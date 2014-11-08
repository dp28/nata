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
