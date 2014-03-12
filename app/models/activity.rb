class Activity < ActiveRecord::Base


	has_many :attendees
	has_many :users, through: :attendees


	# def self.add(json)
	# 	params.permit!
	# 	act = Activity.new(json)
	# 	act.save
	# 	act
	# end
end
