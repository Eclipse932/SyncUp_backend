class Api::V2::UsersController < ApplicationController

	skip_before_filter :authenticate_user_from_token!, :only => [:resetFixture, :unitTests]
	respond_to :json


	def requestFriend
		params.permit!
		friend_json = params[:friendship] #friendship contains friend_id
		if !User.exists?(:id => friend_json[:friend_id])
			renderJSON(200, false, "requested friend not a valid user") and return   
		end

		friend_json[:user_id] = current_user.id
		friend = Friendship.find_by(friend_json)
		if friend.nil?

			friend = Friendship.new(friend_json)
			friend.status = REQUESTED
			second_friend = Friendship.new(:user_id => friend_json[:friend_id], :friend_id => current_user.id, :status => PENDING)

			if friend.save and second_friend.save
				renderJSON(200, true, "request friend") and return
			else
				renderJSON(200, false, "fail to save request") and return
			end

		else
			renderJSON(200, true, "already sent request") and return
		end
	end

	
	def confirmFriend
		params.permit!
		friend_json = params[:friendship] #friendship contains the user which the current user accepts as friend and the boolean indicates
																			#whether the request is accepted or not
		request_id = friend_json[:request_id]

		friend = Friendship.find_by(:user_id => request_id, :friend_id => current_user.id)
		second_friend = Friendship.find_by(:user_id => current_user.id, :friend_id => request_id)

		if friend and second_friend

			if friend_json[:response] == true
				friend.status = ACCEPTED
				second_friend.status = ACCEPTED
				friend.save
				second_friend.save
				renderJSON(200, true, "accept friend")

			else 
				if !(friend.status == ACCEPTED && second_friend.status == ACCEPTED)
					friend.destroy
					second_friend.destroy
					renderJSON(200, true, "reject friend")
				else
					renderJSON(200, false, "invalid reject")
				end
			end

		else 
			renderJSON(200, false, "request doesn't exist")
		end
	end


	def getFriends
		friend_list = Friendship.where(:user_id => current_user.id, :status => ACCEPTED).all
		ids = friend_list.map(&:friend_id)
		renderJSON(200, true, "get all friends", User.findUser(:id => ids))
	end
		
		
	def searchUser
		permitted = params.require(:user).permit(:id, :email, :first_name, :last_name)
		users = User.findUser(permitted)
		renderJSON(200, true, "get users", users)
	end


	def deleteRequest
		params.permit!
		friend_json = params[:friendship] #friendship contains the user_id which the current user wants to delete friend request with or delete friend relationship with
		request_id = friend_json[:request_id]
		friend = Friendship.find_by(:user_id => current_user.id, :friend_id => request_id)
		second_friend = Friendship.find_by(:user_id => request_id, :friend_id => current_user.id)
		if friend and second_friend
				friend.destroy
				second_friend.destroy
				renderJSON(200, true, "delete succeeds")
		else
			renderJSON(200, true, "already deleted")
		end
	end


	def getPendingFriends
		friend_list = Friendship.where(:user_id => current_user.id, :status => PENDING).all
		ids = friend_list.map(&:friend_id)
		renderJSON(200, true, "get pending friend requests", User.findUser(:id => ids))
	end


	def getSentRequests
		friend_list = Friendship.where(:user_id => current_user.id, :status => REQUESTED).all
		ids = friend_list.map(&:friend_id)
		renderJSON(200, true, "get sent friend requests", User.findUser(:id => ids))
	end


	def createActivity
		params.permit!
		act_json = params[:activity]
		act_json[:host_id] = current_user.id
		act = Activity.new(act_json)
		if act.save
			atd = Attendee.new(:user_id => current_user.id, :activity_id => act.id, :role => HOST)
			if atd.save
				renderJSON(200, true, "create an activity", act)
			else
				renderJSON(200, false, "activity relation failed to save")
			end				
		else
			renderJSON(200, false, "activity failed to save")
		end
	end


	def myActivities
		attendees = Attendee.where(:user_id => current_user.id).all
		ids = attendees.map(&:activity_id)
		render :status => 200,
							 :json => { :success => true,
											 :info => "activites!",
											 :data => Activity.where(:id => ids).all }
	end


	def joinActivity 
			if current_user
					params.permit!
					user_json = params[:activity] #activity contains the activity_id and the end_time of the activity the user may want to join
					activity_id = user_json[:activity_id]
					activity= Activity.find_by(:id => activity_id)

					if current_user.id == activity.host_id
							render :status => 200,
													:json => { :success => true,
																			:info => "already joined activity as host"}
							return
					end

					friend = Friendship.find_by(:user_id => current_user.id, :friend_id => activity.host_id, :status => ACCEPTED)

					if friend #and DateTime.now < user_json[:end_time]
							atd = Attendee.find_by(:user_id => current_user.id, :activity_id => activity_id, :role => GUEST)
							if atd.nil?
									atd = Attendee.new(:user_id => current_user.id, :activity_id => activity_id, :role => GUEST)
									if atd.save
												render :status => 200,
													:json => { :success => true,
																			:info => "successfully join the activity"}
									else
											render :status => 200,
													:json => { :success => false,
																			:info => "cannot save attendee"}
									end
							else 
										render :status => 200,
													:json => { :success => true,
																			:info => "already joined activity"}
							end

					else
								render :status => 200,
													:json => { :success => false,
																			:info => "not friend with host, so cannot join activity"}
					end
			else
					failure
			end
	end


	def getFriendsActivities
		friends = Friendship.where(:user_id => current_user.id, :status => ACCEPTED).all
		friendsActivitiesIds = Set.new
		friends.each do |friend|
				friendsActivitiesIds += (Attendee.where(:user_id => friend.friend_id).all).map(&:activity_id)
		end
		renderJSON(200, true, "get all friends' activities", Activity.where(:id => friendsActivitiesIds.to_a).all)
	end



	#################################################
	# utility functions                             #
	#################################################
	def resetFixture
			User.delete_all
			Activity.delete_all
			Attendee.delete_all
			Friendship.delete_all
			renderJSON(200, true, "reset succeed")
	end


	def unitTests
			if Rails.env == "production"
					output = `RAILS_ENV=development ruby -Itest test/models/user_test.rb`
			else
					output = `ruby -Itest test/models/user_test.rb`
			end
			logger.debug output
			testInfo = output.split(/\n/)
			testInfo = testInfo[-1].split(", ")
			render(:json=>{"nrFailed" => testInfo[2].split()[0].to_i, "output" => output,
					"totalTests" => testInfo[0].split()[0].to_i}, status:200)
	end

end
