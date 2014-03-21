describe("AdefyAccountFundsController", function() {
  var scope = null;
  var httpBackend = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      UserServiceMock = {
        user: {
          tutorials: {
            funds: false
          },
          withdrawal: {
            interval: 0,
            min: 0,
            email: ""
          }
        },
        getUser: function(cb) { cb(this.user); },
      };

      $controller("AdefyAccountFundsController", {
        $scope: scope,
        $routeParams: {},
        UserService: UserServiceMock
      });
    });
  });
  afterEach(function() {
    window.showTutorial = undefined;
  });

  it("Registers a method to show the tutorial", function(done) {
    window.should.have.property("showTutorial");

    window.guiders._show = window.guiders.show;
    window.guiders.show = function(target) {
      if(target == "fundsGuider1") {
        done();
      }
    };
    window.showTutorial();
    window.guiders.show = window.guiders._show;
  });

  // TODO: Implement withdrawls and test the method
  it("Provides a withdrawal settings save method", function() {
    scope.should.have.property("saveWithdrawalSettings");
  });

  it("Should fetch user transaction list on load", function() {
    httpBackend.expectGET("/api/v1/user/transactions").respond(200, []);
  });

  it("Provides a deposit method that POSTs /api/v1/user/deposit/:amount", function() {
    scope.should.have.property("deposit");
    scope.should.have.property("paymentInfo");

    scope.paymentInfo.amount = 123;

    httpBackend.expectGET("/api/v1/user/transactions").respond(200, []);

    // Respond with error to prevent redirect
    httpBackend.expectPOST("/api/v1/user/deposit/123").respond(403);

    scope.deposit();
    httpBackend.flush();
  });
});
