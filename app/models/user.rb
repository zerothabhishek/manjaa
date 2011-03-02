class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise  :database_authenticatable, # encrypts and stores a password in the database to validate the authenticity of an user while signing in.
          :registerable, # handles signing up users through a registration process, also allowing them to edit and destroy their account.
          :recoverable, # resets the user password and sends reset instructions.
          :rememberable, # manages generating and clearing a token for remembering the user from a saved cookie.
          :trackable, # tracks sign in count, timestamps and IP address.
          :validatable # provides validations of email and password 

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :sites
  has_many :posts  
end
