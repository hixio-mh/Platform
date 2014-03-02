spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/News"

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

  it "Should fail if title or text is missing", (done) ->

    news = model()

    news.title = undefined
    news.text = undefined

    news.save (err) ->
      expect(err).to.exist
      done()

  it "Should succeed all parameters are set", (done) ->

    news = model()
    news.title = "Test Title"
    news.text = "Some content and stuff"

    news.save (err) ->
      expect(err).to.not.exist
      done()

    news.remove()