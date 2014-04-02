require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "user_id cannot be null" do 
  Attendee.delete_all
    attendee1 = Attendee.new(:activity_id => 17)
    assert !attendee1.save, "user_id cannot be null"
  end

  test "activity_id cannot be null" do
  Attendee.delete_all
    attendee1 = Attendee.new(:user_id => 12)
    assert !attendee1.save, "activity_id cannot be null"
  end

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
