angular.module("AdefyApp").factory "App", ($resource) ->
  $resource "/api/v1/publishers/:id", id: "@id"
