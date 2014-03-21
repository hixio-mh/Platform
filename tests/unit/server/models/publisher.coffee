spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../../../src/server/models/Publisher"

model = mongoose.model "Publisher"

describe "Publisher Model", ->

  it "Should have a toAPI Method", (done) ->
    pub = model()
    expect(pub.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    pub = model()

    expect(pub.url).to.equal ""
    expect(pub.description).to.equal ""
    expect(pub.category).to.equal ""
    expect(pub.thumbURL).to.equal ""
    expect(pub.active).to.equal false
    expect(pub.status).to.equal 0
    expect(pub.approvalMessage).to.be.empty
    expect(pub.type).to.equal 0

    expect(pub.name).to.not.exist
    expect(pub.apikey).to.not.exist

    done()

  it "Should provide apikey generation", (done) ->
    pub = model()
    expect(pub.createAPIKey).to.exist
    done()

  describe "Api key generation", ->

    it "Should allow apikey generation only once", (done) ->
      pub = model()

      pub.createAPIKey()
      expect(pub.apikey).to.not.be.empty
      expect(pub.apikey.length).to.equal 24

      apikey = pub.apikey
      pub.createAPIKey()

      expect(pub.apikey).to.equal apikey

      done()

  it "Should provide thumbnail url generation", (done) ->
    pub = model()
    expect(pub.generateThumbnailUrl).to.exist
    done()

  describe "Thumbnail url generation", ->

    it "Should generate app thumbnail from package name", (done) ->
      pub = model()

      @timeout 5000

      pub.url = "com.rovio.angrybirds"
      pub.generateThumbnailUrl ->
        expect(pub.thumbURL).to.not.be.empty
        expect(pub.thumbURL.length).to.be.at.least 3

        done()

    it "Should generate app thumbnail from store url", (done) ->
      pub = model()

      @timeout 5000

      pub.url = "https://play.google.com/store/apps/details?id=com.rovio.angrybirds"
      pub.generateThumbnailUrl ->
        expect(pub.thumbURL).to.not.be.empty
        expect(pub.thumbURL.length).to.be.at.least 3

        done()

    it "Should generate default thumbnail", (done) ->
      pub = model()

      @timeout 5000

      pub.generateThumbnailUrl ->
        expect(pub.thumbURL).to.not.be.empty
        expect(pub.thumbURL.length).to.be.at.least 3

        done()

  describe "Field population on save", ->

    it "Should fail to save with no name", (done) ->
      pub = model()

      pub.save (err) ->
        expect(err).to.exist

        pub.remove ->
          done()

    it "Should generate api key on save", (done) ->
      pub = model({ name: "Test" })

      pub.save (err) ->
        expect(err).to.not.exist
        expect(pub.apikey.length).to.equal 24

        pub.remove ->
          done()
