class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	before_save :ensure_authentication_token
  validates_uniqueness_of :email

  devise :database_authenticatable, :registerable,
				 :recoverable, :rememberable, :trackable, :validatable

  # has_many :attendees
  # has_many :activities, through: :attendees

  # has_many :friends, :through => :friendships, :conditions => "status = " + ACCEPTED.to_s
  # has_many :starred_friends, :through => :friendships, :source => :friend, :conditions => "status = " + STARRED.to_s
  # has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = " + REQUESTED.to_s, :order => :created_at
  # has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status = " + PENDING.to_s, :order => :created_at
  # has_many :friendships, :dependent => :destroy


  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
 
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

	def self.authenticate(ep)
    user = User.find_for_authentication(:email => ep[:email])
    if user and user.valid_password?(ep[:password])
    	user
    end
  end

  def self.reset
    User.delete_all
  end

end
