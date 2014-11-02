class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by email: params[:email].downcase
    if user && user.authenticate(params[:password])
      attempt_sign_in user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    sign_out if signed_in?
    redirect_to root_url
  end

  private 

    def attempt_sign_in user
      if user.activated?
        sign_in_user user
      else
        flash[:error] = "Account not activated. Check your email for the activation link."
        redirect_to root_url
      end
    end

    def sign_in_user user
      sign_in user
      params[:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    end
end
