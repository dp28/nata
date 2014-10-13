require 'spec_helper'

describe Task do

  let(:user) { FactoryGirl.create :user }
  before { @task = user.tasks.build content: "Lorem ipsum" }

  subject { @task }

  it { should respond_to :content }
  it { should respond_to :user_id }
  it { should respond_to :parent_id }
  it { should respond_to :user }
  it { should respond_to :completed }
  its(:user) { should eq user }

  it { should be_valid }

  context "when user_id is not present" do
    before { @task.user_id = nil }
    it { should_not be_valid }
  end


  describe "#completed" do
    it "should default to false" do
      expect(@task.completed).to be false
    end
  end
end
