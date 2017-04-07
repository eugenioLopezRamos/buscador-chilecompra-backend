# Overrides for devise token auth TokenValidationsController
class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
  # TODO: decide how to present this
  def render_validate_token_success
    render json: { data: @resource } # Could also be user.all_related_data
  end
end
