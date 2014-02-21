describe("AdefyAccountSettingsController", function() {
  var scope = null;
  var rootScope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      rootScope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      var user = {
        currentPass: "",
        newPass: ""
      };

      UserServiceMock = {
        getUser: function(cb) { cb(user); },
        clearCache: function() {}
      };

      $controller("AdefyAccountSettingsController", {
        $scope: scope,
        $routeParams: {},
        UserService: UserServiceMock
      });
    });
  });

  it("Fetches country list on load", function() {
    httpBackend.expectGET("/api/v1/filters/countries").respond(200, []);
    httpBackend.flush();
  });

  it("Provides a save method that saves the scope user model", function(done) {
    scope.should.have.property("save");
    scope.me.$save = function() {
      done();
      return { then: function() {} };
    }
    scope.save();
  });
});
