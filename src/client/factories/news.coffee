angular.module("AdefyApp").factory "News", ($resource) ->
  $resource "/api/v1/news/:id", id: "@id"
