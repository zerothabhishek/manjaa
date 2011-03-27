class User < ActiveRecord::Base
  include SecurePassword
  has_secure_password
  
  has_many :posts
end