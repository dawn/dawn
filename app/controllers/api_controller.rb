class ApiController < ActionController::Metal
  include ActionController::Rendering   # enables rendering
  include ActionController::Head        # for header only responses
  include AbstractController::Callbacks # callbacks for authentication logic (before_action, etc..)

  include ActionController::ForceSSL # secure API by forcing SSL in production

  include ActionController::Helpers
  include Devise::Controllers::Helpers # helper methods

  # This is our new function that comes before Devise's one
  before_action :authenticate_user_from_api_key!

  force_ssl if: :ssl_configured?

  before_filter :set_default_response_format # force json

  append_view_path "#{Rails.root}/app/views" # you have to specify your views location as well

  private

  def set_default_response_format
    request.format = :json
  end

  def ssl_configured?
    !Rails.env.development?
  end

  # Hand-rolled api key login functions, so that we achieve lightweight
  # "bare metal" fuctionality and avoid triggering stuff like increasing
  # the sign_in_count, etc.

  def current_user=(user)
    @current_user = user
  end

  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_api_key!
    key  = params[:api_key].presence
    user = key && User.find_by(api_key: key)

    if user
      self.current_user = user
    else
      head :unauthorized
    end
  end
end
