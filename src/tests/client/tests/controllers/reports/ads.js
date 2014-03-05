describe("AdefyReportsAdsController", function() {
  var scope = null;

  AdServiceMock = {
    getAd: function(cb) {
      if(cb !== undefined) { cb(this.ad); }
    },
    ad: {}
  };

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyReportsAdsController", {
        $scope: scope,
        AdService: AdServiceMock,
        $routeParams: RouteParams
      });
    });

    // Reset ad
    AdServiceMock.ad = {};
  });

  describe('Default render settings', function () {
    it('Provides a default range', function () {
      scope.should.have.property("range");
      scope.range.should.have.property("startDate");
      scope.range.should.have.property("endDate");
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

  describe('Hover formatters', function () {
    it("Exposes a normal number formatter", function() {
      scope.should.have.property("hoverFormatNumber");

      hoverText = scope.hoverFormatNumber({ name: "wazzzaaaa" }, 1, 1);
      expect(hoverText).to.be.a("string");
    });

    it("Exposes a number formatter just for expenses", function() {
      scope.should.have.property("hoverFormatSpent");

      hoverText = scope.hoverFormatSpent({ name: "wazzzaaaa" }, 1, 1);
      expect(hoverText).to.be.a("string");
    });
  });
});
