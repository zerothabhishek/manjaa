class ApplicationController < ActionController::Base
  protect_from_forgery
  include GithubProcessor
  helper_method :github_auth_url
  
  def current_user
    logged_in? ? User.find(session[:current_user_id]) : nil
  end
  helper_method :current_user
  
  def logged_in?
    !!session[:current_user_id]
  end
  helper_method :logged_in?
  
  def authenticate!
    redirect_to login_path unless logged_in?
  end
  
  def set_session user
    session[:current_user_id] = user.id
  end
end
