class User < ActiveRecord::Base
  include SecurePassword
  has_secure_password
  
  has_many :posts
  has_one :github_info
  has_one :setup_status

  after_create :create_github_info_and_setup_status

  def create_github_info_and_setup_status
    self.create_github_info
    self.create_setup_status
  end

  def remote_repo_name
    "#{github_info.github_username}.github.com"
  end
  
  def remote_repo
    github_username_identified? ? "git@github.com:#{github_info.github_username}/#{remote_repo_name}" : nil
  end
    
  # getters for github_info
  def got_code?;                    !self.github_info.access_code.blank?      end  
  def got_access?;                  !self.github_info.access_token.blank?     end  
  
  # setters for github_info
  def lost_github_access!;          self.github_info.update_attribute(:access_token, nil) end
  
  # getters for setup_status 
  def site_initialized?;            self.setup_status.site_initialized;     end
  def site_remote_set?;             self.setup_status.site_remote_set;      end
  def site_repo_created?;           self.setup_status.site_repo_created;    end
  def public_key_uploaded?;         self.setup_status.public_key_uploaded;  end
  def github_username_identified?;  self.setup_status.github_username_identified; end
  
  # setters for setup_status  
  def site_initialized!;            self.setup_status.update_attribute(:site_initialized, true);    end  
  def site_remote_set!;             self.setup_status.update_attribute(:site_remote_set, true);     end
  def site_repo_created!;           self.setup_status.update_attribute(:site_repo_created, true);   end
  def public_key_uploaded!;         self.setup_status.update_attribute(:public_key_uploaded, true); end      
  def github_username_identified!;  self.setup_status.update_attribute(:github_username_identified, true); end
  
  ####### setup stuff
  def setup_incomplete?
    !site_initialized?  || 
    !site_remote_set?   || 
    !github_username_identified? || 
    !site_repo_created? || 
    !public_key_uploaded?
  end
  
  def setup_almost_complete?
    !site_repo_created?   && 
    site_initialized?     && 
    site_remote_set?      && 
    github_username_identified?   && 
    public_key_uploaded?
  end
  
  def setup_complete?
    !setup_incomplete?
  end

  def do_setup(code)
    setup_github_access(code)   if got_code? && !got_access?
    identify_github_username    unless github_username_identified?
    upload_public_key           unless public_key_uploaded?
    initilize_site              unless site_initialized?
    set_site_remote             unless site_remote_set?
  end
  
  def setup_github_access(code)
    Stalker.enqueue("github.fetch_access_token", :code => code, :user_id => self.id) 
  end
  
  def identify_github_username
    Stalker.enqueue("github.get_user_info", :user_id => self.id)
  end
  
  def create_site_repo
    Stalker.enqueue("github.create_repo", :user_id => self.id)
  end
  
  def upload_public_key
    Stalker.enqueue("github.upload_public_key", :user_id => self.id)
  end
  
  def initilize_site
    Stalker.enqueue("jekyll.init", :user_id => self.id)
  end
  
  def set_site_remote
    Stalker.enqueue("jekyll.set_site_remote", :user_id => self.id)
  end
  
end

