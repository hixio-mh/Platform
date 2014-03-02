describe("AdefyAppsIndexController", function() {
  var scope = null;
  var AppServiceMock = null;
  var AppModelMock = null;
  var httpBackend = null;

  beforeEach(function() {
    AppServiceMock = { getAllApps: function() {} };
    AppModelMock = function() {};

    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyAppsIndexController", {
        $scope: scope,
        AppService: AppServiceMock,
        App: AppModelMock
      });
    });

    // Reset app
    AppServiceMock.app = {};
  });

  afterEach(function() {
    window.showTutorial = undefined;
  });

  it('Provides a sort settings object on the scope', function () {
    scope.should.have.property("sort");
    scope.sort.should.have.property("metric");
    scope.sort.should.have.property("direction");
  });

  it("Registers a method to show the tutorial", function(done) {
    window.should.have.property("showTutorial");

    window.guiders._show = window.guiders.show;
    window.guiders.show = function(target) {
      if(target == "appsGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
  });
});
