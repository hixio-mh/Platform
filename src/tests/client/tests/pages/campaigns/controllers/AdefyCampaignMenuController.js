describe("AdefyCampaignMenuController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyCampaignMenuController", { $scope: scope });
    });
  });

  describe('Activation toggle method', function () {
    it('Exists', function () {
      scope.should.have.property("activeToggled");
    });

    it('POSTS to .../activate when campaign is inactive', function () {
      scope.campaign = {
        id: 123,
        active: false
      };

      httpBackend.expectPOST("/api/v1/campaigns/123/activate").respond(200);
      scope.activeToggled();
      httpBackend.flush();
    });

    it('POSTS to .../deactivate when campaign is active', function () {
      scope.campaign = {
        id: 123,
        active: true
      };

      httpBackend.expectPOST("/api/v1/campaigns/123/deactivate").respond(200);
      scope.activeToggled();
      httpBackend.flush();
    });
  });
});
