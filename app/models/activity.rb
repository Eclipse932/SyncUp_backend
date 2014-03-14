class Activity < ActiveRecord::Base

	has_many :attendees
	has_many :users, through: :attendees

  validates_presence_of :name
	#validate :start_must_be_before_end_time

  	#def start_must_be_before_end_time
  		 
  		#if ((DateTime.parse(end_time) rescue ArgumentError) == ArgumentError)
  			#errors.add(:end_time, 'must be a valid datetime')
  			
  		#elsif ((DateTime.parse(start_time) rescue ArgumentError) == ArgumentError)
  			#errors.add(:start_time, 'must be a valid datetime') 
  			
  		#else start_time >= end_time
    		#errors.add(:start_time, "must be before end time") 
    	#end
 	#end 


	# def self.add(json)
	# 	params.permit!
	# 	act = Activity.new(json)
	# 	act.save
	# 	act
	# end
end
