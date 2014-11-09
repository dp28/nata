require 'spec_helper'

describe TasksHelper do

  describe "append_id" do
    let(:user) { FactoryGirl.create :user }
    let(:task) { user.add_task content: "test" }
    specify { expect(append_id("test", task)).to eq("test_task_#{task.id}") } 
  end
end
