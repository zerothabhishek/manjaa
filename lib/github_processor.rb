module GithubProcessor
    
  def github_user access_token
    JSON.parse(access_token.get('/api/v2/json/user/show')) 
  end
  
  def github_url
    new_client.web_server.authorize_url(
        :scope => 'email,offline_access')
  end

  ## taken from this gist - https://gist.github.com/9fd1a6199da0465ec87c
  def new_client
    client_id = "40b43a12613944cc85aa"
    client_secret = "6b03149d65012d21b08d55b14d09ecb30e2a1fe5"
    OAuth2::Client.new(client_id, client_secret, :site => 'https://github.com',
      :authorize_path => '/login/oauth/authorize', :access_token_path => '/login/oauth/access_token')
  end
  
  ## taken from this gist - https://gist.github.com/9fd1a6199da0465ec87c
  def redirect_uri(path = '/auth/github/callback', query = nil)
    uri = URI.parse(request.url)
    uri.path  = path
    uri.query = query
    uri.to_s
  end
  
end