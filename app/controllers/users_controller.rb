# Returns a user's info
class UsersController < ApplicationController
  # done through devise
  before_action :authenticate_user!
  def all_related_data
    render json: current_user.all_related_data
  end
end
