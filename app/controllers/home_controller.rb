class HomeController < ApplicationController
  
  before_filter :authenticate!, :only => [:dashboard, :github_callback]
  
  def index
  end
  
  def dashboard
  end
  
  def github_callback
    @code = params[:code]
    current_user.setup_github(@code)
    redirect_to dashboard_path
  end

end