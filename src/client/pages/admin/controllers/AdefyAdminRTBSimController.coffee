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

angular.module("AdefyApp").controller "AdefyAdminRTBSimController", ($scope, $http, $route) ->

  $scope.budget = 50000
  $scope.impressions = 0
  $scope.averageBid = 0
  $scope.pace = 1
  $scope.flowControl = 10

  $scope.chart =
    static: [
      name: "Impressions"
      color: "#97bbcd"
    ,
      name: "Bids"
      color: "#cc97a6"
    ,
      name: "Pacing"
      color: "#96cc97"
    ]

    dynamic: [
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
    ]

  bidder = new Bidder $scope.budget, 5, $scope
  bidder.onUpdate = (budget, impressions, avgBid, pace) ->
    $scope.$apply ->
      $scope.budget = budget.toFixed 2
      $scope.impressions = impressions
      $scope.averageBid = avgBid.toFixed 2
      $scope.pace = pace.toFixed 6

  bidder.run()

  # Set up flow control modifier
  setInterval =>
    $scope.$apply ->
      $scope.flowControl = Math.ceil(Math.random() * 1000)
  , 60000

class Bidder

  startBudget: 0
  budget: 0
  pace: 1
  impressions: 0
  avgBid: 0
  targetCPC: 0

  __bidCount: 0

  __loopCount: 0
  __loopDelay: 100
  __pacingAdjust: 10 * 1000
  __pacingTime: 0

  # Store handles
  constructor: (@budget, @targetCPC, @$scope) ->
    @startBudget = @budget

    # Set up initial pace using budget and average volume + averageCPC (network)
    networkAvgCPC = 4.5
    networkAvgHourVol = 180000

    _networkAvgSpend10s = (180000 / (60 * 6)) * networkAvgCPC
    targetSpend10s = @budget / (24 * 60 * 6)

    @pace = targetSpend10s / _networkAvgSpend10s

  onUpdate: null

  run: ->
    setInterval =>
      @loop()

      if @onUpdate != null
        @onUpdate @budget, @impressions, @avgBid, @pace

      @__pacingTime += @__loopDelay

    , @__loopDelay

  __slicedGraphData1: false
  __slicedGraphData2: false
  __slicedGraphData3: false

  loop: ->

    icount = 0

    # Simulate random impression volume
    for i in [0...Math.ceil(Math.random() * @$scope.flowControl)]
      @handleImpression()
      icount++

    @$scope.chart.dynamic[0].push
      x: new Date().getTime()
      y: icount

    @$scope.chart.dynamic[2].push
      x: new Date().getTime()
      y: @pace * 10000


    if @$scope.chart.dynamic[0].length > 2 and not @__slicedGraphData1
      @$scope.chart.dynamic[0].splice 0, 1
      @__slicedGraphData1 = true

    if @$scope.chart.dynamic[1].length > 2 and not @__slicedGraphData2
      @$scope.chart.dynamic[1].splice 0, 1
      @__slicedGraphData2 = true

    if @$scope.chart.dynamic[2].length > 2 and not @__slicedGraphData3
      @$scope.chart.dynamic[2].splice 0, 1
      @__slicedGraphData3 = true

    @handleLoop()

  handleImpression: ->
    bid = @calculateBid()

    if @canBid()

      @budget -= bid
      @avgBid = ((@avgBid * @__bidCount) + bid) / (@__bidCount + 1)
      @__bidCount++

      @$scope.chart.dynamic[1].push
        x: new Date().getTime()
        y: bid
    else
      @$scope.chart.dynamic[1].push
        x: new Date().getTime()
        y: 0

    @impressions++
    @__pacingPossibleSpend += bid

  ##
  ## Actual loop logic
  ##

  handleLoop: ->
    @__loopCount++

    # Adjust pacing if needed
    if (@__loopCount * @__loopDelay) % @__pacingAdjust == 0
      @updatePacing()

  ##
  ## Pacing
  ##

  __pacingPossibleSpend: 0

  updatePacing: ->
    @pace = (@startBudget * ((@__pacingTime * 0.008675) / (10 * 60 * 60 * 24))) / @__pacingPossibleSpend

    @__pacingPossibleSpend = 0
    @__pacingTime = 0

  canBid: ->  Math.random() < @pace

  calculateBid: -> @targetCPC * @estimateCTR()

  estimateCTR: -> 0.9
