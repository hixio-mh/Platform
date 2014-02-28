describe("AdefyAppsMenuController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyAppsMenuController", { $scope: scope });
    });
  });

  describe('Approval request method', function () {
    it("Exists", function(done) {
      scope.should.have.property("requestApproval");
    });

    it("Works and updates scope publisher status", function() {
      httpBackend.expectPOST("/api/v1/publishers/123/approve").respond(200);

      scope.app = { id: 123 };
      scope.requestApproval();

      httpBackend.flush();
    });
  });

  describe('Activation toggle method', function () {
    it('Exists', function () {
      scope.should.have.property("activeToggled");
    });

    it('POSTS to .../activate when app is inactive', function () {
      scope.app = {
        id: 123
        active: false
      };

      httpBackend.expectPOST("/api/v1/publishers/123/activate").respond(200);
      scope.activeToggled();
      httpBackend.flush();
    });

    it('POSTS to .../deactivate when app is active', function () {
      scope.app = {
        id: 123
        active: true
      };

      httpBackend.expectPOST("/api/v1/publishers/123/activate").respond(200);
      scope.activeToggled();
      httpBackend.flush();
    });
  });
});
