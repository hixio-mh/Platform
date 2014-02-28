describe("AdefyAppsEditController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyAppsEditController", { $scope: scope });
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

  it('Fetches categories on init', function () {
    httpBackend.expectGET("/api/v1/filters/categories").respond(200, []);
    httpBackend.flush();
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('Updates scope ad model', function (done) {
      scope.app = {
        id: 123,
        $save: function() { done(); }
      };

      scope.submit();
    });
  });

  describe('Delete method', function () {
    it('Exists', function () {
      scope.should.have.property("delete");
    });

    it('Does nothing if provided app name does not match', function (done) {
      var modified = false;

      scope.app = {
        name: "abc"
        $delete: function() {
          modified = true;
          finish();
        }
      };

      var finish = function() {
        expect(modified).to.be.false;
        done();
      }

      // Modified should not be modified by the app $delete() method
      scope.form.name = 123;
      scope.delete();
      finish();
    });

    it('Calls $delete() on the app model if the provided name matches', function (done) {
      scope.app = {
        name: "abc"
        $delete: function() { done(); }
      };

      scope.form.name = "abc";
      scope.delete();
    });
  });
});
