class TasksController < ApplicationController
  before_action :signed_in_user  
  before_action :correct_user,   only: :destroy

  def create
    @task = create_task
    if @task.save
      flash[:success] = "Task added"
      redirect_to :back
    else 
      flash[:danger] = "Failed to add task"     
      @feed_items = current_user.feed.paginate page: params[:page] 
      render 'static_pages/home'
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render layout: false }
    end
  end

  def complete
    @task = Task.find(params[:id])
    @task.complete!
    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render layout: false }
    end
  end

  def uncomplete
    @task = Task.find(params[:id])
    @task.uncomplete!
    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render layout: false }
    end
  end

  private

    def task_params
      params.require(:task).permit :content
    end

    def create_task
      task = current_user.add_task task_params
      task.parent_id = params[:task][:parent_id]
      task
    end

    def correct_user
      @task = current_user.tasks.find params[:id]
    rescue
      redirect_to root_url
    end
end