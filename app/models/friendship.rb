class Friendship < ActiveRecord::Base
	# belongs_to :user
	# belongs_to :friend, :class_name => "User"

	# def self.getFriend(user_id, friend_id)
	# 	Friendship.find_by(:user_id => user_id, :friend_id => friend_id)
	# end
	
	validates_presence_of :user_id
	validates_presence_of :friend_id
end
