window.Adefy.controller "settings", ($scope, $http, $route) ->

  $("#main-list .active").removeClass "active"
  $("#main-list a[href=\"settings\"] li.hoverable").addClass "active"
