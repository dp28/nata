require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_content 'Sign up'  }
    it { should have_title full_title('Sign up')   }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    context "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count) 
      end 

      context "after submission" do
        before { click_button submit }

        it { should have_title 'Sign up'  }
        it { should have_content 'error'  }
      end
    end

    context "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by 1 
      end

      it "should send an email" do
        expect { click_button submit }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
      
      context "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by email: 'user@example.com' }

        it { should have_link 'Sign in'  }
        it { should have_selector 'div.alert.alert-info', text: 'activate'  }
        specify { expect(user.activation_digest).not_to be nil }

        context "signing in after activation" do
          before do
            user.update_attributes activated: true, password: "foobar"
            user.save!
            visit signin_path
            fill_in "Email",        with: "user@example.com"
            fill_in "Password",     with: "foobar"
            click_button "Sign in"
          end

          it { should have_link "Sign out" }
        end
      end
    end
  end

  describe "index" do

    context "when signed in as a non-admin user" do
      before do
        sign_in FactoryGirl.create(:user)
        visit users_path
      end

      it { should_not have_title('All users') }
      it { should_not have_content('All users') }
      it { should_not have_link('delete') }
    end

    context "when signed in as an admin user" do
      let(:admin) { FactoryGirl.create :admin }
      before do
        sign_in admin
        visit users_path
      end

      it { should have_title('All users') }
      it { should have_content('All users') }
      
      describe "pagination" do

        before(:all) { 30.times { FactoryGirl.create :user } }
        after(:all)  { User.delete_all }

        it { should have_selector('div.pagination') }

        it "should list each user" do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector('li', text: user.name) 
          end
        end
      end

      describe "delete links" do
        let!(:non_admin) { FactoryGirl.create :user, name: "Bob", email: "bob@example.com" }
        before { visit users_path }

        it { should     have_link('delete', href: user_path(non_admin)) }
        it { should_not have_link('delete', href: user_path(admin)) }

        it "should be able to delete another user" do
          expect { click_link 'delete', match: :first }.to change(User, :count).by(-1)
        end
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create :user  }
    before do
      sign_in user
      visit edit_user_path user 
    end

    describe "page" do
      it { should have_content "Update your profile"  }
      it { should have_title "Edit user"  }
    end

    context "with invalid information" do
      before { click_button "Save changes" } 

      it { should have_content 'error'  }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in_without_capybara user 
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end

    context "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end

  describe "profile page" do
    let(:user)    { FactoryGirl.create :user }
    let!(:task1)  { FactoryGirl.create :task, user: user }
    let!(:task2)  { FactoryGirl.create :completed_task, user: user }

    before do
      sign_in user
      visit user_path(user) 
    end

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe "tasks" do
      it { should have_content(task1.content) }
      it { should have_content(task2.content) }
      it { should have_css(".status.completed") }
      it { should have_css(".status.incomplete") }
      it { should have_content(user.tasks.count) }
    end
  end
end
