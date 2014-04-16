require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
	HOST = 1
	GUEST= 2
	DECLINED = 4

	STARRED = 1
	ACCEPTED = 2
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
		act1 = createActivity(user1["id"], "act1", :start_time => nil)
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal([], parsed_body["data"])

		act2 = createActivity(user1["id"], "act2")
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act2.id]}, parsed_body["data"])

		act3 = createActivity(user1["id"], "act3")
		act4 = createActivity(user1["id"], "act4")
		get(:myActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act2.id, act3.id, act4.id]}, parsed_body["data"])

	end


	def test_myTodos
		puts "\nCalling test_myTodos"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		act1 = createActivity(user1["id"], "act1", :start_time => nil)
		get(:myTodos, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act1.id]}, parsed_body["data"])

		act2 = createActivity(user1["id"], "act2")
		get(:myTodos, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act1.id]}, parsed_body["data"])

		act3 = createActivity(user1["id"], "act3", :start_time => nil)
		act4 = createActivity(user1["id"], "act4", :start_time => nil)
		get(:myTodos, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({'id' => [act1.id, act3.id, act4.id]}, parsed_body["data"])

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


	def test_inviteActivity_with_already_joined_user
		puts "\nCalling test_inviteActivity_with_already_joined_user"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		user1["attendee"] = {"user_id" => user2["id"], "activity_id" => act1.id}
		post(:inviteActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("user already involved in the activity", parsed_body["info"])
	end


	def test_inviteActivity_with_not_host
		puts "\nCalling test_inviteActivity_with_not_host"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		user2["attendee"] = {"user_id" => user1["id"], "activity_id" => act1.id}
		post(:inviteActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("don't have right to invite", parsed_body["info"])
	end


	def test_inviteActivity_with_valid_invite
		puts "\nCalling test_inviteActivity_with_valid_invite"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")

		user1["attendee"] = {"user_id" => user2["id"], "activity_id" => act1.id}
		post(:inviteActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_equal("invitation sent", parsed_body["info"])
		assert_not_nil(Attendee.find_by(:user_id => user2["id"], :activity_id => act1.id, :role => PENDING))
	end


	def test_confirmActivity_with_invalid_request
		puts "\nCalling test_confirmActivity_with_invalid_request"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => PENDING)
		assert_not_nil(atd.save)

		user2["attendee"] = {"user_id" => user1["id"], "activity_id" => act1.id}
		post(:confirmActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("please specify response", parsed_body["info"])
	end


	def test_confirmActivity_with_yes_response
		puts "\nCalling test_confirmActivity_with_yes_response"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => PENDING)
		assert_not_nil(atd.save)

		user2["attendee"] = {"user_id" => user2["id"], "activity_id" => act1.id, "response" => true}
		post(:confirmActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_not_nil(Attendee.find_by(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST))

	end

	def test_confirmActivity_with_no_response
		puts "\nCalling test_confirmActivity_with_no_response"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f1.save
		f2.save
		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => PENDING)
		assert_not_nil(atd.save)

		user2["attendee"] = {"user_id" => user2["id"], "activity_id" => act1.id, "response" => false}
		post(:confirmActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		attendee = Attendee.find_by(:user_id => user2["id"], :activity_id => act1.id)
		assert_not_nil(attendee)
		assert_equal(DECLINED, attendee.role)
		
	end


	def test_getActivityAttendees_with_invalid_activity
		puts "\nCalling test_getActivityAttendees_with_invalid_activity"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f4 = Friendship.new(:user_id => user2["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f1.save
		f2.save
		f3.save
		f4.save

		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)
		atd = Attendee.new(:user_id => user3["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		user1["activity"] = {"activity_id" => 12345845} 
		post(:getActivityAttendees, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(false, parsed_body["success"])
		assert_equal("activity not exists or not visible", parsed_body["info"])

	end


	def test_getActivityAttendees_with_valid_activity
		puts "\nCalling test_getActivityAttendees_with_invalid_activity"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f4 = Friendship.new(:user_id => user2["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f1.save
		f2.save
		f3.save
		f4.save

		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)
		atd = Attendee.new(:user_id => user3["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		user1["activity"] = {"activity_id" => act1.id} 
		post(:getActivityAttendees, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [user1["id"], user2["id"], user3["id"]]}, parsed_body["data"])

	end


	def test_getFriendsActivities_1
		puts "\nCalling test_getFriendsActivities_1"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f4 = Friendship.new(:user_id => user1["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f1.save
		f2.save
		f3.save
		f4.save

		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)
		atd = Attendee.new(:user_id => user3["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		act2 = createActivity(user2["id"], "act2")
		act3 = createActivity(user3["id"], "act3")
		act4 = createActivity(user3["id"], "act4", :start_time => nil)
		act5 = createActivity(user3["id"], "act5", :start_time => nil)
		act6 = createActivity(user2["id"], "act6", :start_time => nil)


		get(:getFriendsActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act1.id, act2.id, act3.id]}, parsed_body["data"])

	end


	def test_getFriendsActivities_2
		puts "\nCalling test_getFriendsActivities_2"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f4 = Friendship.new(:user_id => user1["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f1.save
		f2.save
		f3.save
		f4.save

		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)
		atd = Attendee.new(:user_id => user3["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		act2 = createActivity(user2["id"], "act2")
		act3 = createActivity(user3["id"], "act3")
		act4 = createActivity(user3["id"], "act4", :start_time => nil)
		act5 = createActivity(user3["id"], "act5", :start_time => nil)
		act6 = createActivity(user2["id"], "act6", :start_time => nil)
		get(:getFriendsActivities, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act1.id]}, parsed_body["data"])

	end


	def test_getFriendsActivities
		puts "\nCalling test_getFriendsActivities"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')
		user3 = createUser('user3@example.com', 'orange', 'juice')

		f1 = Friendship.new(:user_id => user1["id"], :friend_id => user2["id"], :status => ACCEPTED)
		f2 = Friendship.new(:user_id => user2["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f3 = Friendship.new(:user_id => user3["id"], :friend_id => user1["id"], :status => ACCEPTED)
		f4 = Friendship.new(:user_id => user1["id"], :friend_id => user3["id"], :status => ACCEPTED)
		f1.save
		f2.save
		f3.save
		f4.save

		act1 = createActivity(user1["id"], "act1")
		atd = Attendee.new(:user_id => user2["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)
		atd = Attendee.new(:user_id => user3["id"], :activity_id => act1.id, :role => GUEST)
		assert_not_nil(atd.save)

		act2 = createActivity(user2["id"], "act2")
		act3 = createActivity(user3["id"], "act3")
		act4 = createActivity(user3["id"], "act4", :start_time => nil)
		act5 = createActivity(user3["id"], "act5", :start_time => nil)
		act6 = createActivity(user2["id"], "act6", :start_time => nil)


		get(:getFriendsTodos, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act4.id, act5.id, act6.id]}, parsed_body["data"])

	end


	def test_myUpcomingActivities
		puts "\nCalling test_myUpcomingActivities"

		user1 = createUser('user1@example.com', 'apple', 'pie')

		act1 = createActivity(user1["id"], "act1")
		act3 = createActivity(user1["id"], "act3", :start_time => "2014-05-14T05:31:14.976Z")
		act4 = createActivity(user1["id"], "act4", :start_time => nil)

		get(:myUpcomingActivities, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act1.id]}, parsed_body["data"])

	end


	def test_getActivity_with_host
		puts "\nCalling test_getActivity_with_host"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		act1 = createActivity(user1["id"], "act1")
		act3 = createActivity(user1["id"], "act3", :start_time => "2014-05-14T05:31:14.976Z")
		act4 = createActivity(user1["id"], "act4", :start_time => nil)

		user1["activity_id"] = act1.id
		user2["activity_id"] = act3.id

		get(:getActivity, user1)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act1.id]}, parsed_body["data"])

	end


	def test_getActivity_with_guest
		puts "\nCalling test_getActivity_with_guest"

		user1 = createUser('user1@example.com', 'apple', 'pie')
		user2 = createUser('user2@example.com', 'apple', 'juice')

		act1 = createActivity(user1["id"], "act1")
		act3 = createActivity(user1["id"], "act3", :start_time => "2014-05-14T05:31:14.976Z")
		act4 = createActivity(user1["id"], "act4", :start_time => nil)

		user1["activity_id"] = act1.id
		user2["activity_id"] = act3.id

		get(:getActivity, user2)
		parsed_body = JSON.parse(response.body)
		assert_equal(true, parsed_body["success"])
		assert_json_list_contain({"id" => [act3.id]}, parsed_body["data"])

	end


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
