require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "unique attendee in a specifc activity" do
  Attendee.delete_all
  	attendee1 = Attendee.new(:activity_id => 17, :user_id => 12)
  	assert attendee1.save, "adding attendee to a specific event failed"
  	attendee2 = Attendee.new(:activity_id => 17, :user_id => 12)
  	assert !attendee2.save, "single event have duplicate attendees"
  end

  test "same users permitted for different activities" do
  Attendee.delete_all
  	attendee1 = Attendee.new(:activity_id => 17, :user_id => 12)
  	assert attendee1.save, "adding attendee to a specific event failed"
  	attendee2 = Attendee.new(:activity_id => 18, :user_id => 12)
  	assert attendee2.save, "different event could have duplicate attendees"
  end 

end
