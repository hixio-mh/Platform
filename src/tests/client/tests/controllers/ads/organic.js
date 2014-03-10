describe("AdefyAdOrganicCreativeController", function() {
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

      $controller("AdefyAdOrganicCreativeController", {
        $scope: scope,
        AdService: AdServiceMock,
        $routeParams: RouteParams
      });
    });

    // Reset ad
    AdServiceMock.ad = {};
  });

  it("Initializes with null creative data", function() {
    expect(scope.creativeLoaded).to.equal(false);
    expect(scope.creativeData).to.equal(null);
  });

  it("Provides a method to cycle the creative directive with a url", function() {
    scope.should.have.property("commitURL");
    scope.ad = { organic: { googleStoreURL: "www.google.com" } };
    scope.renderURL = null;

    scope.cycle = true;
    scope.commitURL();

    expect(scope.renderURL).to.equal("www.google.com");
    expect(scope.cycle).to.equal(false);
  });

  it("Provides an invalid URL handler", function() {
    expect(scope.isInvalidURL).to.not.equal(true);
    scope.invalidURL();
    expect(scope.isInvalidURL).to.equal(true);
  });

  it("Provides a load completion handler", function() {
    expect(scope.creativeData).to.equal(null);
    scope.doneLoading(123);
    expect(scope.creativeData).to.equal(123);
  });

  it("Exposes a getter for the saved creative data by URL", function() {
    scope.should.have.property("getSavedData");
    scope.ad = {
      organic: {
        googleStoreURL: "waaazzzzaaaa",
        data: 123
      }
    };

    validData = scope.getSavedData("waaazzzzaaaa");
    invalidData = scope.getSavedData("sup");

    expect(validData).to.equal(123);
    expect(invalidData).to.equal(null);
  });

  it("Provides a save method for the ad", function(done){
    scope.should.have.property("save");
    scope.ad = {
      organic: {
        data: 123
      }
    };

    AdServiceMock.save = function(ad, cb) {
      done();
    };

    scope.save();
  });
});
