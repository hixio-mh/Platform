mongoose = require "mongoose"
bcrypt = require "bcrypt"
crypto = require "crypto"
spew = require "spew"
redisInterface = require "../helpers/redisInterface"
redis = redisInterface.main

schema = new mongoose.Schema
  username: String
  email: String
  password: String
  apikey: String

  forgotPasswordToken: String
  forgotPasswordTimestamp: Date

  fname: { type: String, default: "" }
  lname: { type: String, default: "" }

  address: { type: String, default: "" }
  city: { type: String, default: "" }
  state: { type: String, default: "" }
  postalCode: { type: String, default: "" }
  country: { type: String, default: "" }

  company: { type: String, default: "" }
  phone: { type: String, default: "" }
  vat: { type: String, default: "" }

  # 0 - admin (root)
  # 1 - unassigned
  # 2 - unassigned
  # ...
  # 7 - normal user
  permissions: { type: Number, default: 7 }

  adFunds: { type: Number, default: 0 }
  pubFunds: { type: Number, default: 0 }

  transactions: [{ action: String, amount: Number, time: Number }]
  pendingWithdrawals: [{ source: String, amount: Number, time: Number, email: String }]

  # Used to store intermediate transaction information. String is of the
  # format id|token
  pendingDeposit: { type: String, default: "" }

  version: { type: Number, default: 2 }

  tutorials:
    dashboard: { type: Boolean, default: true }
    apps: { type: Boolean, default: true }
    ads: { type: Boolean, default: true }
    campaigns: { type: Boolean, default: true }
    reports: { type: Boolean, default: true }
    funds: { type: Boolean, default: true }
    appDetails: { type: Boolean, default: true }
    adDetails: { type: Boolean, default: true }
    campaignDetails: { type: Boolean, default: true }

schema.methods.getRedisId = -> "user:#{@_id}"
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  delete ret.session
  delete ret.permissions
  delete ret.hash
  delete ret.password
  ret

# Tutorial object initialization. Only works if they don't already exist!
schema.methods.createTutorialObjects = (cb) ->

  tutorialPublisher = mongoose.model("Publisher")
    owner: @_id
    name: "Example Publisher"
    tutorial: true

    url: "https://play.google.com/store/apps/details?id=com.rovio.angrybirds"
    description: "Tutorial publisher. No description needed (should be self-explanatory)"
    category: "Games"

    type: 0
    minimumCPM: 2.50
    minimumCPC: 0.30
    preferredPricing: "CPM"

    version: 1

  tutorialAd = mongoose.model("Ad")
    owner: @_id
    name: "Example Ad"
    campaigns: []
    version: 1
    tutorial: true

  tutorialCampaign = mongoose.model("Campaign")
    owner: @_id
    name: "Example Campaign"
    description: "Tutorial campaign. No description needed (should be self-explanatory)"
    category: "Games"
    tutorial: true

    dailyBudget: 1500
    pricing: "CPM"

    bidSystem: "automatic"
    bid: 4.50

    active: false
    ads: []
    networks: ["wifi", "mobile"]

  createPublisher = (done) ->
    mongoose.model("Publisher").findOne
      owner: @_id
      tutorial: true
    , (err, pub) =>
      if err then spew.error err
      if pub then return done()

      tutorialPublisher.generateThumbnailUrl ->
        tutorialPublisher.save (err) ->
          if err then spew.error err

          done()

  createAd = (done) ->
    mongoose.model("Ad").findOne
      owner: @_id
      tutorial: true
    , (err, ad) =>
      if err then spew.error err
      if ad then return done()

      tutorialAd.save (err) ->
        if err then spew.error err

        done()

  createCampaign = (done) ->
    mongoose.model("Campaign").findOne
      owner: @_id
      tutorial: true
    , (err, campaign) =>
      if err then spew.error err
      if campaign then return done()

      tutorialCampaign.save (err) ->
        if err then spew.error err

        done()

  createPublisher -> createAd -> createCampaign -> cb()

# NOTE: This overwrites the fund count stored in redis!
schema.methods.createRedisStruture = (cb) ->
  signedup = new Date(Date.parse(@_id.getTimestamp())).getTime() / 1000
  data = @toAPI()
  data.admin = data.permissions == 0
  data.signedup = signedup

  redis.set "user:apikey:#{@apikey}", JSON.stringify(data), (err) =>
    if err then spew.error err
    redis.set "#{@getRedisId()}:adFunds", @adFunds, (err) =>
      if err then spew.error err
      redis.set "#{@getRedisId()}:pubFunds", @pubFunds, (err) =>
        if err then spew.error err
        if cb then cb()

schema.methods.updateFunds = (cb) ->
  redis.get "#{@getRedisId()}:adFunds", (err, adFunds) =>
    if err then spew.error err
    redis.get "#{@getRedisId()}:pubFunds", (err, pubFunds) =>
      if err then spew.error err
      needsFundsRecreation = false

      if adFunds != null then @adFunds = Number adFunds
      else needsFundsRecreation = true

      if pubFunds != null then @pubFunds = Number pubFunds
      else needsFundsRecreation = true

      if needsFundsRecreation then @createRedisStruture()
      if cb then cb()

schema.methods.generateResetToken = (cb) ->
  crypto.randomBytes 24, (ex, buf) =>
    @forgotPasswordToken = buf.toString "hex"
    @forgotPasswordTimestamp = Date.now()

    if cb then cb()

schema.methods.resetTokenValid = ->
  Date.now() - @forgotPasswordTimestamp <= 1000 * 60 * 30

##
## API Key handling
##

schema.methods.createAPIKey = ->
  if @hasAPIKey() then return

  crypto.randomBytes 24, (ex, buf) ->
    @apikey = buf.toString('hex')

schema.methods.hasAPIKey = ->
  if @apikey and @apikey.length == 24
    true
  else
    false

schema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    if err
      spew.error "Error when comparing hashes"
      return cb err

    cb null, isMatch

schema.methods.addFunds = (amount) ->
  @adFunds += Number amount
  redis.incrbyfloat "#{@getRedisId()}:adFunds", amount

  @transactions.push
    action: "deposit"
    amount: amount
    time: new Date().getTime()

  true

schema.methods.withdrawFunds = (type, amount) ->
  if type == "pub"
    @pubFunds -= Number amount
    redis.incrbyfloat "#{@getRedisId()}:pubFunds", -amount

    @transactions.push
      action: "withdraw"
      amount: amount
      time: new Date().getTime()
  else if type == "ad"
    @adFunds -= Number amount
    redis.incrbyfloat "#{@getRedisId()}:adFunds", -amount

    @transactions.push
      action: "withdraw"
      amount: amount
      time: new Date().getTime()

  true

schema.methods.pushWithdrawalRequest = (source, amount, email) ->

  @pendingWithdrawals.push
    source: (String source)
    amount: (Number amount)
    time: new Date().getTime()
    email: (String email)

  true

schema.pre "save", (next) ->
  if not @isModified "password" then return next()
  if not @hasAPIKey() then @createAPIKey()

  bcrypt.genSalt 10, (err, salt) =>
    if err
      spew.error "Error when generating salt"
      return next err

    bcrypt.hash @password, salt, (err, hash) =>
      if err
        spew.error "Error when hashing password"
        return next err

      @password = hash
      next()

mongoose.model "User", schema
