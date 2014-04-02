require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "validate activity name is not nil" do 
  Activity.delete_all
  	activity = Activity.new()
  	assert !activity.save, "activity must have a name"
  end

  test "test activity visibility for friends1" do
  Friendship.delete_all
  Activity.delete_all
  	friendship1 = Friendship.new(:user_id => 11, :friend_id => 12, :status => 2)
  	assert friendship1.save, "adding friendship1 relation failed"
  	friendship2 = Friendship.new(:user_id => 12, :friend_id => 11, :status => 2)
  	assert friendship2.save, "adding friendship2 relation failed"
  	activity = Activity.new(:name => "poker face!", :host_id => 12, :visibility => 2)
  	assert activity.save, "adding activity failed"
  	assert Activity.visible?(11, activity), "accepted friends should be able to see activities hosted by each other with default actvity visibility"

  end

  test "test activity visibility for attendee" do
  Activity.delete_all
  Attendee.delete_all
    activity = Activity.new(:name => "poker face!", :host_id => 12, :visibility => 2)
  	assert activity.save, "adding activity failed"
  	user1 = Attendee.new(:user_id => 11, :activity_id => activity.id, :role => GUEST)
  	assert user1.save, "adding user1 failed"
  	user2 = Attendee.new(:user_id => 12, :activity_id => activity.id, :role => HOST)
  	assert user2.save, "adding user2 failed"
  	assert Activity.visible?(11, activity), "activity attendee should be able to see activities under default visibility"
  	assert Activity.visible?(12, activity), "activity host should be able to see activities under default visibility"
  end

  test "adding activity1" do 
  Activity.delete_all
  Attendee.delete_all
   	activity = Activity.add({"name" => "poker face!", "host_id" => 14})
   	if activity
   		assert_equal(ACCEPTED, activity.visibility, "default visibility should be ACCEPTED")
   		attendee = Attendee.find_by(:user_id => 14)
   		assert_equal(activity.id, attendee.activity_id, "should update the attendee table")
   		assert_equal(HOST, attendee.role, "should add the attendee as host")
   	end
  end 

  test "adding activity2" do
  Activity.delete_all
  Attendee.delete_all
  		activity = Activity.add({"host_id" => 14})
  		assert_nil(activity, "save the activity with no name ")

  end 

  test "adding activity3" do
  Activity.delete_all
  Attendee.delete_all
  		activity = Activity.add({"name" => "poker face!"})
  		assert_nil(activity, "save the activity with no host")

  end 
  

end
