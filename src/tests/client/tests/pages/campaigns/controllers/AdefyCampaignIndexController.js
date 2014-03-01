describe("AdefyCampaignIndexController", function() {
  var scope = null;
  var CampaigServiceMock = null;
  var CampaigModelMock = null;
  var httpBackend = null;

  beforeEach(function() {
    CampaigServiceMock = { getAllCampaigs: function() {} };
    CampaigModelMock = function() {};

    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyCampaignIndexController", {
        $scope: scope,
        CampaigService: CampaigServiceMock,
        CampaigModel: CampaigModelMock
      });
    });

    // Reset campaign
    CampaigServiceMock.campaign = {};
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
      if(target == "campaignsGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
  });
});
