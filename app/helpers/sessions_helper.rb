module SessionsHelper

  def sign_in user 
    session[:user_id] = user.id
  end

  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def sign_out
    forget current_user
    session.delete :user_id 
    @current_user = nil
  end
  
  def signed_in?
    !current_user.nil?
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def current_user= user
    @current_user = user
  end

  def current_user
    if user_id = session[:user_id]
      find_current_user_from_session user_id
    elsif user_id = cookies.signed[:user_id]
      find_current_user_from_cookie user_id
    end
  end

  def current_user? user 
    user == current_user
  end

  def redirect_back_or default 
    redirect_to session[:return_to] || default
    session.delete :return_to 
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end

  private

    def find_current_user_from_session user_id
      @current_user ||= User.find_by id: user_id
    end

    def find_current_user_from_cookie user_id
      user = User.find_by id: user_id
      if user && user.authenticated?(:remember, cookies[:remember_token])
        sign_in user
        @current_user = user
      end      
    end
end
