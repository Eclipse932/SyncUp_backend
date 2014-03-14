require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "reset user" do
  	User.reset
		user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1")
		assert user.save, "Adding user failed"
		User.reset
		assert User.all.empty?, "User table reset failed"
	end

	test "create user" do
  	User.reset
		user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1")
		assert user.save, "Adding user failed"
		assert !user.authentication_token.nil?, "Adding authentication_token failed"
	end

	test "authenticate user" do
  	User.reset
		user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1")
		assert user.save, "Adding user failed"
		assert !User.authenticate({:email => "u1@example.com",
															:password => "p2"}), "Error Authentication"
		assert !User.authenticate({:email => "u2@example.com",
															:password => "p1"}), "Error Authentication"
		assert User.authenticate({:email => "u1@example.com",
															:password => "p1"}), "Error Authentication"
	end



end
