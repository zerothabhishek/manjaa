require File.expand_path("../../../config/environment", __FILE__) 
require 'fileutils'
include GithubProcessor

job "jekyll.init" do |args|
  user = User.find args['user_id'].to_i
  user.initilize_site
end

job "github.fetch_access_token" do |args|  
  user = User.find args['user_id'].to_i  
  user.setup_github_access(args["code"])
end

job "github.get_user_info" do |args|  
  user = User.find args['user_id'].to_i  
  user.identify_github_username
end

job "github.create_repo" do |args|
  user = User.find args['user_id'].to_i  
  user.create_site_repo
end

job "github.upload_public_key" do |args|
  user = User.find args['user_id'].to_i  
  user.upload_public_key
end

job "post.preprocess" do |args|
  post = Post.find args["post_id"].to_i
  post.preprocess
end

job "post.jkyll" do |args|
  post = Post.find args["post_id"].to_i
  post.jkyll
end

job "post.copy" do |args|
  post = Post.find args["post_id"].to_i
  post.copy
end

job "post.push" do |args|
  post = Post.find args["post_id"].to_i
  post.push
end
