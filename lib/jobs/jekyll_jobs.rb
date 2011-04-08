require File.expand_path("../../../config/environment", __FILE__) 
require 'fileutils'

job "jekyll.init" do |args|
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
end

job "jekyll.set_site_remote" do |args|
  user = User.find args['user_id'].to_i
  
  user_site = "#{Manjaa::Application.config.sites_path}/#{user.name}/_site"
  FileUtils.cd user_site
  
  git_init_command = "git init"
  `#{git_init_command}`
  
  git_remote_add_command = "git remote add origin #{user.remote_repo}"
  `#{git_remote_add_command}`
  
  user.site_remote_set!
end
