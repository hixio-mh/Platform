# AEM - ApiErrorMessage Helper Object (with humor!)
spew = require "spew"
_ = require "lodash"
compare = require "./compare"

##
# TODO: Move these to a JSON file possibly
responses200 = [
  "Okay"
  "That's done"
  "Success my friend"
  "Completed successfully comrade"
]

responses200login = [
  "Welcome to the Adefy Orchestra! err Platform"
  "All your Ads are belong to us"
]

responses200nofunds = [
  "Sux to be broke"
  "And we have a winner! (not)"
]

responses200delete = [
  "Never let your sense of morals prevent you from doing what is right!"
  "And Poof, its gone!"
  "*whistle* *sound of paper shredding*"
  "♫♪ Hit the road Jack ♪♫"
  "Vapourized successfully!"
  "Fragged successfully!"
]

responses200disapprove = [
  "*Stamp* Disapproved"
  "Um, nope, maybe some other time"
]

responses200approve = [
  "Adefy, Stamp of Approval"
  "We hope you don't regret this in the end"
]

responses200approve_pending = [
  "We'll think about it"
  "And that's another for the TODO (sigh)"
  "Now, you playing the waiting game"
  "Go grab a latte, this may take awhile"
]

responses400 = [
  "And what was I supposed to do with that?"
  "You're not doing it right"
  "Bummer, looks like you missed something"
  "Not quite what we where expecting"
]

responses400save = responses400
responses400validate = responses400

responses401 = [
  "Check your privilege"
  "Go back and get your VIP card"
  "Credentials noah"
  "Is this really yours?"
  "And, you are?"
]

responses403 = [
  "Fancy people only"
  "How about, no"
  "No can do amigo"
  "No Entry!"
  "Um, nope"
  "You shouldn't be here"
  "You came to the wrong neck of the neighborhood bub"
]

responses403apikey = [
  "Sorry bro, we couldn't find your key on the rack"
  "We don't stock that key"
]

responses404 = [
  "Don't know that one, old chap"
  "Four 'o' Four mate"
  "Couldn't find your moose"
  "I think your map is upside down"
  "Nothing here but us chickens"
  "I present to you: NULL"
  "We couldn't find what you asked, but would you fancy some cats instead?"
  "Looks like we need Sherlock for this one"
]

responses404ad = responses404

responses409 = [
  "Looks like you already have something",
  "No you can't, because the system would explode"
]

responses500 = [
  "ERMAGAWD ERROR!!!"
  "He's dead Jim!"
  "Ackward..."
  "Must have been that renegade cop and the ninja"
  "Its just a paper jam, I swear!"
  "Oh no, the duct tape broke (again)"
  "Do not panic, this is not a drill!"
  "Something went wrong, I think we ran out of bugspray"
  "Arrrg, meltdown in the systems!"
  "Something weird just happened"
]

responses500delete = [
  "Our shredder got jammed"
  "Our shredder ate a NULL!"
]

responses500db = [
  "The database has exploded! Not really, but something bad happened to it."
  "The database has exploded! Don't worry, your data is safe. (probably)"
  "The database has exploded! NOOOOOOOOOOOooooooooooo....."
]

responses500unexpected = [
  "Wow, some mojo went down"
  "Who let the magician in?"
  "Somebody slipped by security"
]

