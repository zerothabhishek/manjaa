class SessionsController < ApplicationController
  
  # GET /login
  def new
  end
  
  # POST /sessions
  def create
    user = User.find_by_name(params[:user][:name]).try(:authenticate, params[:user][:password]) 
    set_session user
    redirect_to dashboard_path
  end
  
  # GET /logout
  def destroy
    session[:current_user_id] = nil
    redirect_to :root
  end
  
end