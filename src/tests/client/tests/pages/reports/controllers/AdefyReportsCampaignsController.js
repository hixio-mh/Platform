describe("AdefyReportsCampaignsController", function() {
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

      $controller("AdefyReportsCampaignsController", {
        $scope: scope,
        AdService: AdServiceMock,
        $routeParams: RouteParams
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
      if(target == "reportsGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
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
