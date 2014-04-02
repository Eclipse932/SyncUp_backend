require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "user id cannot be null" do 
  Friendship.delete_all
  	friendship = Friendship.new(:friend_id => 11)
  	assert !friendship.save, "save with no user_id"

  end

  test "friend id cannot be null" do
  Friendship.delete_all
  	friendship = Friendship.new(:user_id => 11)
  	assert !friendship.save, "save with no friend_id"

  end
end
