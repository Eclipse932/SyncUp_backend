class Api::V2::ActivitiesController < ApplicationController

	def createActivity
		params.permit!
		act_json = params[:activity]
		act_json[:host_id] = current_user.id

		act = Activity.add(act_json)
		if act
			renderJSON(200, true, "created an activity", act)
		else
			renderJSON(200, false, "activity failed to creat")
		end
	end


	def myActivities
		attendees = Attendee.where(:user_id => current_user.id).all
		ids = attendees.map(&:activity_id)
		renderJSON(200, true, "get my activities", Activity.where(:id => ids).all )
	end


	def joinActivity 
		params.permit!
		act_json = params[:activity] #activity contains the activity_id and the end_time of the activity the user may want to join
		activity_id = act_json[:activity_id]
		activity= Activity.find_by(:id => activity_id)

		if current_user.id == activity.host_id
			renderJSON(200, true, "already joined activity as host")
		end

		friend = Friendship.find_by(:user_id => current_user.id, :friend_id => activity.host_id, :status => ACCEPTED)

		if friend #and DateTime.now < user_json[:end_time]
			atd = Attendee.find_by(:user_id => current_user.id, :activity_id => activity_id, :role => GUEST)
			if atd.nil?
				atd = Attendee.new(:user_id => current_user.id, :activity_id => activity_id, :role => GUEST)
				if atd.save
					renderJSON(200, true, "successfully join the activity")
				else
					renderJSON(200, true, "cannot save attendee")
				end
			else
				renderJSON(200, true, "already joined activity")
			end

		else
			renderJSON(200, false, "not friend with host, so cannot join activity")
		end
	end


	def inviteActivity
		permitted = params.permit(:user_id, :activity_id)
		permitted[:role] = PENDING
		atd = Attendee.new(permitted)
		if atd.save
			renderJSON(200, true, "invitation sent")
		else
			renderJSON(200, true, "user already involved in the activity")
		end
	end


	def confirmActivity
		permitted = params.permit(:user_id, :activity_id, :response)

		if permitted[:response] == nil
			renderJSON(200, false, "please specify response") and return 
		end

		atd = Attendee.find_by(permitted)
		if atd and atd.role == PENDING
			if permitted[:response]
				atd.role = GUEST
				atd.save
				renderJSON(200, true, "confirm to attend activity")
			else
				if atd.destroy
					renderJSON(200, true, "reject activity")
				else
					renderJSON(200, false, "unexpected error for atd destroy")
				end
			end
		else
			renderJSON(200, false, "not in the pending list") 
		end
	end


	def getActivityAttendees
		permitted = params.require(:activity).permit(:activity_id)
		act = Activity.find(permitted[:activity_id])
		if act and Activity.visible?(:user_id => current_user.id, :activity => act)
			attendee_list = Attendee.where(:activity_id => act.id, :status => GUEST).all
			ids = attendee_list.map(&:user_id)
			ids += [act.host_id]
			renderJSON(200, true, "get all attendees", User.findUser(:id => ids))
		else
			renderJSON(200, false, "activity not exists or not visible")
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

end
