class ApiController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::Rendering   # enables rendering
  include ActionController::Head        # for header only responses
  include AbstractController::Callbacks # callbacks for authentication logic (before_action, etc..)
  #include ActionController::Helpers    # helpers
  include ActionView::Layouts           # for views (render method)

  include ActionController::ForceSSL    # secure API by forcing SSL in production

  # Authentication: Token
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user_from_api_key!
  before_action :set_default_response_format # force json
  force_ssl if: :ssl_configured?

  append_view_path "#{Rails.root}/app/views" # you have to specify your views location as well

  private

  def set_default_response_format
    request.format = :json
  end

  def ssl_configured?
    !Rails.env.development?
  end

  # Bare metal authentication using Authentication: Token
  attr_accessor :current_user

  def authenticate_user_from_api_key!
    authenticate_or_request_with_http_token do |token, options|
      if token && user = User.find_by(api_key: token)
        self.current_user = user
      else
        false
      end
    end
  end

end
