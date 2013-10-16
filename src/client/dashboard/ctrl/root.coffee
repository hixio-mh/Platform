window.AdefyDashboard.controller "rootController", ($scope, $http, $route) ->

  $http.get("/logic/user/self").success (me) ->

    me.acText = "$#{me.advertiserCredit.toFixed 2} Advertising Credit"
    me.pbText = "$#{me.publisherBalance.toFixed 2} Publisher Balance"

    $scope.me = me