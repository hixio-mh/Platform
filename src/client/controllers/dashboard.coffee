window.Adefy.controller "dashboard", ($scope, $http, $route) ->

  $("#main-list .active").removeClass "active"
  $("#main-list a[href=\"dashboard\"] li.hoverable").addClass "active"
