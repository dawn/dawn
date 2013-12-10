class Api::SessionController < ApiController

  skip_before_action :authenticate_user_from_api_key!

  def create
    user = User.find_by(username: params[:username])
    if user && user.valid_password?(params[:password])
      render json: { api_key: user.api_key }, status: 200
    else
      head 400
    end
  end

end