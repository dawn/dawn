class Api::SessionController < ApiController

  skip_before_action :authenticate_user_from_api_key!

  def create
    user = User.find_by(email: params[:email])

    if user.valid_password?(params[:password])
      render :text => {api_key: user.api_key}.to_json
    end
  end

end
