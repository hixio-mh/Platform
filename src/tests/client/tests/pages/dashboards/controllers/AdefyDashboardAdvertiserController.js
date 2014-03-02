describe("AdefyDashboardAdvertiserController", function() {
  var scope = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyDashboardAdvertiserController", {
        $scope: scope,
      });
    });
  });

  it("Exposes a hover formatter", function() {
    scope.should.have.property("hoverFormatter");

    hoverText = scope.hoverFormatter({ name: "wazzzaaaa" }, 1, 1);
    expect(hoverText).to.be.a("string");
  });
});
