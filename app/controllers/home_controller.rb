class HomeController < ApplicationController
  def index
    @users = User.all
  end

  def activity_params
      params.require(:user).permit(:id, :name, :description, :avatar)
  end
end
