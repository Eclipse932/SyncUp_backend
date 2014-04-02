class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	before_save :ensure_authentication_token
	validates_uniqueness_of :email
	has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
	# validates_attachment :avatar, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png"] }
	do_not_validate_attachment_file_type :avatar

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
 
 
	def self.authenticate(ep)
		user = User.find_for_authentication(:email => ep[:email])
		if user and user.valid_password?(ep[:password])
			user
		end
	end
	

	def self.reset
		User.delete_all
	end


	def self.findUser(userJSON)
		users = User.select("first_name, last_name, email, id, description").where(userJSON)
		users.each do |user|
			if user.avatar.exists?
				user[:avatar] = Base64.encode64(open(user.avatar.path(:thumbnail)){ |io| io.read })
			end
		end
		users
	end


	def user_params
		params.require(:user).permit(:avatar)
	end


	private
	
	def generate_authentication_token
		loop do
			token = Devise.friendly_token
			break token unless User.where(authentication_token: token).first
		end
	end



end
