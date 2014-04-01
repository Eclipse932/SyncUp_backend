class Attendee < ActiveRecord::Base

	validates_uniqueness_of :user_id, :scope => :activity_id

end
