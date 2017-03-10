ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!
require 'resque_unit'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all


  def sign_in_example_user
      # We login the user and return the headers since we need those to access the routes that use 
      # authenticate_user!
      post '/auth/sign_in', params: {email: "example@example3.com", password: "password"}

      token = @response.headers["access-token"]
      expiry = @response.headers["expiry"]
      client = @response.headers["client"]
      #Otherwise you might get a different number of assertions on each test
      #assert_response 200

      headers = {
                "access-token" => token,
                "token-type" => "Bearer",
                "client" => client,
                "uid" => @user.uid,
                "expiry" => expiry,
                "Content-Type": "application/json",
                "accept": "application/json"
              }
      
  end


  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include ApplicationHelper
  include Devise::Test::ControllerHelpers

end


