class ActivitiesController < ApplicationController

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
		attendees = Attendee.where(:user_id => current_user.id)
		ids = attendees.map(&:activity_id)
		acts = Activity.where("start_time IS NOT NULL").where(:id => ids)
		js = []
		acts.each do |act|
	        js += [self.getAct(act)]
		end
		renderJSON(200, true, "get my activities", js)

	end

    # Returns the current users todos.
	def myTodos
		attendees = Attendee.where(:user_id => current_user.id)
		ids = attendees.map(&:activity_id)
		acts = Activity.where(:id => ids, :host_id=> current_user.id, :start_time => nil)
		js = []
		acts.each do |act|
	        js += [self.getAct(act)]
		end
		renderJSON(200, true, "get my activities", js)
	end

	def joinActivity 
		params.permit!
		act_json = params[:activity] #activity contains the activity_id and the end_time of the activity the user may want to join
		activity_id = act_json[:activity_id]
		activity= Activity.find_by(:id => activity_id)

		if activity.nil?
			renderJSON(200, false, "activity not valid") and return
		end

		if current_user.id == activity.host_id
			renderJSON(200, true, "already joined activity as host") and return
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
		permitted = params.require(:attendee).permit(:user_id, :activity_id)
		permitted[:role] = PENDING
		if Attendee.find_by(:user_id => current_user.id, :activity_id => permitted[:activity_id], :role => HOST)
			atd = Attendee.new(permitted)
			if atd.save
				renderJSON(200, true, "invitation sent")
			else
				renderJSON(200, true, "user already involved in the activity")
			end
		else
			renderJSON(200, false, "don't have right to invite")
		end
	end


	def confirmActivity
		permitted = params.require(:attendee).permit(:user_id, :activity_id)
		response = params[:attendee][:response]
		if response == nil
			renderJSON(200, false, "please specify response") and return 
		end

		atd = Attendee.find_by(permitted)
		if atd and atd.role == PENDING
			if response
				atd.role = GUEST
				atd.save
				renderJSON(200, true, "confirm to attend activity")
			else
				atd.role = DECLINED
				atd.save
				renderJSON(200, true, "reject activity")
			end
		else
			renderJSON(200, false, "not in the pending list") 
		end
	end


	def getActivityAttendees
		permitted = params.require(:activity).permit(:activity_id)
		act = Activity.find_by(:id => permitted[:activity_id])
		if act and Activity.visible?(current_user.id, act)
			attendee_list = Attendee.where(:activity_id => act.id)
			ids = attendee_list.map(&:user_id)
			roles = attendee_list.map(&:role);
			renderJSON(200, true, "get all attendees", {:users => User.findUser(:id => ids), :roles => roles})
		else
			renderJSON(200, false, "activity not exists or not visible")
		end
	end

	def getTodoFollowers
		permitted = params.require(:activity).permit(:activity_id)
		act = Activity.find_by(:id => permitted[:activity_id])
		if act and Activity.visible?(current_user.id, act)
			attendee_list = Attendee.where(:activity_id => act.id, :role => GUEST)
			ids = attendee_list.map(&:user_id)
			#ids += [act.host_id]
			renderJSON(200, true, "get all attendees", User.findUser(:id => ids))
		else
			renderJSON(200, false, "activity not exists or not visible")
		end
	end



	def getFriendsActivities
		friends = Friendship.where(:user_id => current_user.id, :status => ACCEPTED)
		friendsActivitiesIds = Set.new
		friends.each do |friend|
				friendsActivitiesIds += (Attendee.where(:user_id => friend.friend_id)).map(&:activity_id)
		end
		#renderJSON(200, true, "get all friends' activities", Activity.where(:id => friendsActivitiesIds.to_a).where("start_time IS NOT NULL"))
        activities = Activity.where(:id => friendsActivitiesIds.to_a).where("start_time IS NOT NULL")
        names = []
        js = []
        activities.each do |activity|
            names.push ( User.find_by(:id=>activity.host_id).first_name + " " + User.find_by(:id=>activity.host_id).last_name)
            js += [getAct(activity)]
        end
             
		renderJSON(200, true, "get all friends' activities", {:activities=>js,
                                                        :names=>names})

	end

	def getFriendsTodos
		friends = Friendship.where(:user_id => current_user.id, :status => ACCEPTED)
		friendsActivitiesIds = Set.new
		friends.each do |friend|
				friendsActivitiesIds += (Attendee.where(:user_id => friend.friend_id, :role=>1)).map(&:activity_id)
		end
		#renderJSON(200, true, "get all friends' todos", Activity.where(:id => friendsActivitiesIds.to_a, :start_time => nil))
        activities = Activity.where(:id => friendsActivitiesIds.to_a, :start_time => nil)
        names = []
        js = []
        activities.each do |activity|
            names.push ( User.find_by(:id=>activity.host_id).first_name + " " + User.find_by(:id=>activity.host_id).last_name)
            js += [getAct(activity)]
        end
             
		renderJSON(200, true, "get all friends' activities", {:activities=>js,
                                                        :names=>names})

	end

	def myUpcomingActivities
		attendees = Attendee.where(:user_id => current_user.id)
		ids = attendees.map(&:activity_id)
		acts = Activity.where(:id => ids, :start_time => Date.today..Date.today.next_month)
		js = []
		acts.each do |act|
			js += [self.getAct(act)]
		end

		renderJSON(200, true, "activities!", js)
	end

	def updateActivityRole
		atd = Attendee.find_by(:activity_id => params[:attendee][:activity_id], :user_id => current_user.id)
		if atd
			requestedRole = params[:attendee][:role].to_i
			if atd.role == HOST || (requestedRole < HOST)
				renderJSON(200, false, "can't change host role")
			else
				atd.role = requestedRole
				atd.save
				renderJSON(200, true, "actvitiy role updated")
			end
			
		else
			renderJSON(200, false, "attendee not exists")
		end

	end


	def getActivity
		params.permit!
		activity_id = params[:activity_id]
		activity = Activity.find_by(:id => activity_id)
		act = self.getAct(activity)
		isHost = false
		if current_user.id == activity.host_id
				isHost = true
		end

		if isHost
				render :status => 200, :json => {:success => true,
																				 :info => {:is_host => true},
																				 :data => act }
		else
				render :status => 200, :json => {:success => true,
																				 :info => {:is_host => false},
																				 :data => act }
		end
	end

	def getAct(act)
		entry = act.as_json
		if act.photo.exists?
			entry[:photo_thumbnail] = act.photo.url(:thumb)
			entry[:photo_medium] = act.photo.url(:medium)
			entry[:photo_original] = act.photo.url(:original)
		end
		return entry
	end


	def deleteActivity
		params.permit!
		activity_json = params[:activity]
		activity_id = activity_json[:activity_id]
		activity = Activity.find_by(:id => activity_id)
		if activity.nil?
			renderJSON(200, true, "activity already deleted whooo")
		else 
			if activity.host_id == current_user.id
				activity.destroy
				attendees = Attendee.where(:activity_id => activity_id)
				attendees.each do |attendee|
	        		attendee.destroy
				end
				renderJSON(200, true, "host delete the activity")
			else
				guest = Attendee.where(:activity_id => activity_id,:user_id => current_user.id)
				guest.each do |gst|					
					if gst.nil?
						renderJSON(200, true, "guest already not going to the activity")
					else
						gst.destroy
						renderJSON(200,true, "guest decides not to go to the activity")
					end
				end
			end
		end
	end


end

