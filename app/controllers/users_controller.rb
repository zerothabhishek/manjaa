class UsersController < ApplicationController
  
  layout nil
    
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      set_session @user
      @user.setup_jekyll
      redirect_to dashboard_path
    else
      render :text => "some error occurred"
    end
  end
    
end