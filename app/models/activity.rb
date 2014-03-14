class Activity < ActiveRecord::Base

	has_many :attendees
	has_many :users, through: :attendees

	validate :start_time_is_valid_datetime

	validate :end_time_is_valid_datetime

	def end_time_is_valid_datetime
    	errors.add(:end_time, 'must be a valid datetime') if ((DateTime.parse(end_time) rescue ArgumentError) == ArgumentError)
 	end

  	def start_time_is_valid_datetime
    	errors.add(:start_time, 'must be a valid datetime') if ((DateTime.parse(start_time) rescue ArgumentError) == ArgumentError)
  	end


	


	# def self.add(json)
	# 	params.permit!
	# 	act = Activity.new(json)
	# 	act.save
	# 	act
	# end
end
