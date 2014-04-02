require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
	HOST = 1
	GUEST= 2
	PENDING = 3
	REQUESTED = 4


	def test_createActivity_with_empty_name
		puts "\nCalling test_createActivity_with_empty_name"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user1["activity"] = {"name" => ""}
		post(:createActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("activity failed to creat", parsed_body["info"])

	end


	def test_createActivity_with_valid_act
		puts "\nCalling test_createActivity_with_valid_act"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user1["activity"] = {"name" => "act1"}
		post(:createActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("act1", parsed_body["data"]["name"])

	end


	def test_myActivities
		puts "\nCalling test_myActivities"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal([], parsed_body["data"])

		act1 = createActivity(user1["id"], "act1")
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act1.id]}, parsed_body["data"])

		act2 = createActivity(user1["id"], "act2")
		act3 = createActivity(user1["id"], "act3")
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act1.id, act2.id, act3.id]}, parsed_body["data"])

	end


	def test_joinActivity_with_invalid_activity
		puts "\nCalling test_joinActivity_with_invalid_activity"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')
		act1 = createActivity(user1["id"], "act1")

		user1["activity"] = {"activity_id" => act1.id-10}
		get(:joinActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("activity not valid", parsed_body["info"])

	end


	def test_joinActivity_with_inaccessible_activity
		puts "\nCalling test_joinActivity_with_inaccessible_activity"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')
		act1 = createActivity(user1["id"], "act1")

		user2["activity"] = {"activity_id" => act1.id}
		get(:joinActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("not friend with host, so cannot join activity", parsed_body["info"])

	end


	def test_joinActivity_with_valid_activity
		puts "\nCalling test_joinActivity_with_invalid_activity"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save

		act1 = createActivity(user1["id"], "act1")

		user2["activity"] = {"activity_id" => act1.id}
		get(:joinActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_not_nil(Attendee.find_by(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST))

	end


		# assert_not_nil(Friendship.find_by(:user_id => user1["id"], :friend_id => user2["id"], :status => REQUESTED))
		# assert_not_nil(Friendship.find_by(:user_id => user2["id"], :friend_id => user1["id"], :status => PENDING))
		# act = createActivity(user1["id"], "example_act")
		# puts act.start_time

 	def createUser(email, first_name="", last_name="")
		user = User.new(:email => email, :password => 'password', :password_confirmation => 'password',
										:first_name => first_name, :last_name => last_name)
		assert_not_nil(user.save)
		{ 'email' => user.email, 'token' => user.authentication_token, 'id' => user.id }
	end


	def createActivity(host_id, name, start_time="2014-04-14T05:31:14.976Z", visibility=GUEST, location="", description="")
		act = Activity.new(:host_id => host_id, :name => name, :start_time => start_time, :visibility => visibility,
										:location => location, :description => description)
		assert_not_nil(act.save)
		atd = Attendee.new(:user_id => host_id, :activity_id => act.id, :role => HOST)
		assert_not_nil(atd.save)
		act
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
