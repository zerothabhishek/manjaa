class User < ActiveRecord::Base
  include SecurePassword
  include GithubProcessor
  has_secure_password
  
  has_many :posts
  has_one :github_info
  has_one :setup_status

  attr_accessor :home_path, :posts_dir, :push_dir, :site_dir, :remote_repo
  
  after_create :create_github_info_and_setup_status

  def create_github_info_and_setup_status
    self.create_github_info
    self.create_setup_status
  end

  def home_path
    sites_home = Manjaa::Application.config.sites_path
    user_home = "#{sites_home}/#{name}"     
    github_username_identified? ? user_home : nil 
  end
  
  def posts_dir; File.join(home_path, "_posts"); end
  def push_dir;  File.join(home_path, "_push");  end
  def site_dir;  File.join(home_path, "_site");  end
    
  
  def remote_repo_name
    "#{github_info.github_username}.github.com"
  end
  
  def remote_repo
    github_username_identified? ? "git@github.com:#{github_info.github_username}/#{remote_repo_name}.git" : nil
  end
    
  # getters for github_info
  def got_code?;                    !self.github_info.access_code.blank?      end  
  def got_access?;                  !self.github_info.access_token.blank?     end  
  
  # setters for github_info
  def lost_github_access!;          self.github_info.update_attribute(:access_token, nil) end
  
  # getters for setup_status 
  def site_initialized?;            self.setup_status.site_initialized;     end
  def site_repo_created?;           self.setup_status.site_repo_created;    end
  def public_key_uploaded?;         self.setup_status.public_key_uploaded;  end
  def github_username_identified?;  self.setup_status.github_username_identified; end
  
  # setters for setup_status  
  def site_initialized!;            self.setup_status.update_attribute(:site_initialized, true);    end  
  def site_repo_created!;           self.setup_status.update_attribute(:site_repo_created, true);   end
  def public_key_uploaded!;         self.setup_status.update_attribute(:public_key_uploaded, true); end      
  def github_username_identified!;  self.setup_status.update_attribute(:github_username_identified, true); end
  
  ####### setup stuff
  def setup_incomplete?
    !site_initialized?  || 
    !github_username_identified? || 
    !site_repo_created? || 
    !public_key_uploaded?
  end
  
  def setup_almost_complete?
    !site_repo_created?   && 
    site_initialized?     && 
    github_username_identified?   && 
    public_key_uploaded?
  end
  
  def setup_complete?
    !setup_incomplete?
  end

  def do_setup(code)
    Stalker.enqueue("github.fetch_access_token", :user_id => self.id, :code => code)    if got_code? && !got_access?
    Stalker.enqueue("github.get_user_info",      :user_id => self.id)   unless github_username_identified?
    Stalker.enqueue("github.upload_public_key",  :user_id => self.id)   unless public_key_uploaded?
    Stalker.enqueue("jekyll.init",               :user_id => self.id)   unless site_initialized?
  end
  
  def setup_github_access(code)
    begin
      access_token = new_client.web_server.get_access_token(code)
      p "user=#{id}, access_token=#{access_token.token}"
      github_info.update_attribute(:access_token, access_token.token)
    rescue OAuth2::AccessDenied   
      user.lost_github_access!
    end    
  end
  
  def identify_github_username
    begin
      access_token = OAuth2::AccessToken.new(new_client, github_info.access_token)

      data = access_token.get('/api/v2/json/user/show')
      github_username = JSON.parse(data)["user"]["login"]
      p "user=#{id}, github_username=#{github_username}"

      user.github_info.update_attribute(:github_username, github_username)
      user.github_username_identified!
    rescue OAuth2::AccessDenied
      user.lost_github_access!
    end
  end

  # This actually does NOT create the repo.
  # It only checks of the repo exists, and if it does, sets the corresponding status flags
  # Github api has problems creating repos via oAuth2, hence the user must be asked to create it manually.  
  def create_site_repo
    begin
      access_token = OAuth2::AccessToken.new(new_client, github_info.access_token)
      github_username = github_info.github_username

      repo_data = JSON.parse(access_token.get("/api/v2/json/repos/show/#{github_username}"))
      repo_exists = repo_data["repositories"].any? { |repo| repo["name"] == remote_repo_name }
      p "repo exists" if repo_exists

      site_repo_created!   if repo_exists
    rescue OAuth2::AccessDenied
      user.lost_github_access!
    end
  end
  
  def upload_public_key
    begin
      access_token = OAuth2::AccessToken.new(new_client, user.github_info.access_token)

      public_key = File.read("/Users/abhishekyadav/.ssh/id_rsa.pub")
      params = {:title => "key from manjaa", :key => public_key }
      access_token.post('/api/v2/json/user/key/add', params)

      user.public_key_uploaded!    
    rescue OAuth2::AccessDenied
      user.lost_github_access!
    end
  end
  
  def initilize_site
    begin
      username = self.name
      sites_home = Manjaa::Application.config.sites_path
      user_home = "#{sites_home}/#{username}"

      puts "initializing jekyll site for the #{username} at #{user_home}"
      FileUtils.mkdir_p   user_home
      FileUtils.mkdir_p   "#{user_home}/_site"
      FileUtils.mkdir_p   "#{user_home}/_posts"
      FileUtils.mkdir_p   "#{user_home}/_layouts"
      FileUtils.mkdir_p   "#{user_home}/_push"
      FileUtils.cp        "#{sites_home}/_config.yml",  "#{user_home}/_config.yml"  
      FileUtils.cp        "#{sites_home}/index.html",   "#{user_home}/index.html"  
      FileUtils.cp        "#{sites_home}/default.html", "#{user_home}/_layouts/default.html"   

      FileUtils.cd "#{user_home}/_push"
      git_init_command = "git init"
      output = `#{git_init_command}`
      raise output unless $?.success?
            
      self.site_initialized!
    rescue  => e
      p e.message
      p e.backtrace
    end
  end
    
end

