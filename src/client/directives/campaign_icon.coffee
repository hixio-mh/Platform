angular.module("AdefyApp").directive "campaignIcon", [->

  template: """
  <div ng-switch="iconStatus">
    <div class="icon noimage" ng-switch-when="none"></div>

    <img class="icon" ng-switch-when="one" ng-src="{{ getAdIcon(0) }}" />

    <ul class="icon list" ng-switch-when="multiple">
      <li ng-repeat="i, ad in campaign.ads">
        <img ng-src="{{ getAdIcon(i) }}" />
      <li>
    </ul>
  </div>
  """
  restrict: "AE"
  scope:
    campaign: "="

  link: (scope, element, attrs) ->
    scope.iconStatus = "none"

    if scope.campaign.ads.length == 1
      scope.iconStatus = "one"
    else if scope.campaign.ads.length > 1
      scope.iconStatus = "multiple"

    console.log scope.campaign.ads
    console.log scope.iconStatus

    scope.getAdIcon = (index) ->
      ad = scope.campaign.ads[index]

      if ad.organic.jsSource.image
        ad.organic.jsSource.image
      else if ad.native.iconURL
        ad.native.iconURL
      else if ad.organic.notification.icon
        ad.organic.notification.icon
      else
        null
]
