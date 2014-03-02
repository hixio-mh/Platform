describe("AdefyAppsDetailsController", function() {
  var scope = null;

  AppServiceMock = {
    getApp: function(cb) {
      if(cb !== undefined) { cb(this.app); }
    },
    app: {}
  };

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyAppsDetailsController", {
        $scope: scope,
        AppService: AppServiceMock,
        $routeParams: RouteParams
      });
    });

    // Reset app
    AppServiceMock.app = {};
  });

  afterEach(function() {
    window.showTutorial = undefined;
  });

  it("Registers a method to show the tutorial", function(done) {
    window.should.have.property("showTutorial");

    window.guiders._show = window.guiders.show;
    window.guiders.show = function(target) {
      if(target == "appDetailsGuider1") {
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

  it("Exposes essential graph info", function() {
    scope.should.have.property("graphInterval");
    scope.should.have.property("graphSum");
    scope.should.have.property("intervalOptions");
  });

  it("Exposes valid interval options", function() {
    expect(scope.intervalOptions.length).to.be.above(0);

    for(var i = 0; i < scope.intervalOptions.length; i++) {
      scope.intervalOptions[i].should.have.property("val");
      scope.intervalOptions[i].should.have.property("name");
    }
  });
});
