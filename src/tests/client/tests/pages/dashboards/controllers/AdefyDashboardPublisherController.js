describe("AdefyDashboardPublisherController", function() {
  var scope = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyDashboardPublisherController", {
        $scope: scope,
      });
    });
  });

  afterEach(function() {
    window.showTutorial = undefined;
  });

  it("Registers a method to show the tutorial", function(done) {
    window.should.have.property("showTutorial");

    window.guiders._show = window.guiders.show;
    window.guiders.show = function(target) {
      if(target == "dashboardGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
  });

  it("Exposes a hover formatter", function() {
    scope.should.have.property("hoverFormatter");

    hoverText = scope.hoverFormatter({ name: "wazzzaaaa" }, 1, 1);
    expect(hoverText).to.be.a("string");
  });
});
