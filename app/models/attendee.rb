class Attendee < ActiveRecord::Base
    validates_presence_of :user_id
    validates_presence_of :activity_id
	validates_uniqueness_of :user_id, :scope => :activity_id


end
