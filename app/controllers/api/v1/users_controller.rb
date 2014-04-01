class Api::V1::UsersController < ApplicationController
	respond_to :json

	# below is what I add 

	def requestFriend
		if current_user
			params.permit!

			friend_json = params[:friendship] #friendship contains friend_id
            friend_json[:user_id] = current_user.id
            friend = Friendship.find_by(:user_id => current_user.id, :friend_id => friend_json[:friend_id])
            if friend.nil? and User.find_by(:id => friend_json[:friend_id])
			     friend = Friendship.new(friend_json)
                 friend.status = REQUESTED

                 second_friend = Friendship.new(:user_id => friend_json[:friend_id], :friend_id => current_user.id, :status => PENDING)
			     if friend.save and second_friend.save
				    render :status => 200,
					   :json => { :success => true,
			                     :info => "request friend"}
                 else 
                    render :status => 200,
                        :json => { :success => false,
                                :info => "fail to save request"}
            
			     end
            else 
                 if User.find_by(:id => friend_json[:friend_id])
                    render :status => 200,
                       :json => { :success => true,
                                 :info => "already sent request"}
                 else    
                    render :status => 200,
                       :json => { :success => false,
                                 :info => "request friend not a valid user"}
                 end
            end
		else 
			failure
		end

	end

	
    def confirmFriend
		if current_user
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
                    render :status => 200,
                        :json => { :success => true,
                                :info => "accept friend"}
                else 
                    if !(friend.status == ACCEPTED && second_friend.status == ACCEPTED)
                        friend.destroy
                        second_friend.destroy
                        render :status => 200,
                            :json => { :success => true,
                                    :info => "reject friend"}
                    else
                        render :status => 200,
                            :json => { :success => false,
                                    :info => "invalid reject"}
                    end
                end

            else 
                render :status => 200,
                        :json => { :success => false,
                                 :info => "request doesn't exist"}
            end

		else
			failure
		end 
	end


    

    def getFriends
        if current_user
            friend_list = Friendship.where(:user_id => current_user.id, :status => ACCEPTED).all
            ids = friend_list.map(&:friend_id)
            render :status => 200,
                :json => { :success => true,
                            :info => "get all friends",
                            :data => User.select("first_name, email, id, description").where(:id => ids).all}

        else 
            failure
        end
    end

    
    
    def searchUser
        if current_user
            params.permit!
            friend_json = params[:user] #user contains the friend name or friend id or friend email which the current user wants to search for 
            
            if friend_json[:first_name]
                friend = User.select("first_name, email, id, description").where(:first_name => friend_json[:first_name]).all
                render :status => 200,
                    :json => { :success => true,
                            :info => "find user by name",
                            :data => friend}
            elsif friend_json[:id]
                friend = User.select("first_name, email, id, description").find_by(:id => friend_json[:id])
                render :status => 200,
                    :json => { :success => true,
                            :info => "find user by id",
                            :data => [friend]}

            elsif friend_json[:email]
                friend = User.select("first_name, email, id, description").find_by(:email => friend_json[:email])
                render :status => 200,
                    :json => { :success => true,
                            :info => "find user by email",
                            :data => [friend]}

            else
                render :status => 200,
                    :json => { :success => false,
                            :info => "cannot find user"}
            end
        else 
            failure
        end
    end

    


    def deleteRequest
        if current_user
            params.permit!
            friend_json = params[:friendship] #friendship contains the user_id which the current user wants to delete friend request with or delete friend relationship with
            request_id = friend_json[:request_id]
            friend = Friendship.find_by(:user_id => current_user.id, :friend_id => request_id)
            second_friend = Friendship.find_by(:user_id => request_id, :friend_id => current_user.id)
            if friend and second_friend
                friend.destroy
                second_friend.destroy
                render :status => 200,
                    :json => { :success => true,
                            :info => "delete succeeds"}
            else 
                 render :status => 200,
                    :json => { :success => true,
                            :info => "already deleted"}
            end
        else
            failure
        end
    end


    def getPendingFriends
        if current_user
            friend_list = Friendship.where(:user_id => current_user.id, :status => PENDING).all
            ids = friend_list.map(&:friend_id)
            render :status => 200,
                :json => { :success => true,
                            :info => "get pending friend requests",
                            :data => User.select("first_name, email, id, description").where(:id => ids).all}

        else 
           failure
        end

    end

    


    def getSentRequests
        if current_user
            friend_list = Friendship.where(:user_id => current_user.id, :status => REQUESTED).all
            ids = friend_list.map(&:friend_id)
            render :status => 200,
                :json => { :success => true,
                            :info => "get sent friend requests",
                            :data => (User.select("first_name, email, id, description").where(:id => ids).all)}

        else 
            failure
        end        

    end


	def createActivity
		if current_user

			#################################################
			# might want to limit params for security later #
			#################################################
			params.permit!


			act_json = params[:activity]
			act_json[:host_id] = current_user.id
			act = Activity.new(act_json)
			if act.save
				atd = Attendee.new(:user_id => current_user.id, :activity_id => act.id, :role => HOST)
				if atd.save
					render :status => 200,
			           :json => { :success => true,
			                      :info => "Create an activity",
			                      :data => act }
			  	else
			  		render :status => 200,
		           		:json => { :success => false,
		                      	 :info => "activity relation failed to save"}
		    	end
		    	
		    else
		    		failure
		  	end
		else
			failure
		end

	end



	def myActivities
		if current_user
          attendees = Attendee.where(:user_id => current_user.id).all
		  ids = attendees.map(&:activity_id)
		  render :status => 200,
	               :json => { :success => true,
	                       :info => "activites!",
	                       :data => Activity.where(:id => ids).all }
	                       # :data => current_user.activites}
        else
            failure
        end
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
        if current_user
            friends = Friendship.where(:user_id => current_user.id, :status => ACCEPTED).all
            friendsActivitiesIds = Set.new
            friends.each do |friend|
                friendsActivitiesIds += (Attendee.where(:user_id => friend.friend_id).all).map(&:activity_id)
            end

             render :status => 200,
                            :json => { :success => true,
                                        :info => "get all friend activities",
                                        :data => Activity.where(:id => friendsActivitiesIds.to_a).all}
        else
            failure
        end
    end

    #################################################
    # utility functions                             #
    #################################################

    def failure
        render :status => 200,
            :json => { :success => false,
                        :info => "user not signed in"}
    end
    
    def resetFixture
        User.delete_all
        Activity.delete_all
        Attendee.delete_all
        Friendship.delete_all
        render :status => 200,
            :json => { :success => false,
                        :info => "reset succeed"}
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
