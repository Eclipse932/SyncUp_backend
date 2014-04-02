require 'test_helper'

class UsersControllerTest < ActionController::TestCase
	include Devise::TestHelpers


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


	def test_getMyProfile
		puts "\nCalling test_getMyProfile"

		request_json = createUser('user1@example.com', 'apple', 'pie')
		get(:getMyProfile, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal('apple', parsed_body["data"]["first_name"])
		assert_equal('pie', parsed_body["data"]["last_name"])
		assert_equal('user1@example.com', parsed_body["data"]["email"])

	end

	def test_updateMyProfile
		puts "\nCalling test_updateMyProfile"

		request_json = createUser('user1@example.com', 'apple', 'pie')

		get(:getMyProfile, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal(nil, parsed_body["data"]["description"])

		request_json['user'] = { 'description' => 'this is an example user' }
		post(:updateMyProfile, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])

		get(:getMyProfile, request_json)
		parsed_body = JSON.parse(response.body)
		assert_equal('this is an example user', parsed_body["data"]["description"])

	end


	def test_searchUser
		puts "\nCalling test_searchUser"

		request_json = createUser('user1@example.com', 'apple', 'pie')
		createUser('user2@example.com', 'apple', 'juice')
		createUser('user3@example.com', 'orange', 'juice')
		createUser('user4@example.com', 'chocolate', 'shake')

		request_json['user'] = { 'email' => 'user4@example.com'}
		post(:searchUser, request_json)
		parsed_body = JSON.parse(response.body)
		assert_json_list_contain({"email" => ['user4@example.com']}, parsed_body["data"])

		request_json['user'] = { 'first_name' => 'apple'}
		post(:searchUser, request_json)
		parsed_body = JSON.parse(response.body)
		assert_json_list_contain({"email" => ['user1@example.com', 'user2@example.com']}, parsed_body["data"])

		request_json['user'] = { 'first_name' => 'apple', 'last_name' => 'juice'}
		post(:searchUser, request_json)
		parsed_body = JSON.parse(response.body)
		assert_json_list_contain({"email" => ['user2@example.com']}, parsed_body["data"])

		request_json['user'] = { 'last_name' => 'juice'}
		post(:searchUser, request_json)
		parsed_body = JSON.parse(response.body)
		assert_json_list_contain({"email" => ['user2@example.com', 'user3@example.com']}, parsed_body["data"])
	end



	def createUser(email, first_name="", last_name="")
		user = User.new(:email => email, :password => 'password', :password_confirmation => 'password',
										:first_name => first_name, :last_name => last_name)
		assert_not_nil(user.save)
		{ 'email' => user.email, 'token' => user.authentication_token }
	end


	def assert_json_list_contain(data, list)
		assert list!=[]
		data.each do |key, entries|
			assert list[0].has_key?(key)
			temp_list = []
			list.each do |record|
				temp_list += [record[key]]
			end
			assert_equal(entries, temp_list)
		end
	end





end
