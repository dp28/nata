require 'spec_helper'

describe TasksHelper do

  describe "append_id" do
    let(:task) { FactoryGirl.create :task }
    specify { expect(append_id("test", task)).to eq("test_task_#{task.id}") } 
  end
end
