require 'spec_helper'

describe "Task pages" do

  subject { page }

  let(:user)  { FactoryGirl.create(:user) }
  let!(:task) { user.root_list }
  before { sign_in user }

  describe "task creation" do
    let(:add_button) { append_id("add_child_to", task) }
    before { visit user_path(user) }

    context "with invalid information" do

      it "should not create a task" do        
        expect { click_button add_button }.not_to change(Task, :count)
      end

      describe "error messages" do
        before { click_button add_button }
        it { should have_content('Failed') }
      end
    end

    context "with valid information" do      
      before { fill_in append_id("new_child_content", task), with: "Lorem ipsum" }
      it "should create a task" do
        expect { click_button add_button }.to change(Task, :count).by(1)
      end
    end

    describe "adding subtasks" do

      before do
        visit user_path(user)
        fill_in append_id("new_child_content", task), with: "Lorem ipsum"        
      end

      it "should add a task to the original task's children" do
        expect { 
          click_button append_id("add_child_to", task) 
        }.to change(task.children, :count).by(1)
      end

      context "after adding a subtask" do
        before {  click_button append_id("add_child_to", task) }
        it "should add a new task as a descendent of the parent task's div" do
          task_div      = "@id='task_#{task.id}'"
          task_list     = "@class=#{xpath_match_class('task_list')}"
          task_content  = "@class=#{xpath_match_class('task_content')}"
          subtask = "//*[#{task_div}]/*[#{task_list}]//*[#{task_content}]"
          expect(page).to have_xpath(subtask)
        end
      end
    end
  end

  describe "task destruction" do
    context "as correct user" do
      let(:non_root) { task.add_task content: "non-root" }
      before do 
        non_root.save! 
        visit user_path(user)
      end

      context "deleting a root_list" do
        it "should not be possible" do
          expect { click_link append_id("delete", task) }.not_to change(Task, :count)
        end

        it "should show an error message" do
          click_link append_id("delete", task) 
          expect(page).to have_error_message "You cannot delete this task"
        end
      end

      context "deleting a non-root_task" do
        it "should delete a task" do
          expect { click_link append_id("delete", non_root) }.to change(Task, :count).by(-1)
        end
      end
    end
  end

  describe "task completion" do
    context "as correct user" do
      before { visit user_path(user) }

      it "should complete the task" do
        expect { 
          click_link append_id("complete", task)
          task.reload 
        }.to change(task, :completed?).from(false).to(true)
      end
    end
  end

  describe "uncompleting a task" do
    context "as correct user" do
      before do
        task.complete!
        visit user_path(user)  
      end

      it "should uncomplete the task" do
        expect { 
          click_link append_id("uncomplete", task)
          task.reload 
        }.to change(task, :completed?).from(true).to(false)
      end
    end
  end
end