module.exports =

  # Add a humourful message to the response?
  humor: true

  ###
  # Generates a message object
  # @param [String] messageType expected message type
  # @param [Option] options
  #   @option [String] message
  #   @option [String] msg
  #   @option [String] error replacement error/message
  ###
  make: (messageType, options) ->
    # 3 ways to declare the same thing
    errmsg = options && (options["error"])
    usrmsg = options && (options["message"] || options["msg"])
    msg = ""
    response = ""

    code = 200

    switch messageType
      # Generic 200
      when "200"
        response = _.sample responses200
        msg = "OK"
        code = 200
      # Response to a successful login
      when "200:login"
        response = _.sample responses200login
        msg = "Login successful"
        code = 200
      # Soft response to user not having enough funds
      when "200:nofunds"
        response = _.sample responses200nofunds
        msg = "You do not appear to have enough funds to complete this action"
        code = 200
      # Response to a resource deletion request
      when "200:delete"
        response = _.sample responses200delete
        msg = "Request received"
        code = 200
      # Response to a resource dissaproval request
      when "200:disapprove"
        response = _.sample responses200disapprove
        msg = "Object has been disapproved"
        code = 200
      # Response to a resource approval request
      when "200:approve"
        response = _.sample responses200approve
        msg = "Object has been approved"
        code = 200
      # Response to a resource aproval request (in pending)
      when "200:approve_pending"
        response = _.sample responses200approve_pending
        msg = "Request received"
        code = 200
      # Generic 302
      when "302"
        response = _.sample responses302
        msg = "Redirecting"
        code = 302
      # Generic 400 error
      when "400"
        response = _.sample responses400
        msg = "Malformed request"
        code = 400
      # When an error occurs because of validation error
      when "400:validate"
        response = _.sample responses400validate
        msg = "Validation has failed"
        code = 400
      # When an error occurs during saving, possibly by validation
      when "400:save"
        response = _.sample responses400save
        msg = "An error occurred while saving the resource"
        code = 400
      # Generic 401 error
      when "401"
        response = _.sample responses401
        msg = "Unauthorized access!"
        code = 401
      # Generic 403 error
      when "403"
        response = _.sample responses403
        msg = "Forbidden"
        code = 403
      # apikey authentication failed
      when "403:apikey"
        response = _.sample responses403apikey
        msg = "Apikey authentication failed, forbidden to continue"
        code = 403
      # Generic 404 error
      when "404"
        response = _.sample responses404
        msg = "Could not find requested resource"
        code = 404
      when "404:ad"
        response = _.sample responses404ad
        msg = "Ad could not be found"
        code = 404
      when "409"
        response = _.sample responses409
        msg = "Conflict!"
        code = 409
      # Generic 500 error
      when "500"
        response = _.sample responses500
        msg = "An internal error occurred"
        code = 500
      # When an error occurred because of a missing internal reference
      when "500:404"
        response = _.sample responses404
        msg = "An internal error occurred"
        code = 500
      # When an error occurs during the removal of an internal resource
      when "500:delete"
        response = _.sample responses500delete
        msg = "Error occurred while removing object"
        code = 500
      # When an error occurs during the accessing of a Database
      when "500:db"
        response = _.sample responses500db
        msg = "A database error occurred"
        code = 500
      # When an error while saving occurs, despite the data
      when "500:save"
        response = _.sample responses500save
        msg = "An error occurred while saving the resource"
        code = 500
      # When an error occurs from something funky
      when "500:unexpected"
        response = _.sample responses500unexpected
        msg = "An unexpected internal error occurred"
        code = 500

    is_error = (not not errmsg) || code >= 400

    msg = errmsg || usrmsg || msg

    ret = {}
    ret.status = code
    ret.humor = response if @humor
    ret.error = msg if is_error
    ret.message = msg unless is_error
    ret

  ###
  # Generates and sends a message object using the response Object
  # @param [ResultObject] res response object
  # @param [String] messageType expected message type
  # @param [Options] options
  ###
  send: (res, messageType, options) ->

    responseData = @make messageType, options

    # optionally we could drop the "status" from the Hash
    res.json responseData.status, responseData

  ###
  # Check for missing param, return a JSON error if needed
  #
  # @param [Object] res response object
  # @param [Object] param param to check for
  # @param [String] label param name
  #
  # @return [Boolean] valid true if the param is defined
  ###
  param: (param, res, label) ->
    return true if param != undefined

    @send res, "400", error: label if res and label
    false

  ###
  # Log db error and send appropriate response
  #
  # @param [Object] res response object
  # @param [Object] err mongoose error object
  # @param [Boolean] passive if false or undefined, issues a res.JSON error
  #
  # @return [Boolean] wasError false if error was undefined or null
  ###
  dbError: (err, res) ->
    return false unless err

    # Just treat cast errors as 404s
    if res
      if err.name == "CastError"
        @send res, "404"
      else
        spew.error err
        @send res, "500:db"

    true

  ###
  # Determines if (user) is the owner of (obj), a 401 is sent if the check
  # results in false (if a res object is given)
  # @param [Object] user
  # @param [Object] obj
  # @param [Response] res
  ###
  isOwnerOf: (user, obj, res) ->
    return false unless obj.owner != undefined
    return true if user.admin or compare.isOwnerOf(user, obj)

    @send res, "401" if res
    false

  ###
  # Optionally determines if (obj) is a Number, if not a 400 error is
  # sent (if res is given)
  # @param [Object] obj
  # @param [Object] name A name that will appear in the error string
  # @param [Response] res
  ###
  optIsNumber: (obj, name, res) ->
    return true unless isNaN obj

    if res
      name = name || "object"
      @send res, "400", error: "Invalid #{name} (expected a Number)"

    false

  ###
  # Optionally determines if (obj) is one of the given objects in opts
  # if not a 400 error is sent (if res is given)
  # @param [Object] obj
  # @param [Object] name A name that will appear in the error string
  # @param [Response] res
  ###
  optIsOneOf: (obj, opts, name, res) ->
    return false if obj == undefined
    return true if _.contains opts, obj

    if res
      name = name || "object"
      opts_s = opts.join(" or ")
      @send res, "400", error: "Invalid #{name} (expected #{opts_s})"

    false
