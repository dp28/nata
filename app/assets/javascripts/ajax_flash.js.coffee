setFlashTimeout = ->
  $(".alert").delay(5000).fadeOut(900)

show_ajax_message = (message, type) ->
  $("#flash_message").fadeIn(300, ->
    $(this).html("<div class=\"alert alert-#{type}\">#{message}</div>")
  )
  setFlashTimeout()

$(document).ajaxComplete((event, request) ->
  message = request.getResponseHeader('X-Message')
  if message
    type    = request.getResponseHeader('X-Message-Type')
    show_ajax_message(message, type)
)

$(document).ready -> setFlashTimeout()