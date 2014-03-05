describe("AdefyNewsCreateController", function() {
  var scope = null;
  var httpBackend = null;
  var locationMock = { path: function() {} };

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyNewsCreateController", {
        $scope: scope,
        $location: locationMock
      });
    });
  });

  it('Provides a default article on the scope', function () {
    scope.should.have.property("article");
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('POSTS to /api/v1/news', function () {
      scope.setNotification = function() {};

      // Respond with an error to prevent redirect
      httpBackend.expectPOST("/api/v1/news").respond(403);

      scope.submit();
      httpBackend.flush();
    });
  });

  describe('Cancel method', function () {
    it('Exists', function () {
      scope.should.have.property("cancel");
    });

    it('Redirects to /news', function (done) {
      locationMock.path = function(path) {
        expect(path).to.equal("/news");
        done();
      }

      scope.cancel();
    });
  });
});
