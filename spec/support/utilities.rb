include ApplicationHelper
include TasksHelper

def sign_in user 
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def sign_in_without_capybara user
  user.remember
  cookies[:user_id] = user.id
  cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

def xpath_match_class class_attr
  "contains(concat(' ',normalize-space(@class),' '),' #{class_attr} ')"
end

def task_for user_or_task, params={}
  params.reverse_merge! content: "test task #{rand} created at #{Time.now}"
  task = user_or_task.add_task params
  task.save!
  task
end
