class User < ActiveRecord::Base
  include SecurePassword
  has_secure_password
  
  has_many :posts
  has_one :github_info
  has_one :setup_status

  after_create :create_github_info_and_setup_status

  def remote_repo
    return nil unless github_username_identified?
    github_username = user.github_info.github_username
    "git@github.com:#{github_username}/#{github_username}.github.com"
  end
  
  # getters for setup_status 
  def site_initialized?;            self.setup_status.site_initialized;             end
  def site_remote_set?;             self.setup_status.site_remote_set;              end
  def github_username_identified?;  self.setup_status.github_username_identified;   end
  def site_repo_created?;           self.setup_status.site_repo_created;            end
  def public_key_uploaded?;         self.setup_status.public_key_uploaded;          end
  
  # setters for setup_status  
  def site_initialized!;            self.setup_status.update_attribute(:site_initialized,           true);   end  
  def site_remote_set!;             self.setup_status.update_attribute(:site_remote_set,            true);   end
  def github_username_identified!;  self.setup_status.update_attribute(:github_username_identified, true);   end
  def site_repo_created!;           self.setup_status.update_attribute(:site_repo_created,          true);   end
  def public_key_uploaded!;         self.setup_status.update_attribute(:public_key_uploaded,        true);   end
  
  def setup_jekyll
    Stalker.enqueue("jekyll.init", :user_id => self.id)
  end
  
  def setup_github code
    Stalker.enqueue("github.fetch_access_token", :code => code, :user_id => self.id )
  end
  
  def create_github_info_and_setup_status
    self.create_github_info
    self.create_setup_status
  end
  
end

