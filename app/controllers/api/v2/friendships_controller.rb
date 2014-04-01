class Api::V2::FriendshipsController < ApplicationController

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
	
end
