var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('localytics.directives', []);

angular.module('localytics.directives').directive('chosen', function() {
  var CHOSEN_OPTION_WHITELIST, NG_OPTIONS_REGEXP, chosen, isEmpty, snakeCase;
  NG_OPTIONS_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?(?:\s+group\s+by\s+(.*))?\s+for\s+(?:([\$\w][\$\w]*)|(?:\(\s*([\$\w][\$\w]*)\s*,\s*([\$\w][\$\w]*)\s*\)))\s+in\s+(.*?)(?:\s+track\s+by\s+(.*?))?$/;
  CHOSEN_OPTION_WHITELIST = ['noResultsText', 'allowSingleDeselect', 'disableSearchThreshold', 'disableSearch', 'enableSplitWordSearch', 'inheritSelectClasses', 'maxSelectedOptions', 'placeholderTextMultiple', 'placeholderTextSingle', 'searchContains', 'singleBackstrokeDelete', 'displayDisabledOptions', 'displaySelectedOptions', 'width'];
  snakeCase = function(input) {
    return input.replace(/[A-Z]/g, function($1) {
      return "_" + ($1.toLowerCase());
    });
  };
  isEmpty = function(value) {
    var key;
    if (angular.isArray(value)) {
      return value.length === 0;
    } else if (angular.isObject(value)) {
      for (key in value) {
        if (value.hasOwnProperty(key)) {
          return false;
        }
      }
    }
    return true;
  };
  return chosen = {
    restrict: 'A',
    require: '?ngModel',
    terminal: true,
    link: function(scope, element, attr, ctrl) {
      var disableWithMessage, empty, initOrUpdate, initialized, match, options, origRender, removeEmptyMessage, startLoading, stopLoading, valuesExpr, viewWatch;
      element.addClass('localytics-chosen');
      options = scope.$eval(attr.chosen) || {};
      angular.forEach(attr, function(value, key) {
        if (__indexOf.call(CHOSEN_OPTION_WHITELIST, key) >= 0) {
          return options[snakeCase(key)] = scope.$eval(value);
        }
      });
      startLoading = function() {
        return element.addClass('loading').attr('disabled', true).trigger('chosen:updated');
      };
      stopLoading = function() {
        return element.removeClass('loading').attr('disabled', false).trigger('chosen:updated');
      };
      initialized = false;
      empty = false;
      initOrUpdate = function() {
        if (initialized) {
          return element.trigger('chosen:updated');
        } else {
          element.chosen(options);
          return initialized = true;
        }
      };
      removeEmptyMessage = function() {
        empty = false;
        return element.find('option.empty').remove();
      };
      disableWithMessage = function(message) {
        empty = true;
        return element.empty().append("<option selected class=\"empty\">" + message + "</option>").attr('disabled', true).trigger('chosen:updated');
      };
      if (ctrl) {
        origRender = ctrl.$render;
        ctrl.$render = function() {
          origRender();
          return initOrUpdate();
        };
        if (attr.multiple) {
          viewWatch = function() {
            return ctrl.$viewValue;
          };
          scope.$watch(viewWatch, ctrl.$render, true);
        }
      } else {
        initOrUpdate();
      }
      attr.$observe('disabled', function(value) {
        return element.trigger('chosen:updated');
      });
      if (attr.ngOptions) {
        match = attr.ngOptions.match(NG_OPTIONS_REGEXP);
        valuesExpr = match[7];
        if (angular.isUndefined(scope.$eval(valuesExpr))) {
          startLoading();
        }
        return scope.$watchCollection(valuesExpr, function(newVal, oldVal) {
          if (newVal !== oldVal) {
            if (empty) {
              removeEmptyMessage();
            }
            stopLoading();
            if (isEmpty(newVal)) {
              return disableWithMessage(options.no_results_text || 'No values available');
            }
          }
        });
      }
    }
  };
});