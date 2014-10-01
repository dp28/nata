class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  MAX_USER_NAME_LENGTH = 64
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i # Accepts consecutive dots ...

  validates :name, presence: true, length: { maximum: MAX_USER_NAME_LENGTH }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  has_secure_password
end
