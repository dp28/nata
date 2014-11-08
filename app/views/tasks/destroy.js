$('.delete_task').bind('ajax:success', function() {  
  $(this).closest('li').fadeOut();
}); 

<%- unless @task.root? %>
  var parent_html = $("<%= escape_javascript(render('tasks/single_task', task: @task.parent)) %>");
  $('#task_<%= @task.parent.id %>').replaceWith(parent_html);
<% end %>