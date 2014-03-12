class Attendee < ActiveRecord::Base
	belongs_to :user
	belongs_to :activity

	def self.add(json)
		atd = Attendee.new(json)
		atd.save
		atd
	end
end
