require 'spec_helper'

describe "PasswordResets" do
  subject { page }
  let(:user) { FactoryGirl.create :user }

  describe "entering the email to send the reset message to" do    
    before { visit password_resets_new_path }

    context "with an invalid email address" do 
      ["test", "test@.", "t..@"].each do |invalid_email|
        before do 
          fill_in       "Email", with: invalid_email
          click_button  "Submit"
        end

        it { click_button "Submit"; should_not have_content("Email sent") }
        it "should send an email" do
          expect { click_button "Submit" }.not_to change { ActionMailer::Base.deliveries.size }
        end
      end
    end

    context "with a valid email that does not belong to a user" do
      before do 
        fill_in       "Email", with: "invalid_email@example.org"
        click_button  "Submit"
      end

      it { click_button "Submit"; should_not have_content("Email sent") }
      it "should send an email" do
        expect { click_button "Submit" }.not_to change { ActionMailer::Base.deliveries.size }
      end
    end

    context "with a valid email address" do
      before do 
        fill_in       "Email", with: user.email
      end

      it { click_button "Submit"; should have_content("Email sent with password reset instructions") }
      it "should send an email" do
        expect { click_button "Submit" }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end

  describe "resetting a password" do
    context "with an invalid email address" do
      subject { get password_resets_edit_path(user.reset_token, email: 'wrong') }
      it { should redirect_to root_url }
    end

    context "with the correct email address" do
      let(:email) { user.email }
      let(:token) { user.reset_token }

      context "with an invalid token" do
        subject { get password_resets_edit_path('invalid', email: email) }
        it      { should redirect_to root_url }
      end

      context "with an expired token" do
        subject { get password_resets_edit_path(token, email: email) }
        before  { user.update_attribute :reset_sent_at, 3.hours.ago }
        it      { should redirect_to root_url }
      end
    end    
  end
end
