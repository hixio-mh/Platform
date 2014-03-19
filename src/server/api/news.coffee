##
## News manipulation - /api/v1/news
##
spew = require "spew"
db = require "mongoose"
APIBase = require "./base"
aem = require "../helpers/aem"

class APINews extends APIBase

  constructor: (@app) ->
    super model: "News"
    @registerRoutes()

  ###
  # Creates a new news model with the provided options
  #
  # @param [Object] options
  # @param [ObjectId] auther
  # @return [News] model
  ###
  createNewNews: (options, author) ->
    db.model("News")
      writtenBy: author
      date: new Date()
      title: options.title
      summary: options.summary
      text: options.text

  registerRoutes: ->

    ###
    # POST /api/v1/news
    #   Creates a new News article and returns it
    # @param [String] title
    #   This is the title of the News article
    # @param [String] summary
    #   This is optional and replaces the text when displayed on the front page
    # @param [String] text
    #   This is the body of the News article
    # @response [Object] News returns a newly create News object
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/news",
    #          data:
    #            title: "And Its an Example"
    #            summary: "Today we show you gow to create a new News article"
    #            text: """
    #              So its pretty easy, you just POST to the /api/v1/news
    #              provide it some data and you're ready to go
    #            """
    ###
    @app.post "/api/v1/news", @apiLogin, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      newNews = @createNewNews req.body, req.user.id
      newNews.validate (err) ->
        return aem.send res, "400:validate", error: err if err

        newNews.save -> res.json 200, newNews.toAnonAPI()

    ###
    # GET /api/v1/news
    #   Retrieves all News objects
    # @response [Array<Object>] News
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/news"
    ###
    @app.get "/api/v1/news", @apiLogin, (req, res) =>
      @queryAll res, (list) ->
        res.json 200, list.map (article) -> article.toAnonAPI()

    ###
    # GET /api/v1/news/:id
    #   Retreives a News article by :id
    # @param [ID] id
    # @response [Object] News returns requested News article
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/news/J5VLjLsiPC2xO2VBlhjeMlBL"
    ###
    @app.get "/api/v1/news/:id", @apiLogin, (req, res) =>
      @queryId req.params.id, res, (news) ->
        return aem.send res, "404" unless news

        res.json 200, news.toAnonAPI()

    ###
    # POST /api/v1/news/:id
    #   Updates an existing News article by :id
    # @param [ID] id
    # @response [Object] News returns the updated News article
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/news/iewTKw5y8bQO3FXQZxn3zlgT",
    #          data:
    #            title: "We are having an Ad Storm [EDIT]"
    #            summary: "Today we had a huge update!"
    #            text: """
    #              So much has changed, we'd like to thank blah, dee, dah
    #              EDIT: foobar
    #            """
    ###
    @app.post "/api/v1/news/:id", @apiLogin, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @queryId req.params.id, res, (news) ->
        return aem.send res, "404" unless news

        news.title = req.body.title if req.body.title != undefined
        news.summary = req.body.summary if req.body.summary != undefined
        news.text = req.body.text if req.body.text != undefined

        news.validate (err) ->
          return aem.send res, "400:validate", error: err if err

          news.save -> res.json 200, news.toAnonAPI()

    ###
    # DELETE /api/v1/news/:id
    #   Deletes a News article by :id
    # @param [ID] id
    # @example
    #   $.ajax method: "DELETE",
    #          url: "/api/v1/news/tmHWeHKicu4xINCnhZH7mUDd"
    ###
    @app.delete "/api/v1/news/:id", @apiLogin, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @queryId req.params.id, res, (news) ->
        return aem.send res, "404" unless news

        news.remove -> aem.send res, "200:delete"

module.exports = (app) -> new APINews app
