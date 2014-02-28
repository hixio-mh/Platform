describe("AdefyAppsCreateController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyAppsCreateController", { $scope: scope });
    });
  });

  it('Exposes a category listing on the scope', function () {
    scope.should.have.property("categories");

    for(var i = 0; i < scope.categories.length; i++) {
      expect(scope[i]).to.be.a("string");
    }
  });

  it('Exposes a pricing model list on the scope, with specific values', function () {
    scope.should.have.property("pricingModels");

    var found = 0;
    for(var i = 0; i < scope.pricingModels.length; i++) {
      if(scope.pricingModels[i] == "Any") { found++; }
      if(scope.pricingModels[i] == "CPC") { found++; }
      if(scope.pricingModels[i] == "CPM") { found++; }
    }

    expect(pricingModels.length).to.equal(3);
    expect(found).to.equal(3);
  });

  it('Provides a default app on the scope', function () {
    scope.should.have.property("app");
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('POSTS to /api/v1/publisher', function () {

      // Respond with an error to prevent redirect
      httpBackend.expectPOST("/api/v1/publisher").respond(403);

      scope.submit();
      httpBackend.flush();
    });
  });
});
