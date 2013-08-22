window.Adefy.controller "campaigns", ($scope, $http, $route) ->

  $("#main-list .active").removeClass "active"
  $("#main-list a[href=\"campaigns\"] li.hoverable").addClass "active"

