describe("AdefyCampaignEditController", function() {
  var scope = null;
  var httpBackend = null;
  var CampaignServiceMock = {
    getCampaign: function(cb) {
      if(cb !== undefined) { cb(this.campaign); }
    },
    campaign: {},
    updateCachedCampaign: function() {}
  };

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyCampaignEditController", {
        $scope: scope,
        CampaignService: CampaignServiceMock
      });
    });

    // Reset campaign
    CampaignServiceMock.campaign = {};
  });

  it('Exposes an object with minimum values for inputes', function () {
    scope.should.have.property("min");
    scope.min.should.have.property("budget");
    scope.min.should.have.property("cpm");
    scope.min.should.have.property("cpc");
    scope.min.should.have.property("ads");
  });

  it('Exposes a pricing option list on the scope, with specific values', function () {
    scope.should.have.property("pricingOptions");

    var found = 0;
    for(var i = 0; i < scope.pricingOptions.length; i++) {
      if(scope.pricingOptions[i] == "CPC") { found++; }
      if(scope.pricingOptions[i] == "CPM") { found++; }
    }

    expect(scope.pricingOptions.length).to.equal(2);
    expect(found).to.equal(2);
  });

  it('Exposes a bid system option list on the scope, with specific values', function () {
    scope.should.have.property("bidSysOptions");

    var found = 0;
    for(var i = 0; i < scope.bidSysOptions.length; i++) {
      if(scope.bidSysOptions[i] == "Automatic") { found++; }
      if(scope.bidSysOptions[i] == "Manual") { found++; }
    }

    expect(scope.bidSysOptions.length).to.equal(2);
    expect(found).to.equal(2);
  });

  it('Provides a default campaign on the scope', function () {
    scope.should.have.property("campaign");
    scope.campaign.should.have.property("pricing");
    scope.campaign.should.have.property("bidSystem");
    scope.campaign.should.have.property("networks");
    scope.campaign.should.have.property("scheduling");
    scope.campaign.should.have.property("devices");
    scope.campaign.should.have.property("countries");
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('Updates scope campaign model', function (done) {
      scope.campaign = {
        id: 123,
        $save: function() { done(); return { then: function() {} }; }
      };

      scope.devicesInclude = "";
      scope.devicesExclude = "";
      scope.countriesInclude = "";
      scope.countriesExclude = "";

      scope.submit();
    });
  });

  describe('Delete method', function () {
    it('Exists', function () {
      scope.should.have.property("delete");
    });

    it('Does nothing if provided campaign name does not match', function (done) {
      var modified = false;

      scope.campaign = {
        name: "abc",
        $delete: function() {
          modified = true;
          finish();
        }
      };

      var finish = function() {
        expect(modified).to.be.false;
        done();
      }

      // Modified should not be modified by the campaign $delete() method
      scope.form.name = 123;
      scope.delete();
      finish();
    });

    it('Calls $delete() on the campaign model if the provided name matches', function (done) {
      scope.campaign = {
        name: "abc",
        $delete: function() { done(); return { then: function() {} }; }
      };

      scope.form.name = "abc";
      scope.delete();
    });
  });

  describe('Project spend method', function () {
    it('Exists', function () {
      scope.should.have.property("projectSpend");
    });

    it('Returns total account balance if no end date is specified', function () {
      scope.$parent.me = { adFunds: 123123 };
      expect(scope.projectSpend()).to.equal(123123);
    });

    it('Returns dailyBudget * 2 if start & end dates are 2 days apart', function () {
      scope.$parent.me = { adFunds: 100000 };
      scope.campaign.endDate = new Date().getTime() - (1000 * 60 * 60 * 24 * 4);
      scope.campaign.startDate = new Date().getTime() - (1000 * 60 * 60 * 24 * 2);
      scope.campaign.dailyBudget = 123;

      expect(Number(scope.projectSpend())).to.equal(-246);
    });

    it('Returns dailyBudget * 2 if end date is in 2 days and no start is specified', function () {
      scope.$parent.me = { adFunds: 100000 };
      scope.campaign.endDate = new Date().getTime() - (1000 * 60 * 60 * 24 * 2);
      scope.campaign.dailyBudget = 123;

      expect(Number(scope.projectSpend())).to.equal(-246);
    });
  });
});
