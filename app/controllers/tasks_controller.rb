class TasksController < ApplicationController
  before_action :signed_in_user  
  before_action :correct_user,   only: :destroy

  def create
    @task = current_user.tasks.build task_params
    if @task.save
      flash[:success] = "Task added"
      redirect_to root_url
    else      
      @feed_items = current_user.feed.paginate page: params[:page] 
      render 'static_pages/home'
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js   { render :layout => false }
    end
  end

  private

    def task_params
      params.require(:task).permit(:content)
    end

    def correct_user
      @task = current_user.tasks.find params[:id]
    rescue
      redirect_to root_url
    end
end