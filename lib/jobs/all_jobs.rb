require File.expand_path("../../../config/environment", __FILE__) 
require 'fileutils'
include GithubProcessor

job "jekyll.init" do |args|
  begin
    user = User.find args['user_id'].to_i
    username = user.name
    sites_home = Manjaa::Application.config.sites_path
    user_home = "#{sites_home}/#{username}"
  
    puts "initializing jekyll site for the #{username} at #{user_home}"
    FileUtils.mkdir_p   user_home
    FileUtils.mkdir_p   "#{user_home}/_site"
    FileUtils.mkdir_p   "#{user_home}/_posts"
    FileUtils.mkdir_p   "#{user_home}/_layouts"
    FileUtils.cp        "#{sites_home}/_config.yml",  "#{user_home}/_config.yml"  
    FileUtils.cp        "#{sites_home}/index.html",   "#{user_home}/index.html"  
    FileUtils.cp        "#{sites_home}/default.html", "#{user_home}/_layouts/default.html"   
  
    user.site_initialized!
  rescue  => e
    p e.message
    p e.backtrace
  end
end

job "jekyll.set_site_remote" do |args|
  begin
    user = User.find args['user_id'].to_i
  
    user_site = "#{Manjaa::Application.config.sites_path}/#{user.name}/_site"
    FileUtils.cd user_site
    p "cd to #{user_site}"
  
    git_init_command = "git init"
    `#{git_init_command}`
    p "executed #{git_init_command}"
  
    git_remote_add_command = "git remote add origin #{user.remote_repo}"
    `#{git_remote_add_command}`
    p "executed #{git_remote_add_command}"

    user.site_remote_set!
  rescue => e
    p e.message
    p e.backtrace
  end  
end

job "github.fetch_access_token" do |args|  
  begin
    access_token = new_client.web_server.get_access_token(args["code"])
    user = User.find args["user_id"].to_i
    p "user=#{user.id}, access_token=#{access_token.token}"
    user.github_info.update_attribute(:access_token, access_token.token)
  rescue OAuth2::AccessDenied   
    user.lost_github_access!
  end
end

job "github.get_user_info" do |args|  
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    data = access_token.get('/api/v2/json/user/show')
    github_username = JSON.parse(data)["user"]["login"]
    p "user=#{user.id}, github_username=#{github_username}"
    
    user.github_info.update_attribute(:github_username, github_username)
    user.github_username_identified!
  rescue OAuth2::AccessDenied
    user.lost_github_access!
  end  
end

# This actually does NOT create the repo.
# It only checks of the repo exists, and if it does, sets the corresponding status flags
# Github api has problems creating repos via oAuth2, hence the user must be asked to create it manually.
job "github.create_repo" do |args|
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    github_username = user.github_info.github_username
    repo_data = JSON.parse(access_token.get("/api/v2/json/repos/show/#{github_username}"))
    repo_exists = repo_data["repositories"].any? { |repo| repo["name"] == user.remote_repo_name }
    p "repo exists" if repo_exists
        
    user.site_repo_created!   if repo_exists
  rescue OAuth2::AccessDenied
    user.lost_github_access!
  end
end


job "github.upload_public_key" do |args|
  begin
    user = User.find args["user_id"].to_i
    access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)
    
    public_key = File.read("/Users/abhishekyadav/.ssh/id_rsa.pub")
    params = {:title => "key from manjaa", :key => public_key }
    access_token.post('/api/v2/json/user/key/add', params)
    
    user.public_key_uploaded!    
  rescue OAuth2::AccessDenied
    user.lost_github_access!
  end
end


job "post.preprocess" do |args|
  begin
    post = Post.find args["post_id"].to_i
    post.preprocess_it
  rescue => e
    p e.message
    p e.backtrace
  end  
end

job "post.jkyll" do |args|
  begin
    post = Post.find args["post_id"].to_i
    post.jkyll_it
  rescue => e
    p e.message
    p e.backtrace
  end
end

job "post.push" do |args|
  begin
    post = Post.find args["post_id"].to_i
    post.push_it
  rescue => e
    p e.message
    p e.backtrace
  end
end
