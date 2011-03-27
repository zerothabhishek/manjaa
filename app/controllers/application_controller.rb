class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def current_user
    logged_in? ? User.find(session[:current_user_id]) : nil
  end
  helper_method :current_user
  
  def logged_in?
    !!session[:current_user_id]
  end
  helper_method :logged_in?
  
end
