require File.expand_path("../../../config/environment", __FILE__) 
include GithubProcessor

job "github.fetch_access_token" do |args|  
  begin
    access_token = "2"#new_client.web_server.get_access_token(args["code"])
    user = User.find args["user_id"].to_i
    p "user=#{user.id}"
    user.github_info.update_attribute(:access_token, access_token)
  rescue OAuth2::HTTPError    
  end
end

job "github.get_user_info" do |args|  
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    data = access_token.get('/api/v2/json/user/show')
    
    github_username = JSON.parse(data)["user"]["login"]
    user.github_username_identified!
  rescue OAuth2::HTTPError
  end  
end

job "github.create_repo" do |args|
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    repo_name = "#{user.github_info.github_username}.github.com"
    home_page = "http://#{repo_name}"
    params = {:name => repo_name, :desc => "some desc", :homepage => home_page, :public => 1}
    access_token.post('/api/v2/json/repos/create', params)
    
    user.site_repo_created!
  rescue OAuth2::HTTPError
  end
end


job "github.upload_public_key" do |args|
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    public_key = File.read("~/.ssh/id_rsa.pub")
    params = {:title => "key from manjaa", :key => public_key }
    access_token.post('/api/v2/json/user/key/add', params)
    
    user.public_key_uploaded!    
  rescue OAuth2::HTTPError
  end
end
