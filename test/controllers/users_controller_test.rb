require 'test_helper'

class UsersControllerTest < ActionController::TestCase
	include Devise::TestHelpers
  # test "the truth" do
  #   assert true
  # end
  def test_create_with_empty_email
		puts "\nCalling test_create_with_empty_email"

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => '', 'password' => 'password', 'password_confirmation' => 'password' }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

	end


	def test_create_with_bad_format_email
		puts "\nCalling test_create_with_bad_format_email"

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'abcdgmail.com', 'password' => 'password', 'password_confirmation' => 'password' }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'abcd@gmailcom', 'password' => 'password', 'password_confirmation' => 'password' }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

	end


	def test_create_with_password_too_long
		puts "\nCalling test_create_with_password_too_long"

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'abcdgmail.com', 'password' => 'p'*129, 'password_confirmation' => 'p'*129 }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

	end


	def test_create_with_password_too_long
		puts "\nCalling test_create_with_password_too_long"

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'abcd@gmail.com', 'password' => 'p'*129, 'password_confirmation' => 'p'*129 }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

	end


	def test_create_with_existing_user
		puts "\nCalling test_create_with_existing_user"

		createUser('abc@hi.com')
		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'abc@hi.com', 'password' => 'p'*100, 'password_confirmation' => 'p'*100 }})
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])

	end


	def test_create_with_valid_user
		puts "\nCalling test_create_with_valid_user"

		@request.headers["Accept"] = "application/json"
		post(:create, {'user' => { 'email' => 'user1@example.com', 'password' => 'password', 'password_confirmation' => 'password',
																'description' => 'this is an example user' }})
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("user1@example.com", parsed_body["data"]["email"])
		assert_not_nil(User.find_by(:email => "user1@example.com"))

	end


	def test_searchUser
		puts "\nCalling test_searchUser"

		request_json = createUser('user1@example.com', 'apple', 'pie')
		request_json['user'] = { 'email' => 'user1@example.com'}
		post(:searchUser, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])

		get(:getMyProfile, request_json)
		puts response.body
		request_json['user'] = { 'description' => 'this is an example user' }
		post(:updateMyProfile, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		
		get(:getMyProfile, request_json)
		puts response.body

	end





	def createUser(email, first_name="", last_name="")
		user = User.new(:email => email, :password => 'password', :password_confirmation => 'password',
										:first_name => first_name, :last_name => last_name)
		assert_not_nil(user.save)
		{ 'email' => user.email, 'token' => user.authentication_token }
	end




end
