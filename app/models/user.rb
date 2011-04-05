class User < ActiveRecord::Base
  include SecurePassword
  has_secure_password
  
  has_many :posts
  
  def setup_jekyll
    Stalker.enqueue("jekyll.init", :user_id => self.id)
  end
  
end