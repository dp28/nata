require 'spec_helper'

describe Task do

  let(:user)     { FactoryGirl.create :user }
  subject(:list) { user.root_list.add_task content: "list" } 
  before         { list.save!}

  describe "#add_task" do 
    let(:content) { "test" }
    it "should return a new task" do
      expect(list.add_task(content: content)).to be_a Task
    end

    describe "the returned task" do
      subject(:task) { list.add_task content: content } 
      its(:content) { should eq(content) }
      its(:parent)  { should eq(list) }
      its(:user)    { should eq(list.user) }
    end
  end

  context "with sublists and tasks" do
    let(:sublists)  { (1..3).map { list.add_task content: "sublist" } }
    let(:subtasks)  { sublists.map { |sublist| sublist.add_task  content: "subtask" } } 
    let!(:tasks)    { (1..5).map { list.add_task  content: "task" } }

    before do 
      sublists.map(&:save!)
      (subtasks + tasks).map(&:save!)
    end

    describe "#lists" do
      it "should contain child lists of the list that have child tasks of their own" do
        sublists.each { |sublist| expect(list.lists).to include(sublist) } 
      end

      it "should not contain child tasks of the list that do not have child tasks of their own" do
        tasks.each { |task|    expect(list.lists).not_to include(task) } 
      end

      it "should not contain children of its children" do
        subtasks.each { |subtask| expect(list.lists).not_to include(subtask) } 
      end      

      describe "each child of the returned lists" do
        it "should not have the list as its parent" do
          subtasks.each { |subtask| expect(subtask.parent).not_to eq(list) }
        end

        it "should have the specific sublist as its parent" do
          subtasks.each_with_index { |subtask, i| expect(subtask.parent).to eq(sublists[i]) }
        end
      end      
    end

    describe "#children" do  
      it "should contain child lists of the list that have child tasks of their own" do
        sublists.each { |sublist| expect(list.children).to include(sublist) } 
      end

      it "should contain child tasks of the list that do not have child tasks of their own" do
        tasks.each { |task| expect(list.children).to include(task) } 
      end

      it "should not contain children of its children" do
        subtasks.each { |subtask| expect(list.children).not_to include(subtask) } 
      end 

      describe "each child" do
        subject(:children) { list.children }
        it "should have the list as its parent" do
          children.each { |child| expect(child.parent).to eq(list) }
        end
      end
    end    
  end
end