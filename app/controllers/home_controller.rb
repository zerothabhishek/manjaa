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
    fire_github_access_step
    fire_other_setup_steps
    redirect_to dashboard_path
  end
  
  def finish_setup
    redirect_to github_auth_url unless current_user.got_access?
    fire_other_setup_steps
    redirect_to dashboard_path
  end

  private
  
  def fire_github_access_step
    Stalker.enqueue("github.fetch-access-token", :user_id => current_user.id, :code => code)
  end
  
  def fire_other_setup_steps(force=false)
    
    if !current_user.github_username_identified? || force
      Stalker.enqueue("github.get-user-info", :user_id => current_user.id)    
    end    
    if !current_user.public_key_uploaded?  || force
      Stalker.enqueue("github.upload-public-key", :user_id => current_user.id)    
    end    
    if !current_user.site_initialized? || force
      Stalker.enqueue("jekyll.init", :user_id => current_user.id)   
    end
  end
  
end