window.AdefyDashboard.controller "adsCampaigns", ($scope, $http, $route) ->

  # Controls which main element is shown; the campaign listing, or the
  # new campaign wizard
  $scope.mode = "new"

  $(document).ready ->

    wiz = "#fuelux-wizard"
    btnPrev = ".wizard-actions .btn-prev"
    btnNext = ".wizard-actions .btn-next"
    btnFinish = ".wizard-actions .btn-finish"

    wizzy = $(wiz).wizard()
    wizzChange = ->

      step = $(wiz).wizard "selectedItem"

      $(btnNext).removeAttr "disabled"
      $(btnPrev).removeAttr "disabled"

      $(btnNext).show()
      $(btnFinish).hide()

      if step.step == 1
        $(btnPrev).attr "disabled", "disabled"
      else if step.step == 4
        $(btnNext).hide()
        $(btnFinish).show()

    $("body").on "click", btnNext, ->
      $(wiz).wizard "next"
      wizzChange()

    $("body").on "click", btnPrev, ->
      $(wiz).wizard "previous"
      wizzChange()