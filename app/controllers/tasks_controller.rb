class TasksController < ApplicationController
  before_action :signed_in_user  
  before_action :correct_user,   only: :destroy

  def create
    @task = create_task
    if @task.save
      flash[:success] = "Task added"
    else 
      flash[:danger] = "Failed to add task" 
    end
    respond
  end

  def destroy    
    if attempt_destroy 
      flash[:success] = "Task deleted"
    else
      flash[:danger] = "You cannot delete this task"
    end
    respond
  end

  def complete
    @task = Task.find(params[:id])
    @task.complete!
    respond
  end

  def uncomplete
    @task = Task.find(params[:id])
    @task.uncomplete!
    respond
  end

  private

    def task_params
      params.require(:task).permit :content
    end

    def create_task
      parent = Task.find_by id: params[:parent_id]
      task = parent.add_task task_params
      task
    end

    def correct_user
      @task = current_user.tasks.find params[:id]
    rescue
      redirect_to root_url
    end

    def attempt_destroy
      if @task.root?
        false
      else
        @task.destroy
      end
    end

    def respond      
      respond_to do |format|
        format.html { redirect_to :back }
        format.js   { render layout: false }
      end 
    end
end