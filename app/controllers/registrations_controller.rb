class RegistrationsController < ApplicationController
	
	skip_before_filter :authenticate_user_from_token!

  def create
    #################################################
    # might want to limit params for security later #
    #################################################
    params.permit!
    user = User.new(params[:user])
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
end
