class Api::V1::UsersController < ApplicationController
	respond_to :json

	# below is what I add 

	def requestFriend
		if current_user
			params.permit!

			friend_json = params[:friendship] #friendship contains friend_id
            friend_json[:user_id] = current_user.id
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

                    render :status => 200,
                        :json => { :success => true,
                                :info => "accept friend",
                                :data => {} }
                else 
                    if !(friend.status == ACCEPTED && second_friend.status == ACCEPTED)
                        friend.destroy
                        second_friend.destroy
                        render :status => 200,
                            :json => { :success => true,
                                    :info => "reject friend",
                                    :data => {} }
                    else
                        render :status => 200,
                            :json => { :success => false,
                                    :info => "invalid reject",
                                    :data => {} }
                    end
                end

            else 
                render :status => 401,
                        :json => { :success => false,
                                 :info => "request doesn't exist"}
            end

		else
			failure
		end 
	end


    

    def getFriends
        if current_user
            friend_list = Friendship.find(:all, :conditions => {:user_id => current_user.id, :status => ACCEPTED})
            render :status => 200,
                :json => { :success => true,
                            :info => "get all friends",
                            :data => friend_list}

        else 
            failure
        end
    end

    
    
    def searchUser
        if current_user
            params.permit!
            friend_json = params[:user] #user contains the friend name or friend id or friend email which the current user wants to search for 
            friend = nil
            if friend_json[:name]
                friend = User.find_by(:name => friend_json[:name])

            elsif friend_json[:id]
                friend = User.find_by(:id => friend_json[:id])
            else 
                friend = User.find_by(:email => friend_json[:email])
            end

            if friend
                render :status => 200,
                :json => { :success => true,
                            :info => "find the user",
                            :data => friend}
            else
                render :status => 200,
                :json => { :success => false,
                            :info => "cannot find user",
                            :data => {}}
            end

        else 
            failure
        end
    end

    


    def deleteRequest
        if current_user
            params.permit!
            friend_json = params[:friendship] #friendship contains the user which the current user wants to delete friend request with or delete friend relation with
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
            friend_list = Friendship.find(:all, :conditions => {:user_id => current_user.id, :status => PENDING})
            render :status => 200,
                :json => { :success => true,
                            :info => "get pending friend requests",
                            :data => friend_list}

        else 
           failure
        end

    end

    


    def getSentRequests
        if current_user
            friend_list = Friendship.find(:all, :conditions => {:user_id => current_user.id, :status => REQUESTED})
            render :status => 200,
                :json => { :success => true,
                            :info => "get sent friend requests",
                            :data => friend_list}

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
			  		render :status => 401,
		           		:json => { :success => false,
		                      	 :info => "activity relation failed to save"}
		    	end
		  	end
		else
			failure
		end

	end



	def myActivities
		if current_user
		  ids = Attendee.find(:all, :conditions => {:user_id => current_user.id}).map(&:activity_id)
		  render :status => 200,
	               :json => { :success => true,
	                       :info => "activites!",
	                       :data => Activity.find(:all,
	                      	    :conditions => {:id => ids}) }
	                       # :data => current_user.activites}
        else
            failure
        end
	end

    def joinActivity 
        if current_user
            params.permit!
            user_json = params[:activity] #activity contains the activity_id the user may want to join
            activity_id = user_json[:activity_id]
            activity= Activity.find_by(:id => activity_id)
            friend = Friendship.find_by(:user_id => current_user.id, :friend_id => activity.host_id, :status => ACCEPTED)
            if friend 
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

    def failure
        render :status => 401,
            :json => { :success => false,
                        :info => "user not signed in"}
    end

	# def user_params
 #    params.require(:user).permit(:username, :email, :password, :salt, :encrypted_password)
 #  end

end
