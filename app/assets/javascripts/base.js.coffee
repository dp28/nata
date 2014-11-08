$(document).ready ->
  addCarets()

addCarets = ->
  to_add = $('*[data-with-caret="right"')
  to_add.prepend('<b class="caret caret-right"></b>')
  to_add.click ->
    $(this).find(".caret").toggleClass("caret-right")
