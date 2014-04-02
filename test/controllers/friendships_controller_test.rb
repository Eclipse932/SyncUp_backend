require 'test_helper'

class FriendshipsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	STARRED = 1
	ACCEPTED = 2
	PENDING = 3
	REQUESTED = 4


	def test_requestFriend_with_valid_request
		puts "\nCalling test_requestFriend_with_valid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		user1["friendship"] = {"friend_id" => user2["id"]}
		post(:requestFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("request friend", parsed_body["info"])
		assert_not_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED))
		assert_not_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING))

	end


	def test_requestFriend_with_repeted_request
		puts "\nCalling test_requestFriend_with_repeted_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f1.save
		f2.save

		user1["friendship"] = {"friend_id" => user2["id"]}
		post(:requestFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("already sent request", parsed_body["info"])
		assert_not_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED))
		assert_not_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING))

	end


	def test_requestFriend_with_invalid_request
		puts "\nCalling test_requestFriend_with_invalid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		user1["friendship"] = {"friend_id" => 987654321}
		post(:requestFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("requested friend not a valid user", parsed_body["info"])
		assert_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => 987654321, :status => REQUESTED))
		assert_nil(Friendship.find_by(:user_id => 987654321, :friend_id => user1["id"], :status => PENDING))

	end


	def test_confirmFriend_with_invalid_request
		puts "\nCalling test_confirmFriend_with_invalid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		user1["friendship"] = {"request_id" => user2["id"], "response" => true}
		post(:confirmFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("request doesn't exist", parsed_body["info"])
		assert_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"]))
		assert_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"]))

	end


	def test_confirmFriend_with_yes_response
		puts "\nCalling test_confirmFriend_with_invalid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f1.save
		f2.save

		user1["friendship"] = {"request_id" => user2["id"], "response" => true}
		post(:confirmFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_not_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED))
		assert_not_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED))

	end


	def test_confirmFriend_with_no_response
		puts "\nCalling test_confirmFriend_with_invalid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f1.save
		f2.save

		user1["friendship"] = {"request_id" => user2["id"], "response" => false}
		post(:confirmFriend, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"]))
		assert_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"]))

	end


	def test_getFriends
		puts "\nCalling test_getFriends"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')


		get(:getFriends, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal([], parsed_body["data"])

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f1.save
		f2.save

		get(:getFriends, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal([], parsed_body["data"])

		Friendship.update(f1.id, :status => ACCEPTED)
		Friendship.update(f2.id, :status => ACCEPTED)
		f1.save
		f2.save

		get(:getFriends, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [user2["id"]]}, parsed_body["data"])

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user3["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save

		get(:getFriends, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [user2["id"], user3["id"]]}, parsed_body["data"])

	end


	def test_deleteRequest
		puts "\nCalling test_deleteRequest"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f1.save
		f2.save

		user1["friendship"] = {"request_id" => user2["id"]}
		post(:deleteRequest, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"]))
		assert_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"]))

	end


	def test_getPendingFriends
		puts "\nCalling test_getPendingFriends"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user2["id"], :status => REQUESTED)
		f4 = Friendship.new(:user_id => user2["id"], :friend_id => user3["id"], :status => PENDING)
		f1.save
		f2.save
		f3.save
		f4.save

		get(:getPendingFriends, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [user1["id"], user3["id"]]}, parsed_body["data"])

	end


	def test_getSentRequests
		puts "\nCalling test_getSentRequests"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user2["id"], :status => REQUESTED)
		f4 = Friendship.new(:user_id => user2["id"], :friend_id => user3["id"], :status => PENDING)
		f1.save
		f2.save
		f3.save
		f4.save

		get(:getSentRequests, user3)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [user2["id"]]}, parsed_body["data"])

	end












	def createUser(email, first_name="", last_name="")
		user = User.new(:email => email, :password => 'password', :password_confirmation => 'password',
										:first_name => first_name, :last_name => last_name)
		assert_not_nil(user.save)
		{ 'email' => user.email, 'token' => user.authentication_token, 'id' => user.id }
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
