require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    context "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_error_message }

      describe "after visiting another page" do
        before  { click_link "Home" }
        it      { should_not have_error_message }
      end
    end

    context "with valid information" do
      let(:user)  { FactoryGirl.create :user }
      before      { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      context "followed by signout" do
        before  { click_link "Sign out" }
        it      { should have_link("Sign in") }

        context "followed by sign out" do
          before  { delete signout_path }
          it      { should have_link "Sign in"}
        end
      end

      context "when not authenticated" do
        let(:user)  { FactoryGirl.create :unauthenticated_user }
        before      { sign_in user }
        it          { should have_error_message "not activated" }
      end
    end
  end

  describe "authorization" do

    context "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      context "in the Users controller" do

        context "visiting the edit page" do
          before  { visit edit_user_path(user) }
          it      { should have_title('Sign in') }
        end

        context "submitting to the update action" do
          before  { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        context "visiting the user index" do
          before  { visit users_path }
          it      { should_not have_title('All users') }
        end
      end

      context "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end
    end

    context "as wrong user" do
      let(:user) { FactoryGirl.create :user }
      let(:wrong_user) { FactoryGirl.create :user, email: "wrong@example.com" }
      before { sign_in_without_capybara user }

      describe "submitting a GET request to the Users#edit action" do
        before  { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before  { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to signin_path }
      end

      describe "submitting a GET request to the Users#show action" do
        before  { get user_path(wrong_user) }
        specify { expect(response).to redirect_to signin_path }
      end
    end

    context "as non-admin user" do
      let!(:user)       { FactoryGirl.create :user }
      let!(:non_admin)  { FactoryGirl.create :user }

      before { sign_in_without_capybara non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        specify { expect { delete user_path(user) }.not_to change(User, :count) }
      end

      describe "submitting a GET request to the Users#index action" do
        before  { get users_path }
        specify { expect(response.body).not_to match(full_title('All users')) }        
      end
    end

    context "as an admin user" do
      let(:admin) { FactoryGirl.create :admin }
      before { sign_in admin }
      context "visiting the users_path" do
        before  { visit users_path }
        specify { expect(page.current_url).to match(users_path) }
      end
    end

    context "in the Tasks controller" do

      describe "submitting to the create action" do
        before  { post tasks_path }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe "submitting to the destroy action" do
        let(:user)  { FactoryGirl.create :user }
        let(:task) { user.add_task content: "test" }
        before  do 
          task.save!
          delete task_path(task) 
        end

        specify { expect(response).to redirect_to(signin_path) }
      end
    end
  end
end