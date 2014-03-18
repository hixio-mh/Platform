angular.module("AdefyApp").directive "campaignIcon", [->

  template: """
  <div ng-switch="iconStatus">
    <div class="icon noimage" ng-switch-when="none"></div>

    <img class="icon" ng-switch-when="one" ng-src="{{ campaign.ads[0].getIcon() }}" />

    <ul class="icon list" ng-switch-when="multiple">
      <li ng-repeat="(i, ad) in campaign.ads">
        <img ng-src="{{ ad.getIcon() }}" />
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
]
