describe("AdefyAdNativeCreativeController", function() {
  var scope = null;
  var AdServiceMock = {};

  RouteParams = {};

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    AdServiceMock = {
      getAd: function(cb) {
        if(cb !== undefined) { cb(this.ad); }
      },
      ad: {}
    };

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyAdNativeCreativeController", {
        $scope: scope,
        AdService: AdServiceMock,
        $routeParams: RouteParams
      });
    });

    // Reset ad
    AdServiceMock.ad = {};
  });

  it("Provides a save method for the ad", function(done){
    scope.should.have.property("save");
    scope.ad = {
      "native": {}
    };

    AdServiceMock.save = function(ad, cb) {
      done();
    };

    scope.save();
  });
});
