describe("AdefyAdMenuController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyAdMenuController", { $scope: scope });
    });
  });

  describe('Approval request method', function () {
    it("Exists", function() {
      scope.should.have.property("requestApproval");
    });

    it("Works and updates scope ad status", function() {
      httpBackend.expectPOST("/api/v1/ads/123/approve").respond(200);

      scope.ad = { status: 0, id: 123 };
      scope.setNotification = function() {};
      scope.requestApproval();

      httpBackend.flush();
      expect(scope.ad.status).to.equal(2);
    });
  });

  describe('Delete method', function () {
    it('Exists', function () {
      scope.should.have.property("delete");
    });

    it('Does nothing if provided ad name is incorrect', function () {
      scope.form = { name: "abc" };
      scope.ad = {
        name: "123",
        $delete: function() { return { then: function() {} }; }
      };

      scope.delete();
    });

    it('Calls $delete on the scope ad if name is correct', function (done) {
      scope.form = { name: "abc" };
      scope.ad = {
        name: "abc",
        $delete: function() { done(); return { then: function() {} }; }
      };

      scope.delete();
    });
  });
});
