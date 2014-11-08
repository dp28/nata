class User < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  before_save   :downcase_email
  before_create :create_activation_digest
  after_create :add_root_list

  MAX_USER_NAME_LENGTH = 64
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token, :activation_token, :reset_token

  validates :name, presence: true, length: { maximum: MAX_USER_NAME_LENGTH }
  validates :password, length: { minimum: 6 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
              uniqueness: { case_sensitive: false } 
  has_secure_password


  def User.digest string 
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def forget
    update_attribute :remember_digest, nil 
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def feed
    tasks.without_children.incomplete.order(:created_at)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver
  end

  def activate
    update_attribute :activated,    true
    update_attribute :activated_at, Time.zone.now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute :reset_digest,  User.digest(reset_token)
    update_attribute :reset_sent_at, Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def root_list
    tasks.first
  end

  def add_task params={}
    root_list.add_task params
  end

  private 

    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest activation_token
    end

    def add_root_list
      self.tasks.create content: "My lists" 
      true
    end
end
