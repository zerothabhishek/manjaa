class HomeController < ApplicationController
  
  before_filter :authenticate!, :only => :dashboard
  
  def index
  end
  
  def dashboard
  end
  
  def github_callback
    @code = params[:code]
    @access_token = new_client.web_server.get_access_token(@code)
    user_json = @access_token.get('/api/v2/json/user/show')
    @user = JSON.parse user_json
  end

end