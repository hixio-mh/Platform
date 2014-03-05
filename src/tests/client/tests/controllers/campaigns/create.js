describe("AdefyCampaignCreateController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyCampaignCreateController", { $scope: scope });
    });
  });

  it('Exposes a category listing on the scope', function () {
    scope.should.have.property("categories");

    for(var i = 0; i < scope.categories.length; i++) {
      expect(scope.categories[i]).to.be.a("string");
    }
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
    scope.campaign.should.have.property("category");
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('POSTS to /api/v1/campaigns', function () {
      scope.setNotification = function() {};

      // Respond with an error to prevent redirect
      httpBackend.expectGET("/api/v1/filters/categories").respond(200, []);
      httpBackend.expectPOST("/api/v1/campaigns").respond(403);

      scope.submit();
      httpBackend.flush();
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
