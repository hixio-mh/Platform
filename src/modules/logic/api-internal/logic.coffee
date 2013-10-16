spew = require "spew"
crypto = require "crypto"

##
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  # Helpful security check (on its own since a request without a user shouldn't
  # reach this point)
  userCheck = (req, res, passive) ->
    if passive != true then passive = false

    if req.cookies.user == undefined
      if not passive then res.json { error: "Invalid user [uc] (CRITICAL)" }
      return false
    true

  # Fails if the user result is empty
  userValid = (user, res, passive) ->
    if passive != true then passive = false

    if (user instanceof Array and user.length <= 0) or user == undefined
      if not passive then res.json { error: "Invalid user [uv] (CRITICAL)" }
      return false
    true

  # Calls the cb with admin status, and the fetched user
  verifyAdmin = (req, res, cb, passive) ->
    if passive != true then passive = false

    if req.cookies.admin != "true"
      if not passive then res.json { error: "Unauthorized" }
      cb false

    if not userCheck req, res, passive then cb false

    db.fetch "User", { username: req.cookies.user.id, session: req.cookies.user.sess }, (user) ->
      if not userValid user, res, passive then cb false

      if user.permissions != 0
        if not passive then res.json { error: "Unauthorized" }
        cb false
      else cb true, user

  # Top-level routing

  ## ** Unprotected ** - public invite add request!
  server.server.get "/logic/invite/add", (req, res) ->
    if not utility.param req.query.key, res, "Key" then return
    if not utility.param req.query.email, res, "Email" then return

    if req.query.key != "WtwkqLBTIMwslKnc" and req.query.key != "T13S7UESiorFUWMI"
      res.json { error: "Invalid key" }
      return

    invite = db.models().Invite.getModel()
      email: req.query.email
      code: utility.randomString 32

    invite.save()

    if req.query.key == "WtwkqLBTIMwslKnc"
      res.json { msg: "Added" }
    else if req.query.key == "T13S7UESiorFUWMI"
      res.json { email: invite.email, code: invite.code, id: invite._id }

  # Invite manipulation - /logic/invite/:action
  #
  #   /get      getInvite
  #
  # admin only
  server.server.get "/logic/invite/:action", (req, res) ->
    verifyAdmin req, res, (admin) ->
      if not admin then return

      if req.params.action == "all" then _getAllInvites req, res
      else if req.params.action == "update" then _updateInvite req, res
      else if req.params.action == "delete" then _deleteInvite req, res
      else res.json { error: "Unknown action #{req.params.action} "}

  # User manipulation - /logic/user/:action
  #
  #   /get      getUser
  #
  # Some routes are admin only
  server.server.get "/logic/user/:action", (req, res) ->
    if not userCheck req, res then return

    # Admin-only
    if req.params.action == "get"
      verifyAdmin req, res, (admin) ->
        if not admin then return else getUser req, res

    # Admin-only
    else if req.params.action == "delete"
      verifyAdmin req, res, (admin) ->
        if not admin then return else deleteUser req, res

    else if req.params.action == "self"
      if not userCheck req, res then return else getUserSelf req, res

    else if req.params.action == "save"
      if not userCheck req, res then return else saveUser req, res

    else res.json { error: "Unknown action #{req.params.action} "}

  # Ad manipulation - /logic/ads/:action
  #
  #   /get      getAd
  #   /create   createAd
  #   /delete   deleteAd
  #
  server.server.get "/logic/ads/:action", (req, res) ->
    if not userCheck req, res then return

    if req.params.action == "get" then getAd req, res
    else if req.params.action == "create" then createAd req, res
    else if req.params.action == "delete" then deleteAd req, res
    else res.json { error: "Unknown action #{req.params.action} " }

  # Campaign manipulation - /logic/campaigns/:action
  #
  #   /create   createCampaign
  #
  server.server.get "/logic/campaigns/:action", (req, res) ->
    if not userCheck req, res then return

    if req.params.action == "create" then createCampaign req, res
    else if req.params.action == "get" then fetchCampaigns req, res
    else if req.params.action == "delete" then deleteCampaign req, res
    else if req.params.action == "events" then fetchCampaignEvents req, res
    else if req.params.action == "save" then saveCampaign req, res
    else res.json { error: "Unknown action #{req.params.action}" }

  # Publisher manipulation - /logic/publishers/:action
  #
  #   /create   createPublisher
  #   /save     savePublisher
  #   /delete   deletePublisher
  #
  server.server.get "/logic/publishers/:action", (req, res) ->
    if not userCheck req, res then return

    if req.params.action == "create" then createPublisher req, res
    else if req.params.action == "save" then savePublisher req, res
    else if req.params.action == "delete" then deletePublisher req, res
    else if req.params.action == "get" then getPublishers req, res
    else if req.params.action == "approve" then approvePublisher req, res
    else res.json { error: "Unknown action #{req.params.action}"}

  ##
  ## Invite manipulation
  ##
  _getAllInvites = (req, res) ->

    # Fetch wide, result always an array
    db.fetch "Invite", {}, (data) ->

      if data.length == 0 then res.json []

      # TODO: Figure out why result is not wide
      if data !instanceof Array then data = [ data ]

      # Data fetched, send only what is needed
      ret = []

      for i in data
        invite = {}
        invite.email = i.email
        invite.code = i.code
        invite.id = i._id
        ret.push invite

      res.json ret

    , (err) -> res.json { error: err }
    , true

  _deleteInvite = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.fetch "Invite", { _id: req.query.id }, (invite) ->

      if invite.length == 0 then res.json { error: "No such invite" }
      else
        invite.remove()
        res.json { msg: "OK" }

  _updateInvite = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.email, res, "Email" then return
    if not utility.param req.query.code, res, "Code" then return

    db.fetch "Invite", { _id: req.query.id }, (invite) ->

      if invite.length == 0 then res.json { error: "No such invite" }
      else

        invite.code = req.query.code
        invite.email = req.query.email
        invite.save()
        res.json { msg: "OK" }

  ##
  ## User manipulation
  ##

  # Delete user
  deleteUser = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.fetch "User", { _id: req.query.id }, (user) ->
      if user.length = 0 then res.json { error: "No such user" }
      else

        if req.cookies.user.sess == user.session
          res.json { error: "You can't delete yourself!" }
          return

        spew.info "Deleted user #{user.username}"

        user.remove()
        res.json { msg: "OK" }

  # Retrieve use, expects {filter}
  getUser = (req, res) ->
    if not utility.param req.query.filter, res, "Filter" then return

    if req.query.filter == "username" then _getUserByUsername req, res
    else if req.query.filter == "all" then _getAllUsers req, res

  # Retrieve the user represented by the cookies on the request. Used on
  # the backend account page
  getUserSelf = (req, res) ->

    _username = req.cookies.user.id
    _session = req.cookies.user.sess

    db.fetch "User", { username: _username, session: _session }, (user) ->

      ret =
        username: user.username
        fname: user.fname
        lname: user.lname
        email: user.email
        company: user.company
        address: user.address
        city: user.city
        state: user.state
        postalCode: user.postalCode
        country: user.country
        phone: user.phone
        fax: user.fax

      res.json ret

    , (err) -> res.json { error: err }

  # Saves both the user signed in, and any user if we are an admin
  #
  # If we are admin, expect a username
  saveUser = (req, res) ->
    verifyAdmin req, res, (admin) ->

      # Query current user
      if admin == false
        query = { username: req.cookies.id, session: req.cookies.sess }
      else query = { username: req.query.username }

      db.fetch "User", query, (user) ->
        if user == undefined or user.length == 0
          res.json { error: "No such user" }
          return

        user.fname = req.query.fname
        user.lname = req.query.lname
        user.email = req.query.email
        user.company = req.query.company
        user.address = req.query.address
        user.city = req.query.city
        user.state = req.query.state
        user.postalCode = req.query.postalCode
        user.country = req.query.country
        user.phone = req.query.phone
        user.fax = req.query.fax

        user.save()
        res.json { msg: "OK" }

    , true

  # Retrieves all users for list rendering
  _getAllUsers = (req, res) ->

    # Fetch wide, result always an array
    db.fetch "User", {}, (data) ->

      # TODO: Figure out why result is not wide
      if data not instanceof Array then data = [ data ]

      # Data fetched, send only what is needed
      ret = []

      for u in data
        user = {}
        user.username = u.username
        user.fname = u.fname
        user.lname = u.lname
        user.email = u.email
        user.id = u._id
        ret.push user

      res.json ret

    , (err) -> res.json { error: err }
    , true

  # Expects {username}
  _getUserByUsername = (req, res) ->
    if not utility.param req.params.username, res, "Username" then return

    # TODO: Sanitize

    # Fetch wide, result always an array
    db.fetch "User", { username: req.params.username }, (user) ->

      if not userValid user, res then return

      # Data fetched, send only what is needed
      ret = {}
      ret.username = user.username
      ret.fname = user.fname
      ret.lname = user.lname
      ret.email = user.email

      res.json ret

  ##
  ## Ad manipulation
  ##

  # Create an ad, expects {name} in url and req.cookies.user to be valid
  createAd = (req, res) ->
    if not utility.param req.query.name, res, "Ad name" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->

      if not userValid user, res then return

      # Create new ad entry
      newAd = db.models().Ad.getModel()
        owner: user._id
        name: req.query.name
        data: ""

      newAd.save (err) ->
        if err
          spew.error "Error saving new ad [#{err}"
          res.json { error: err }
          return

        spew.info "Created new ad '#{req.query.name}' for #{user.username}"
        res.json { ad: { id: newAd._id, name: newAd.name }}

  # Delete an ad, expects {id} in url and req.cookies.user to be valid
  deleteAd = (req, res) ->
    if not utility.param req.query.id, res, "Ad id" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid user, res then return

      # If we have admin privs, then delete the ad even without ownership
      query = { _id: req.query.id, owner: user._id }

      verifyAdmin req, res, (admin) ->
        if admin then query = { _id: req.query.id }

        db.fetch "Ad", query, (ad) ->

          if ad == undefined or ad.length == 0
            res.json { error: "No such ad found" }
            return

          if !admin and ad.owner != user._id
            res.json { error: "Unauthorized" }
            return

          ad.remove()
          res.json { msg: "Deleted ad #{req.query.id}" }
      , true

  # Main GET method, expects {filter}
  getAd = (req, res) ->
    if not utility.param req.query.filter, res, "Filter" then return

    if req.query.filter == "user" then _getAdByUser req, res
    else res.json { error: "Invalid filter" }

  # Expects req.cookies.user to be valid
  _getAdByUser = (req, res) ->
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid user, res then return

      # Fetch data and reply
      db.fetch "Ad", { owner: user._id }, (data) ->

        ret = []

        if data.length > 0
          for a in data
            ad = {}
            ad.name = a.name
            ad.id = a._id

            ret.push ad

        res.json ret

      , ((err) -> res.json { error: err }), true # db fetch Ad

  ##
  ## Campaign manipulation
  ##
  createCampaign = (req, res) ->
    if not utility.param req.query.name, res, "Campaign name" then return
    if not utility.param req.query.description, res, "Description" then return
    if not utility.param req.query.category, res, "Category" then return
    if not utility.param req.query.pricing, res, "Pricing" then return
    if not utility.param req.query.totalBudget, res, "Total budget" then return
    if not utility.param req.query.dailyBudget, res, "Daily budget" then return
    if not utility.param req.query.system, res, "Bid system" then return
    if not utility.param req.query.bid, res, "Bid" then return
    if not utility.param req.query.bidMax, res, "Max bid" then return

    query =
      username: req.cookies.user.id
      session: req.cookies.user.sess

    # Fetch user
    db.fetch "User", query, (user) ->
      if not userValid user, res then return

      # Create new campaign
      newCampaign = db.models().Campaign.getModel()
        owner: user._id
        name: req.query.name
        description: req.query.description
        category: req.query.category
        pricing: req.query.pricing
        totalBudget: Number req.query.totalBudget
        dailyBudget: Number req.query.dailyBudget
        bidSystem: req.query.system
        bid: Number req.query.bid
        maxBid: Number req.query.bidMax

        status: 0 # 0 is created, no ads
        avgCPC: 0
        clicks: 0
        impressions: 0
        spent: 0

      # Pass placeholder for daily if none provided
      if newCampaign.dailyBudget.length == 0 then newCampaign.dailyBudget = "-"

      newCampaign.save()
      res.json { msg: "OK" }

  # Fetch campaigns owned by the user identified by the cookie
  fetchCampaigns = (req, res) ->
    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      db.fetch "Campaign", { owner: user._id }, (campaigns) ->

        ret = []

        # Remove the owner id, and refactor the id field
        for c in campaigns

          ret.push
            id: c._id
            name: c.name
            description: c.description
            category: c.category
            pricing: c.pricing
            totalBudget: c.totalBudget
            dailyBudget: c.dailyBudget
            bidSystem: c.bidSystem
            bid: c.bid
            maxBid: c.maxBid

            status: c.status
            avgCPC: c.avgCPC
            clicks: c.clicks
            impressions: c.impressions
            spent: c.spent

        res.json ret

      , ((err) -> res.json { error: err }), true
    , true

  # Fetches events associated with the campaign. If not admin, user must own
  # the campaign
  fetchCampaignEvents = (req, res) ->
    if not utility.param req.query.id, res, "Campaign id" then return

    # Build campaign event fetch function first so we can skip campaign
    # ownership verification for admins
    fetchAndReplyWithEvents = (res, id) ->

      db.fetch "CampaignEvent", { campaign: id }, (events) ->

        # Go through and send only affected list, along with a timestamp
        ret = []

        for e in events

          affected = []
          for a in e.affected
            affected.push
              name: a.name
              valuePre: a.valuePre
              valuePost: a.valuePost

              # TODO: Send target type (ad), and target name instead of id

          ret.push
            time: Date.parse e._id.getTimestamp()
            affected: affected

        res.json ret
      , ((error) -> res.json { error: error }), true

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # If admin, fetch
      if admin then fetchAndReplyWithEvents res, req.query.id
      else

        # If not, verify ownership before fetching
        db.fetch "Campaign", { owner: user._id }, (campaign) ->

          if campaign == undefined or campaign.length == 0
            res.json { error: "No such campaign" }
            return

          if campaign.owner != user._id
            res.json { error: "Unauthorized!" }
            return

          # Verified, fetch
          fetchAndReplyWithEvents res, req.query.id

    , true

  # Saves the campaign and generates new campaign events. User must either be
  # admin or own the campaign in question!
  saveCampaign = (req, res) ->
    if not utility.param req.query.id, res, "Campaign id" then return
    if not utility.param req.query.mod, res, "Modifications" then return

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch campaign
      db.fetch "Campaign", { _id: req.query.id }, (campaign) ->

        if campaign == undefined or campaign.length == 0
          res.json { error: "No such campaign!" }
          return

        if not admin
          if campaign.owner != user._id
            res.json { error: "Unauthorized!" }
            return

        # Go through and apply changes
        mod = JSON.parse req.query.mod
        affected = []

        for diff in mod

          # Make sure we aren't setting a value that doesn't exist, or one
          # that doesn't match our expected pre value
          if String(campaign[diff.name]) == diff.pre

            # Figure out target based on what is being saved
            # For now, no target. Sneaky sneaky.

            # Add to our affected array
            affected.push
              name: diff.name
              valuePre: campaign[diff.name]
              valuePost: diff.post

            # Apply change
            campaign[diff.name] = diff.post

        if affected.length > 0

          # Now create the campaign event
          newEvent = db.models().CampaignEvent.getModel()
            campaign: campaign._id
            affected: affected

          campaign.save()
          newEvent.save()

        res.json { msg: "OK" }

    , true

  # Delete the campaign identified by req.query.id
  #
  # If we are not the administrator, we must own the campaign!
  deleteCampaign = (req, res) ->
    if not utility.param req.query.id, res, "Campaign id" then return

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch campaign
      db.fetch "Campaign", { _id: req.query.id }, (campaign) ->

        if campaign == undefined or campaign.length == 0
          res.json { error: "No such campaign!" }
          return

        if not admin
          if campaign.owner != user._id
            res.json { error: "Unauthorized!" }
            return

        # Assuming we've gotten to this point, we are authorized to perform
        # the delete
        campaign.remove()

        res.json { msg: "OK" }

    , true

  ##
  ## Publisher manipulation
  ##

  # Create new publisher on identified user
  createPublisher = (req, res) ->
    if not utility.param req.query.name, res, "Application name" then return

    # Validate type
    if Number(req.query.type) == undefined then type = 0
    else if Number(req.query.type) == 1 then type = 1
    else if Number(req.query.type) == 2 then type = 2
    else type = 0

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      req.query.url = req.query.url || ""
      req.query.description = req.query.description || ""

      newPublisher = db.models().Publisher.getModel()
        owner: user._id
        name: String req.query.name
        type: type
        url: String req.query.url
        category: String req.query.category
        description: String req.query.description

        status: 0
        active: false
        apikey: utility.randomString 32
        impressions: 0
        clicks: 0
        requests: 0
        earnings: 0

      newPublisher.save()
      res.json { msg: "OK" }

    , true

  # Save edits to existing publisher, user must either own the publisher or be
  # an admin
  savePublisher = (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return
    if not utility.param req.query.mod, res, "Modifications" then return

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch publisher
      db.fetch "Publisher", { _id: req.query.id }, (publisher) ->

        if publisher == undefined or publisher.length == 0
          res.json { error: "No such publisher!" }
          return

        if not admin
          if publisher.owner != user._id
            res.json { error: "Unauthorized!" }
            return

        # Go through and apply changes
        mod = JSON.parse req.query.mod
        affected = []

        for diff in mod

          # Make sure we aren't setting a value that doesn't exist, or one
          # that doesn't match our expected pre value
          if String(publisher[diff.name]) == String diff.pre
            publisher[diff.name] = diff.post

        publisher.save()
        res.json { msg: "OK" }

    , true

  # Delete publisher, user must either own the publisher or be an admin
  deletePublisher = (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch campaign
      db.fetch "Publisher", { _id: req.query.id }, (publisher) ->

        if publisher == undefined or publisher.length == 0
          res.json { error: "No such campaign!" }
          return

        if not admin
          if publisher.owner != user._id
            res.json { error: "Unauthorized!" }
            return

        # Assuming we've gotten to this point, we are authorized to perform
        # the delete
        publisher.remove()

        res.json { msg: "OK" }

    , true

  # Fetches owned publisher list
  getPublishers = (req, res) ->
    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      db.fetch "Publisher", { owner: user._id }, (publishers) ->

        ret = []

        for p in publishers
          ret.push
            id: p._id
            name: p.name
            url: p.url
            description: p.description
            category: p.category
            active: p.active
            apikey: p.apikey
            type: p.type
            impressions: p.impressions
            requests: p.requests
            clicks: p.clicks
            earnings: p.earnings
            status: p.status
            approvalMessage: p.approvalMessage

        res.json ret

      , ((error) -> res.json { error: error }), true

    , true

  # Updates publisher status if applicable
  #
  # We abuse the verifyAdmin method since it fetches the user for us, which we
  # use to check for ownership. Admins don't get any special treatment here
  approvePublisher = (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return

    verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      db.fetch "Publisher", { _id: req.query.id, owner: user._id }, (pub) ->
        if pub == undefined or pub.length == 0
          res.json { error: "No such publication" }
          return

        if pub[0].status == 0 or pub[0].status == 1
          pub[0].status = 3
          pub[0].save()

        res.json { msg: "OK" }

      , ((error) -> res.json { error: error }), true

    , true

  register null, {}

module.exports = setup