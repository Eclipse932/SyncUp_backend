require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  user = User.new(:email => "u1@example.com", :password => "p1", :password_confirmation => "p1", :first_name  => "Jane", :last_name => "Huang", :description => "a female code monkey")
	  
end
