class Activity < ActiveRecord::Base

	#has_many :attendees
	# has_many :users, through: :attendees

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

  def self.visible?(user_id, act)
    logger.info "HERE"
    atd = Attendee.find_by(:user_id => user_id, :activity_id => act.id)
    if atd and atd.role <= act.visibility
      return true
    end

    fds = Friendship.find_by(:user_id => act.host_id, :friend_id => user_id)
    if fds and fds.status <= act.visibility
      return true
    else
      return false
    end
  end
  

	def self.add(permitted)
    #permitted = act_json.permit(:name, :status, :host_id, :location, :description, :visibility, :start_time, :end_time)

    if permitted[:visibility] == nil
      permitted[:visibility] = ACCEPTED
    end
		act = Activity.new(permitted)
		if act.save
      atd = Attendee.new(:user_id => act.host_id, :activity_id => act.id, :role => HOST)
      if atd.save
        return act
      else
        act.destroy
      end
    end

    return nil
	end

end
