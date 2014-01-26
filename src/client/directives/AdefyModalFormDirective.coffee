# adapted from https://github.com/nazar/parlmnt/blob/master/app/assets/javascripts/app/directives/form_modal.js
window.AdefyDashboard.directive "formModal", ["$compile", "$http", ($compile, $http) ->
  scope:
    formObject: "="
    formErrors: "="
    title: "@"
    template: "@"
    okButtonText: "@"
    deleteButtonText: "@"
    formSubmitFunc: "@"
    formDeleteFunc: "@"
    formSubmit: "&"
    formClear: "&"
    formDelete: "&"
    close: "="

  compile: (element, cAtts) ->
    template = undefined
    $element = undefined
    loader = undefined
    loader = $http.get("/views/dashboard/modal").success (data) ->
      template = data

    (scope, element, lAtts) ->

      handleSubmission = (result) ->
        if angular.isObject result
          if result.success
            result.success ->
              scope.close()

            result.error (error) ->
              if error.error then scope.formObject.errorMessage = error.error
              else scope.formObject.errorMessage = error
          else if result.error
            scope.formObject.errorMessage = result.error

        else scope.close() unless result is false

      scope.submit = ->
        if scope.formSubmitFunc
          handleSubmission scope.$parent[scope.formSubmitFunc] scope.formObject
        else
          handleSubmission scope.formSubmit()

      scope.delete = ->
        if scope.formDeleteFunc
          handleSubmission scope.$parent[scope.formDeleteFunc] scope.formObject
        else
          handleSubmission scope.formDelete()

      scope.close = ->
        $element.remove()
        scope.formClear()

      scope.enterSubmit = (e) ->
        if e.which == 10 or e.which == 13 then scope.submit()

      element.on "click", (e) ->
        e.preventDefault()
        $element = $compile(template) scope
        $("body").prepend $element
]
