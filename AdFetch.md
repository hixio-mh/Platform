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
    Country: Germany


Publisher request count
-----------------------
First things first, increment the publisher request count

    INCR pub:apikey:requests


Targeting
---------
To begin, we fetch the floor limits and preferred pricing model for the apikey
we receive. Redis query:

    GET pub:apikey

Returning us a serialized object representing the publisher. We now have a bit
more info:

    Pricing: xxx     (Any/CPC/CPM)
    FloorCPC: xxxx   (cents)
    FloorCPM: xxxx   (cents)

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
that result, and all ads within germany:

    SUNIONSTORE apikey:timestamp:germany [ apikey:timestamp country:germany ]

Now check the length of the result. If empty, we take the initial result. If
that one is empty as well, we attempt to backfill.

    SCARD apikey:timestamp:germany

    (if empty)

    SCARD apikey:timestamp:germany

If the result is non-empty, we continue onwards with it. If it is, we
backfill. (Backfill.md)


RTB
---
We now have a set of suitable ads, of the form campaign_id:ad_id. Fetch ad data:

    MGET ad-keys

Ad objects are of the form

    sxx...x|rimpressions|avgcpm|impressions|clicks|spent

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

The fourth, fifth, and sixth contain lifetime stats for this ad under this
campaign. Total impressions, clicks, and cents spent.

*If the pricing model is CPC, we deliver the ad directly, skipping all of this*

If it has 999 running impressions, calculate the final avgcpm and charge the
campaign + update spent amount on ad. Then clear both the rimpressions and
avgcpm fields.

Otherwise, increment the running impressions and calculate the new avgcpm.

*If the pricing model is CPC, continue from here*

Increment the impresssions field in either case!

Finally, fetch the actual ad data, from ad_id:data, and deliver

    GET ad_id:data

Ship!


Earnings
--------
If the ad is priced by CPM, and this is the 1000th impression, we need to
distribute earnings. For now, we take forward all earnings. To make things
simpler in the future, we store our cut % within redis. So fetch it now:

    GET adefy:profit_cut

Calculate publisher profit (1 - profit_cut) and update

    INCRBYFLOAT pub:apikey:earnings publisher-profit
    INCRBYFLOAT adefy:profit adefy-publisher


Publisher tracking
------------------
Now we need to increment the publisher impression count (assuming we've
shipped an ad, as above)

    INCR pub:apikey:impressions


*The above process should have logged many, many events to statsd*