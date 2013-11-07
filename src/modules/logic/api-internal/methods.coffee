spew = require "spew"
request = require "request"

# Ships an invite request to the database
#
# @param [Object] db Line database object
# @param [String] email
# @param [String] code Invite code
#
# @return [Object] invite
exports.createInvite = (db, email, code) ->

  invite = db.models().Invite.getModel()
    email: email
    code: code

  invite.save()
  invite

# Add the email to our user list in MailChimp
#
# @param [String] email
# @param [Function] successCB called on success
# @param [Function] errorCB called on error with message
exports.sendInviteToMailChimp = (email, successCB, errorCB) ->

  mailChimpOptions = JSON.stringify
    apikey: "f74e47649e4e5d56bd769ab62c4f3131-us3"
    id: "947fb5c10a"
    email:
      email: email

  # Initiate request
  request
    uri: "https://us3.api.mailchimp.com/2.0/lists/subscribe.json"
    method: "POST"
    body: mailChimpOptions
    strictSSL: false
  , (err, res, body) ->

    # Check for error from MailChimp
    if err
      spew.error "MailChimp invite error: #{err}"
      errorCB "Server error"
      return

    # Attempt to parse result; fails on invalid JSON
    try
      mailChimpReply = JSON.parse body

      # Call our successCB if we can, else ship error
      if mailChimpReply.error == undefined then successCB()
      else
        spew.error "MailChimp invite end-error: #{mailChimpReply.error}"
        errorCB mailChimpReply.error

    catch e
      spew.error "MailChimp JSON: #{e} [#{body}]"
      errorCB "Server error"

exports.test = -> spew.info "blargh"