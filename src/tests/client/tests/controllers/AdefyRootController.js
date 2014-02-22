describe("AdefyRootController", function() {
  var scope = null;
  var rootScope = null;

  afterEach(function() {
    window.Intercom = undefined;
    window.showTutorial = undefined;
  });

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      rootScope = $rootScope.$new();

      UserServiceMock = {
        enableTutorials: function(cb) { cb(); },
        getUser: function(cb) { cb({}); }
      };

      $controller("AdefyRootController", {
        $scope: scope,
        $rootScope: rootScope,
        UserService: UserServiceMock
      });
    });
  });

  it("Should start out with a null notification", function() {
    expect(rootScope.notification).to.equal(null);
  });

  it("Should allow one to set a notification", function() {
    scope.should.have.property("setNotification");
    scope.setNotification("wazzzaaaaa", "error");

    expect(rootScope.notification.type).to.equal("error");
    expect(rootScope.notification.text).to.equal("wazzzaaaaa");
  });

  it("Should allow one to clear the notification", function() {
    scope.should.have.property("clearNotification");
    scope.clearNotification();

    expect(rootScope.notification).to.equal(null);
  });

  it("Exposes method to show the intercom dialog", function(done) {
    scope.should.have.property("showIntercom");

    window.Intercom = function(msg) {
      expect(msg).to.equal("show");
      done();
    }

    scope.showIntercom();
  });

  it("Exposes a method to show the tutorial", function(done) {
    scope.should.have.property("showTutorial")

    window.showTutorial = function(){ done(); }
    scope.showTutorial();
  });

  it("Should clear notification on location change", function() {
    scope.setNotification("wazzzaaaaa", "error");
    expect(rootScope.notification.type).to.equal("error");
    expect(rootScope.notification.text).to.equal("wazzzaaaaa");

    rootScope.$broadcast("$locationChangeStart");
    expect(rootScope.notification).to.equal(null);
  });
});
