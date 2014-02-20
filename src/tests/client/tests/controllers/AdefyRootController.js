describe("AdefyRootController", function() {
  var scope = null;
  var rootScope = null;

  beforeEach(function() { angular.mock.module("AdefyApp"); });
  beforeEach(function() {
    angular.mock.inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      rootScope = $rootScope.$new();

      $controller("AdefyRootController", {
        $scope: scope,
        $rootScope: rootScope
      });
    });
  });

  it("Should start out with a null notification", function() {
    expect(rootScope.notification).to.equal(null);
  });

  it("Should allow one to set a notification", function() {
    scope.should.have.property("setNotification");
    scope.setNotification("wazzzaaaaa", "error");

    expect(rootScope.notification.type).to.equal("error");
    expect(rootScope.notification.text).to.equal("wazzzaaaaa");
  });

  it("Should allow one to clear the notification", function() {
    scope.should.have.property("clearNotification");
    scope.clearNotification();

    expect(rootScope.notification).to.equal(null);
  });
});
