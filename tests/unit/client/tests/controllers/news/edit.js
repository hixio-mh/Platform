describe("AdefyNewsEditController", function() {
  var scope = null;
  var httpBackend = null;
  var locationMock = { url: function() {} };
  var NewsServiceMock = {
    getArticle: function(cb) {
      if(cb !== undefined) { cb(this.article); }
    },
    article: {},
    updateCachedArticle: function() {}
  };

  beforeEach(function() {
    angular.mock.module("AdefyApp");

    angular.mock.inject(function($rootScope, $controller, $injector) {
      scope = $rootScope.$new();
      httpBackend = $injector.get("$httpBackend");

      $controller("AdefyNewsEditController", {
        $scope: scope,
        NewsService: NewsServiceMock,
        $location: locationMock
      });
    });

    // Reset article
    NewsServiceMock.article = {};
  });

  describe('Submit method', function () {
    it('Exists', function () {
      scope.should.have.property("submit");
    });
    
    it('Updates scope article model', function (done) {
      scope.article = {
        id: 123,
        $save: function() { done(); return { then: function() {} }; }
      };

      scope.submit();
    });
  });

  describe('Destroy method', function () {
    it('Exists', function () {
      scope.should.have.property("destroy");
    });

    it('Calls $delete() on the article model', function (done) {
      scope.article = {
        name: "abc",
        $delete: function() { done(); return { then: function() {} }; }
      };

      window._confirm = window.confirm;
      window.confirm = function() { return true; }

      scope.destroy();
      window.confirm = window._confirm;
    });
  });

  describe('Cancel method', function () {
    it('Exists', function () {
      scope.should.have.property("cancel");
    });

    it('Redirects to /news', function (done) {
      scope.article.id = 123;

      locationMock.url = function(path) {
        expect(path).to.equal("/news/123");
        done();
      }

      scope.cancel();
    });
  });
});
