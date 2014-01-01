# adapted from https://github.com/nazar/parlmnt/blob/master/app/assets/javascripts/app/directives/form_modal.js
window.AdefyDashboard.directive "formModal", ["$compile", "$http", ($compile, $http) ->
  scope:
    formObject: "="
    formErrors: "="
    title: "@"
    template: "@"
    okButtonText: "@"
    formSubmit: "&"
    formClear: "&"

  compile: (element, cAtts) ->
    template = undefined
    $element = undefined
    loader = undefined
    loader = $http.get("/views/dashboard/modal").success (data) ->
      template = data

    (scope, element, lAtts) ->
      scope.submit = ->
        result = scope.formSubmit()
        if angular.isObject(result) and result.success
          result.success ->
            scope.close()


        else scope.close() unless result is false

      scope.close = ->
        $element.remove()
        scope.formClear()

      element.on "click", (e) ->
        e.preventDefault()
        $element = $compile(template) scope
        $("body").prepend $element
]
