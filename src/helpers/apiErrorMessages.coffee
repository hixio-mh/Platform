##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

# AEM - ApiErrorMessage Helper Object (with humor!)

spew = require "spew"

##
# TODO: Move these to a JSON file possibly
responses200 = [
  "Okay",
  "That's done",
  "Success my friend",
  "Completed successfully comrade"
]

responses200login = [
  "Welcome to the Adefy Orchestra! err Platform",
  "All your Ads are belong to us"
]

responses200nofunds = [
  "Sux to be broke",
  "And we have a winner! (not)"
]

responses200delete = [
  "Never let your sense of morals prevent you from doing what is right!",
  "And Poof, its gone!",
  "*whistle* *sound of paper shredding*",
  "♫♪ Hit the road Jack ♪♫",
  "Vapourized successfully!",
  "Fragged successfully!"
]

responses200disapprove = [
  "*Stamp* Disapproved",
  "Um, nope, maybe some other time"
]

responses200approve = [
  "Adefy, Stamp of Approval",
  "We hope you don't regret this in the end"
]

responses200approve_pending = [
  "We'll think about it",
  "And that's another for the TODO (sigh)",
  "Now, you playing the waiting game",
  "Go grab a latte, this may take awhile"
]

responses400 = [
  "And what was I supposed to do with that?",
  "You're not doing it right",
  "Bummer, looks like your missed something",
  "Not quite what we where expecting"
]

responses401 = [
  "Check your privilege",
  "Go back and get your VIP card",
  "Credentials noah",
  "Is this really yours?",
  "And, you are?"
]

responses403 = [
  "Fancy people only",
  "How about, no",
  "No can do amigo",
  "No Entry!",
  "Um, nope",
  "You shouldn't be here",
  "You came to the wrong neck of the neighborhood bub"
]

responses403apikey = [
  "Sorry bro, we couldn't find your key on the rack",
  "We don't stock that key",
]

responses403ad = responses403

responses404 = [
  "Don't know that one, old chap",
  "Four 'o' Four mate",
  "Couldn't find your moose",
  "I think your map is upside down",
  "Nothing here but us chickens",
  "I present to you: NULL",
  "We couldn't find what you asked, but would you fancy some cats instead?",
  "Looks like we need Sherlock for this one"
]

responses404ad = responses404

responses500 = [
  "ERMAGAWD ERROR!!!",
  "He's dead Jim!",
  "Ackward...",
  "Must have been that renegade cop and the ninja",
  "Its just a paper jam, I swear!",
  "Oh no, the duct tape broke (again)",
  "Do not panic, this is not a drill!",
  "Something went wrong, I think we ran out of bugspray",
  "Arrrg, meltdown in the systems!"
]

responses500delete = [
  "Our shredder got jammed",
  "Our shredder ate a NULL!"
]

responses500db = [
  "The database has exploded! Not really, but something bad happened to it.",
  "The database has exploded! Don't worry, your data is safe. (probably)",
  "The database has exploded! NOOOOOOOOOOOooooooooooo....."
]

responses500save = responses500
responses500ad_save = responses500

responses500unexpected = [
  "Wow, some mojo went down",
  "Who let the magician in?",
  "Somebody slipped by security"
]

module.exports =

  # Add a humourful message to the response?
  humor: true

  #
  # @param [Array] ary
  sample: (ary) ->
    return ary[Math.floor(Math.random() * ary.length)]

  #
  # @param [String] ex expected message type
  # @param [Option] opt
  #   @option [String] error replacement error message
  make: (exp, opt) ->
    errmsg = opt && opt["error"]
    err = ""
    msg = ""

    code = 200

    switch exp
      when "200"
        msg = @sample(responses200)
        err = "OK"
        code = 200
      when "200:login"
        msg = @sample(responses200login)
        err = "Login successful"
        code = 200
      when "200:nofunds"
        msg = @sample(responses200nofunds)
        err = "OK"
        code = 200
      when "200:delete"
        msg = @sample(responses200delete)
        err = "Request received"
        code = 200
      when "200:disapprove"
        msg = @sample(responses200disapprove)
        err = "Object has been Disapproved"
        code = 200
      when "200:approve"
        msg = @sample(responses200approve)
        err = "Object has been approved"
        code = 200
      when "200:approve_pending"
        msg = @sample(responses200approve_pending)
        err = "Request received"
        code = 200
      when "302"
        msg = @sample(responses302)
        err = "Unexpected internal error occurred"
        code = 302
      when "400"
        msg = @sample(responses400)
        err = "Malformed request"
        code = 400
      when "401"
        msg = @sample(responses401)
        err = "Unauthorized access!"
        code = 401
      when "403"
        msg = @sample(responses403)
        err = "Forbidden"
        code = 403
      when "403:ad"
        msg = @sample(responses403ad)
        err = "Attempted to access protected Ad"
        code = 403
      when "403:apikey"
        msg = @sample(responses403apikey)
        err = "Apikey authentication failed, forbidden to continue"
        code = 403
      when "404"
        msg = @sample(responses404)
        err = "Could not find requested resource"
        code = 404
      when "404:ad"
        msg = @sample(responses404ad)
        err = "Ad could not be found"
        code = 404
      when "500"
        msg = @sample(responses500)
        err = "An internal error occurred"
        code = 500
      # When an error occurred because of a missing internal reference
      when "500:404"
        msg = @sample(responses404)
        err = "An internal error occurred"
        code = 500
      when "500:delete"
        msg = @sample(responses500delete)
        err = "Error occurred while removing object"
        code = 500
      when "500:db"
        msg = @sample(responses500db)
        err = "A database error occurred"
        code = 500
      when "500:save"
        msg = @sample(responses500save)
        err = "An error occurred while saving the resource"
        code = 500
      when "500:ad:save"
        msg = @sample(responses500ad_save)
        err = "An error occurred while saving the Ad"
        code = 500
      when "500:unexpected"
        msg = @sample(responses500unexpected)
        err = "An unexpected internal error occurred"
        code = 500

    is_error = code >= 400
    err = errmsg if errmsg != undefined
    msg = err unless @humor
    if is_error
      return { status: code, error: err, message: msg }
    else
      return { status: code, response: err, message: msg }

  #
  # @param [ResultObject] res result object
  # @param [String] ex expected message type
  # @param [Options] opt
  send: (res, exp, opt) ->

    dat = @make(exp, opt)
    # optionally we could drop the "status" from the Hash
    return res.json dat.status, dat