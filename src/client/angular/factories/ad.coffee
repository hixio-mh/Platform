angular.module("AdefyApp").factory "Ad", ($resource) ->
  $resource "/api/v1/ads/:id", id: "@id"
