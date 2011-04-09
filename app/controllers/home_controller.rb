class HomeController < ApplicationController
  
  before_filter :authenticate!, :only => [:dashboard, :github_callback, :setup]
  
  def index
  end
  
  def dashboard
  end
  
  def github_callback
    code = params[:code]
    debugger
    current_user.github_info.update_attribute(:access_code, code)
    current_user.do_setup(code)
    redirect_to dashboard_path
  end

end