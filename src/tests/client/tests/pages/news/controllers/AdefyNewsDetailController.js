describe("AdefyNewsDetailController", function() {
  var scope = null;

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();

      $controller("AdefyNewsDetailController", { $scope: scope, });
    });
  });

  it('Provides a default article on the scope', function () {
    scope.should.have.property("article");
  });
});
