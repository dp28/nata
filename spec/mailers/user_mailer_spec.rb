require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create :user }

  shared_examples_for "an email to a user" do
    its(:to) { should eq([user.email]) }
    its(:from) { should eq([ActionMailer::Base.default[:from]]) }
    specify { expect(mail.body.encoded).to match(user.name) } 
  end

  describe "account_activation" do
    subject(:mail) { UserMailer.account_activation user }

    it_should_behave_like "an email to a user"
    its(:subject) { should eq("Account activation") }
    specify { expect(mail.body.encoded).to match(user.activation_token) } 
    specify { expect(mail.body.encoded).to match("Hi") } 
  end

  describe "password_reset" do
    subject(:mail) do 
      user.create_reset_digest
      UserMailer.password_reset user
    end

    it_should_behave_like "an email to a user"
    its(:subject) { should eq("Password reset") }    
    specify { expect(mail.body.encoded).to match(user.reset_token) } 
    specify { expect(mail.body.encoded).to match("Hi") } 
  end

end
