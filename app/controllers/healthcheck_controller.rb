class HealthcheckController < ApiController
  skip_before_action :authenticate_user_from_api_key!

  def index
    head 200
  end
end
