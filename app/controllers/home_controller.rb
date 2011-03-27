class HomeController < ApplicationController

  def index
  end
  
  def github_callback
    @code = params[:code]
  end

end