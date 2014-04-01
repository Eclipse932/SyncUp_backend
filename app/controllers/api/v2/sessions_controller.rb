class Api::V2::SessionsController < Devise::SessionsController

	skip_before_filter :authenticate_user_from_token!, :only => [:create]
  respond_to :json

  def create
    user = User.authenticate(params[:user])
    if user
    	sign_in user
	    render :status => 200,
	           :json => { :success => true,
	                      :info => "Logged in",
	                      :data => { :auth_token => current_user.authentication_token,
                                   :email => current_user.email,
                                   :user => user }}
                                   # :user => Base64.encode64(open(user.avatar.path(:thumbnail)){ |io| io.read })} }
    else
    	failure
    end

  end

  def destroy
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    current_user.update_column(:authentication_token, nil)
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }
  end

  def failure
    render :status => 200,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end
end
