require File.expand_path("../../../config/environment", __FILE__) 
require 'fileutils'

job "jekyll.init" do |args|

  user = User.find args['user_id'].to_s
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
    
end