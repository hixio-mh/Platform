angular.module("AdefyApp").factory "User", ($resource) ->
  $resource "/api/v1/users"
