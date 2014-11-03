require 'spec_helper'

describe Task do

  let(:user)      { FactoryGirl.create :user }
  subject(:task)  { user.tasks.build content: "Lorem ipsum" }

  it { should respond_to :content }
  it { should respond_to :user_id }
  it { should respond_to :parent_id }
  it { should respond_to :user }
  it { should respond_to :completed }
  its(:user) { should eq user }

  it { should be_valid }

  context "when user_id is not present" do
    before { task.user_id = nil }
    it  { should_not be_valid }
  end

  describe "#completed?" do
    it "should default to false" do
      expect(task.completed?).to be false
    end
  end

  describe "#complete!" do
    it "should make the task completed" do
      expect { task.complete! }.to change(task, :completed?).from(false).to(true) 
    end
  end

  describe "#uncomplete!" do
    before { task.complete! }
    it "should make the task incomplete" do
      expect { task.uncomplete! }.to change(task, :completed?).from(true).to(false) 
    end
  end
end
