# AEM - ApiErrorMessage Helper Object (with humor!)
spew = require "spew"
randomize = require "./randomize"

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
  "Bummer, looks like your missed something"
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

responses403ad = responses403

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
  # @param [String] ex expected message type
  # @param [Option] opt
  #   @option [String] message
  #   @option [String] msg
  #   @option [String] error replacement error/message
  ###
  make: (exp, opt) ->
    # 3 ways to declare the same thing
    errmsg = opt && (opt["error"])
    usrmsg = opt && (opt["message"] || opt["msg"])
    msg = ""
    resp = ""

    code = 200

    switch exp
      when "200"
        resp = randomize.sample responses200
        msg = "OK"
        code = 200
      when "200:login"
        resp = randomize.sample responses200login
        msg = "Login successful"
        code = 200
      when "200:nofunds"
        resp = randomize.sample responses200nofunds
        msg = "OK"
        code = 200
      when "200:delete"
        resp = randomize.sample responses200delete
        msg = "Request received"
        code = 200
      when "200:disapprove"
        resp = randomize.sample responses200disapprove
        msg = "Object has been Disapproved"
        code = 200
      when "200:approve"
        resp = randomize.sample responses200approve
        msg = "Object has been approved"
        code = 200
      when "200:approve_pending"
        resp = randomize.sample responses200approve_pending
        msg = "Request received"
        code = 200
      when "302"
        resp = randomize.sample responses302
        msg = "Redirecting"
        code = 302
      when "400"
        resp = randomize.sample responses400
        msg = "Malformed request"
        code = 400
      when "400:validate"
        resp = randomize.sample responses400validate
        msg = "Validation has failed"
        code = 400
      when "400:save"
        resp = randomize.sample responses400save
        msg = "An error occurred while saving the resource"
        code = 400
      when "401"
        resp = randomize.sample responses401
        msg = "Unauthorized access!"
        code = 401
      when "403"
        resp = randomize.sample responses403
        msg = "Forbidden"
        code = 403
      when "403:ad"
        resp = randomize.sample responses403ad
        msg = "Attempted to access protected Ad"
        code = 403
      when "403:apikey"
        resp = randomize.sample responses403apikey
        msg = "Apikey authentication failed, forbidden to continue"
        code = 403
      when "404"
        resp = randomize.sample responses404
        msg = "Could not find requested resource"
        code = 404
      when "404:ad"
        resp = randomize.sample responses404ad
        msg = "Ad could not be found"
        code = 404
      when "409"
        resp = randomize.sample(responses409)
        msg = "Conflict!"
        code = 409
      when "500"
        resp = randomize.sample responses500
        msg = "An internal error occurred"
        code = 500
      # When an error occurred because of a missing internal reference
      when "500:404"
        resp = randomize.sample responses404
        msg = "An internal error occurred"
        code = 500
      when "500:delete"
        resp = randomize.sample responses500delete
        msg = "Error occurred while removing object"
        code = 500
      when "500:db"
        resp = randomize.sample responses500db
        msg = "A database error occurred"
        code = 500
      when "500:save"
        resp = randomize.sample responses500save
        msg = "An error occurred while saving the resource"
        code = 500
      when "500:unexpected"
        resp = randomize.sample responses500unexpected
        msg = "An unexpected internal error occurred"
        code = 500

    is_error = (not not errmsg) || code >= 400

    msg = errmsg || usrmsg || msg

    obj = {}
    obj.status = code
    obj.humor = resp if @humor
    obj.error = msg if is_error
    obj.message = msg unless is_error
    obj

  ###
  # Generates and sends a message object using the response Object
  # @param [ResultObject] res response object
  # @param [String] ex expected message type
  # @param [Options] opt
  ###
  send: (res, exp, opt) ->

    dat = @make exp, opt

    # optionally we could drop the "status" from the Hash
    res.json dat.status, dat

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
    if param == undefined
      if res and label
        @send res, "400", error: label
      return false
    true

  ###
  # Log db error and send appropriate response
  #
  # @param [Object] res response object
  # @param [Object] err mongoose error object
  # @param [Boolean] passive if false or undefined, issues a res.JSON error
  #
  # @return [Boolean] wasError false if error was undefined or null
  ###
  dbError: (err, res, passive) ->
    if err
      # Just treat cast errors as 404s
      unless passive
        if err.name == "CastError"
          @send res, "404"
        else
          spew.error err
          @send res, "500:db"
      return true
    false