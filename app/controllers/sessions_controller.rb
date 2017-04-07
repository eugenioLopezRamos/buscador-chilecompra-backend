# Returns devise token auth session info wrapped under key [:data]
class SessionsController < DeviseTokenAuth::SessionsController
  def new; end

  # TODO: Decide how to present this
  def render_create_success
    # @resource is given by devise_token_auth!
    # @user_data = @resource.as_json
    # @user_data[:searches] = @resource.searches
    # @user_data[:subscriptions] = @resource.subscriptions
    # @user_data[:notifications] = @resource.notifications
    # binding.pry
    render json: { data: @resource } # .get_all_related_data}
  end
end
