$(document).ready ->
  addCarets()

addCarets = ->
  to_add = $("[data-with-caret]")
  to_add.prepend('<b class="caret caret-right"></b>')
  to_add.click ->
    $(this).find(".caret").toggleClass("caret-right")

# Expanding/collapsing lists
$(document).ready ->
  $(".list_expansion_toggle").click ->
    list = $(this).closest(".task")
    list.toggleClass("expanded_list")
    list.toggleClass("collapsed_list")
    chevron_type = if list.hasClass("collapsed_list") then "right" else "down"
    glyph = "<span class=\"glyphicon glyphicon-chevron-#{chevron_type}\"></span>"
    $(this).html(glyph)

# Improved "confirm" dialogue box for deleting
$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) 
  false # always stops the action since code runs asynchronously
 
$.rails.confirmed = (link) ->
  link.removeAttr("data-confirm")
  link.trigger("click.rails")

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  html = """
         <div class="modal">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <h4 class="modal-title">Confirm action</h4>
              </div>
              <div class="modal-body">
                <p>#{message}</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" data-dismiss="modal" class="btn btn-primary confirm_delete">Confirm</button>
              </div>
            </div>
          </div>
        </div>
         """
  $(html).modal()
  $("body").css("padding-right", "0px")
  $('.confirm_delete').on 'click', -> $.rails.confirmed(link)