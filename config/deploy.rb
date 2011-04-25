require 'config/deploy/capistrano_database_yml'

set :application, "manjaa"
set :repository,  "git@github.com:zerothabhishek/manjaa.git"

set :scm, :git
set :user, "root"
set :deploy_to, "/var/www/manjaa"
set :apache_site_folder, "/etc/apache2/sites-enabled"
set :app_site, "li161-110.members.linode.com" 
set :branch, "master"
set :deploy_via, :remote_cache
role :web, app_site                          # Your HTTP server, Apache/etc
role :app, app_site                          # This may be the same as your `Web` server
role :db,  app_site, :primary => true        # This is where Rails migrations will run

set :scm_passphrase, Capistrano::CLI.password_prompt("Enter your git passphrase: ")
default_run_options[:pty] = true  # Must be set for the password prompt from git to work

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
