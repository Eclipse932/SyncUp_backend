class UsersController < ApplicationController

	skip_before_filter :authenticate_user_from_token!, :only => [:create, :resetFixture,:unitTests]
	respond_to :json


	def create
        permitted = params.require(:user).permit(:email, :first_name, :last_name, :description, :avatar,
                                                                                         :password, :password_confirmation, :phone_number)
        user = User.new(permitted)
        if user.save
          sign_in user
          render :status => 200,
               :json => { :success => true,
                          :info => "Registered",
                          :data => { :auth_token => current_user.authentication_token,
                                     :email => current_user.email,
                                     :user => user} }
        else
          render :status => :unprocessable_entity,
                 :json => { :success => false,
                            :info => user.errors,
                            :data => {} }
        end
    end
		

	def searchUser
		user = params[:user]
		prefix = user[:email]
		users = User.findApproximateUser(prefix)
		filtered_users = users.reject {|user| current_user.id == user.id}
		renderJSON(200, true, "get users", filtered_users)
	end


	def getMyProfile
		user = User.select("first_name, last_name, email, id, description, phone_number, avatar_file_name, last_sign_in_at").find(current_user.id)

		if current_user.avatar.exists?
			user[:avatar] = Base64.encode64(open(current_user.avatar.path(:thumbnail)){ |io| io.read })
		end
		renderJSON(200, true, "get my profile", user)
	end

	def updateMyProfile
		permitted = params.require(:user).permit(:first_name, :last_name, :description, :phone_number)
		User.update(current_user.id, permitted)
		renderJSON(200, true, "profile updated")
	end

	def updatePassword
		user = User.authenticate(:email => params[:email], :password => params[:user][:current_password])
		if current_user == user
			permitted = params.require(:user).permit(:password, :password_confirmation)
			if user.update(permitted)
				renderJSON(200, true, "password updated")
			else
				renderJSON(200, false, "password and password_confirmation are not the same")
			end
		else
			renderJSON(200, false, "wrong password")
		end
	end

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
