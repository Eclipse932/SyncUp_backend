class UsersController < ApplicationController

	skip_before_filter :authenticate_user_from_token!, :except => [:searchUser]
	respond_to :json


	def create
    permitted = params.require(:user).permit(:email, :first_name, :last_name, :description, :avatar,
    																				 :password, :password_confirmation)
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
		permitted = params.require(:user).permit(:id, :email, :first_name, :last_name)
		users = User.findUser(permitted)
		renderJSON(200, true, "get users", users)
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
