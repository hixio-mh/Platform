Ad fetch cycle - magic and mystery
=============================
Ad requests come in with an unpredictable amount of data. Although we store
some data in MongoDB, the majority of it exists within Redis.

A query may come in with the following filters (as an example):

    APIKey: xxxxxxxxxxxxxxxx
    Platform: Android
    Device: Nexus 4
    Screen: 768x1280 (available space)
    Type: Animated
    Load style: 1
    Category: Automobiles
    IP: xx.xxx.xx.xx

We perform ip2geo targeting with MaxMind (maxmind-db-reader npm module), to
arrive at our final data set:

    APIKey: xxxxxxxxxxxxxxxx
    Platform: Android
    Device: Nexus 4
    Screen: 768x1280 (available space)
    Type: Animated
    Load style: 1
    Category: Automobiles
    City: Paris


Targeting
---------
To begin, we fetch the floor limits and preferred pricing model for the apikey
we receive. Redis query:

    GET apikey

Returning us a serialized object representing the publisher. We now have a bit
more info:

    Pricing: xxx     (Any/CPC/CPM)
    FloorCPC: xxxx   (cents)
    FloorCPM: xxxx   (cents)
    StrictPricing: x (bool)

At this point we shoot a query into Redis:

    # Pricing is either cpc, cpm, or * if none is preferred

    SUNIONSTORE apikey:timestamp [
      pricing:automobiles:platform:android,
      pricing:automobiles:device:nexus4,
      pricing:automobiles:screen:768x1280,
      pricing:automobiles:type:animated,
      pricing:automobiles:style:1
    ]

The result is stored under `apikey:timestamp`. Now we perform a union between
that result, and all ads within paris:

    SUNIONSTORE apikey:timestamp:paris [ apikey:timestamp paris ]

Now check the length of the result. If empty, we take the initial result. If
that one is empty as well, we attempt to backfill.

    SCARD apikey:timestamp:paris

    (if empty)

    SCARD apikey:timestamp:paris

If the result is non-empty, we continue onwards with it. If it is, we
backfill. (Backfill.md)


RTB
---
We now have a set of suitable ads, of the form campaign_id:ad_id. Fetch JSON
objects:

    MGET ad-keys

Ad objects are of the form

    Sxx...x|rimpressions|avgcpm

Where the first character is the bid system (a/m for auto/manual), and the
rest is the bid amount in cents. (In the first block)

Now go through and perform automatic bidding on the keys that need it. Find the
two largest keys, and floor the larger key to 1 cent above the smaller.


Automatic Bidding
-----------------
TODO


Fill
----
The second and third blocks contain a running impression count, and the current
average CPM delivered by the ad.

*If the pricing model is CPC, we deliver the ad directly, skipping all of this*

If it has 999 running impressions, calculate the final avgcpm and charge the
campaign + update spent amount. Then clear both the rimpressions and avgcpm
fields.

Otherwise, increment the running impressions and calculate the new avgcpm.

*If the pricing model is CPC, continue from here*

Finally, fetch the actual ad data, from ad_id:data, and deliver

    GET ad_id:data

Ship!