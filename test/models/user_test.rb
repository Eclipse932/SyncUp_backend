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

	test "validate uniqueness of user" do
	User.reset
		user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1")
		assert user.save, "Adding user failed"
		user = User.new(:email => "u1@example.com", :password => "p2", :password_confirmation => "p2")
		assert !user.save, "duplicate user is accepted"
	end
    
    test "find user" do 
    User.reset
    	user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1", :first_name  => "Jane", :last_name => "Huang", :description => "a female code monkey")
		assert user.save, "Adding user failed"
		resultList = User.findUser({"email" => "u1@example.com"})
		result = resultList[0]
		assert_equal(result.first_name, user.first_name, "first name returned is different from expected")
		assert_equal(result.last_name, user.last_name, "last name returned is diffferent from expected")
		assert_equal(result.description, user.description, "description returned is diffferent from expected")
		assert_equal(result.id, user.id, "id returned is diffferent from expected")

		resultList = User.findUser({"first_name" => "Jane"})
		result = resultList[0]
		assert_equal(result.first_name, user.first_name, "first name returned is different from expected")
		assert_equal(result.last_name, user.last_name, "last name returned is diffferent from expected")
		assert_equal(result.description, user.description, "description returned is diffferent from expected")
		assert_equal(result.id, user.id, "id returned is diffferent from expected")

		resultList = User.findUser({"last_name" => "Huang"})
		result = resultList[0]
		assert_equal(result.first_name, user.first_name, "first name returned is different from expected")
		assert_equal(result.last_name, user.last_name, "last name returned is diffferent from expected")
		assert_equal(result.description, user.description, "description returned is diffferent from expected")
		assert_equal(result.id, user.id, "id returned is diffferent from expected")

		resultList = User.findUser({"id" => user.id})
		result = resultList[0]
		assert_equal(result.first_name, user.first_name, "first name returned is different from expected")
		assert_equal(result.last_name, user.last_name, "last name returned is diffferent from expected")
		assert_equal(result.description, user.description, "description returned is diffferent from expected")
		assert_equal(result.id, user.id, "id returned is diffferent from expected")

    end

    

end
