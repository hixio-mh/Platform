spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../../../src/server/models/News"

model = mongoose.model "News"

describe "News Model", ->

  it "Should have a toAPI Method", (done) ->
    news = model()
    expect(news.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    news = model()

    expect(news.title).to.not.exist
    expect(news.text).to.not.exist
    expect(news.summary).to.not.exist

    done()

  describe "Saving", ->

    it "should fail if title or text is missing", (done) ->
      news = model()

      news.save (err) ->
        expect(err).to.exist

        done()

    it "should succeed if all parameters are set", (done) ->

      news = model()
      news.title = "Test Title"
      news.text = "Some content and stuff"

      news.save (err) ->
        expect(err).to.not.exist

        news.remove ->
          done()
