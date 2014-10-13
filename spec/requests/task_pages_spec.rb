require 'spec_helper'

describe "Task pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "task creation" do
    before { visit root_path }

    context "with invalid information" do

      it "should not create a task" do
        expect { click_button "Add" }.not_to change(Task, :count)
      end

      describe "error messages" do
        before { click_button "Add" }
        it { should have_content('error') }
      end
    end

    context "with valid information" do

      before { fill_in 'task_content', with: "Lorem ipsum" }
      it "should create a task" do
        expect { click_button "Add" }.to change(Task, :count).by(1)
      end
    end
  end

  describe "task destruction" do
    before { FactoryGirl.create(:task, user: user) }

    context "as correct user" do
      before { visit root_path }

      it "should delete a task" do
        expect { click_link "delete" }.to change(Task, :count).by(-1)
      end
    end
  end
end
