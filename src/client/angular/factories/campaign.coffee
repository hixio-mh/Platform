angular.module("AdefyApp").factory "Campaign", ($resource) ->
  $resource "/api/v1/campaigns/:id", id: "@id"
