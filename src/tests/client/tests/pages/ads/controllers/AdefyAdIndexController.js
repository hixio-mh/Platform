describe("AdefyAdIndexController", function() {
  var scope = null;
  var AdServiceMock = null;
  var AdModelMock = null

  beforeEach(function() {
    AdServiceMock = { getAllAds: function() {} };
    AdModelMock = function() {};

    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyAdIndexController", {
        $scope: scope,
        AdService: AdServiceMock,
        Ad: AdModelMock
      });
    });

    // Reset ad
    AdServiceMock.ad = {};
  });

  afterEach(function() {
    window.showTutorial = undefined;
  });

  it("Registers a method to show the tutorial", function(done) {
    window.should.have.property("showTutorial");

    window.guiders._show = window.guiders.show;
    window.guiders.show = function(target) {
      if(target == "adsGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
  });

  it("Initializes with an ad form object", function() {
    scope.should.have.property("adForm");
  });

  it("Provides a new ad creation method", function(done) {
    AdModelMock.prototype.$save = function() {
      done();
      return { then: function() {} };
    }

    scope.should.have.property("create");
    scope.create();
  });
});
