#
# THIS IS WHY WE CAN'T HAVE NICE THINGS.
#
# S3 doesn't always include the proper CORS headers, specifically for newer
# builds of Chrome. As CloudFront caches the first S3 response, it saves the
# CORS-lacking header contents.
# 
# This is a tiny proxy server that is meant to be called by cloudfront. It
# passes the request to S3, but attaches the proper CORS headers before
# responding to Cloudfront.
express = require "express"
request = require "request"
app = express()

s3BucketUrl = "http://adefy-assets.s3.amazonaws.com"

app.disable "x-powered-by"

# Receive request from CloudFront
app.get "*", (req, res) ->

  headers = {}
  headers[key] = req.get(key) for key in req.headers

  # Pass on to S3
  request.get
    url: "#{s3BucketUrl}#{req.url}"
    encoding: null
  , (err, s3Response, body) ->
    return res.send 500 if err

    # Copy over S3 headers
    res.set key, value for key, value of s3Response.headers

    # Set CORS manually
    res.set "Access-Control-Allow-Origin", "*"
    res.set "Access-Control-Allow-Methods", "GET"
    res.set "Barrel Roll", "Phteven"

    # Send S3 reply
    res.end body, "binary"

app.listen 6060
