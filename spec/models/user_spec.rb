require 'spec_helper'

describe User do

  subject(:user) do
    User.new(name: "Example User", email: "user@example.com", password: "foobar",
              password_confirmation: "foobar") 
  end


  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:authenticated?) }
  it { should respond_to(:admin) }
  it { should respond_to(:tasks) }
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }

  describe "User.create" do
    it "should create a new task for the User" do
      expect { FactoryGirl.create :user }.to change(Task, :count).by(1)
    end

    describe "the created task" do
      let(:new_user)  { FactoryGirl.create :user }
      subject         { new_user.tasks.first }
      it              { should eq(new_user.root_list) }
      its(:content)   { should eq("My lists") }
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      user.save!
      user.toggle! :admin
    end

    it { should be_admin }
  end

  context "when name is not present" do
    before { user.name = " " }
    it { should_not be_valid }
  end

  context "when email is not present" do
    before { user.email = " " }
    it { should_not be_valid }
  end

  context "when name is too long" do
    before { user.name = "a" * 65 }
    it { should_not be_valid }
  end

  context "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com, foo@bar..com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  context "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  context "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  context "when lowercase version of email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  context "when password is not present" do
    subject(:user) do
      User.new(name: "Example User", email: "user@example.com", password: " ", 
        password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  context "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "#authenticate" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }

    context "with valid password" do
      it { should eq found_user.authenticate(user.password) }
    end

    context "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "#authenticated?" do
    context "when the user has a nil remember_digest" do
      specify { expect(user.authenticated?(:remember, "")).to be false }
    end
  end

  describe "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "task associations" do
    subject!(:user)   { FactoryGirl.create :user }
    let!(:older_task) { user.add_task content: "old task" }
    let!(:newer_task) { user.add_task content: "new task"  }

    before do
      user.save! 
      older_task.update_attribute :created_at, 1.day.ago
      newer_task.update_attribute :created_at, 1.hour.ago
    end 

    its(:root_list) { should_not be nil }

    describe "tasks other than the root list" do
      it "should all be children of the user's root_list" do
        [older_task, newer_task].each do |task|
          expect(user.root_list.descendants).to include(task)
        end
      end
    end

    describe "the root list" do
      it "should be an ancestor of all other tasks" do
        [older_task, newer_task].each do |task|
          expect(task.ancestors).to include(user.root_list)
        end
      end
    end 

    it "should destroy associated tasks" do
      tasks = user.tasks.to_a
      user.destroy
      expect(tasks).not_to be_empty
      tasks.each do |tasks|
        expect(Task.where(id: tasks.id)).to be_empty
      end
    end

    describe "status" do
      let(:completed_task)  { user.add_task completed: true }
      let(:other_user_task) { FactoryGirl.create(:user).tasks.build }
      let(:root_list)       { user.root_list }

      its(:feed) { should include(older_task) }
      its(:feed) { should include(newer_task) }
      its(:feed) { should_not include(root_list) }
      its(:feed) { should_not include(completed_task) }
      its(:feed) { should_not include(other_user_task) }
    end
  end
end