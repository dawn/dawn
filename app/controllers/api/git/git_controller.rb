class Api::Git::GitController < ActionController::Metal
  include ActionController::Head        # for header only responses
  include AbstractController::Rendering
  include ActionController::Rendering   # enables rendering

  def allowed
    if key = Key.where(key: params[:key]).first
      head 200
    else
      head 404
    end
  end

  def discover
    key = Key.where(id: params[:key_id]).first
    return head 404 unless key
    user = key.user
    render text: {name: user.username}.to_json, status: 200
  end

  def api_key
    if user = User.where(username: params[:username]).first
      if params[:build_token] == ENV["DAWN_BUILD_TOKEN"]
        render json: { user: { api_key: user.api_key } }, status: 200
      else
        response = { id: "build_token.mismatch",
                     message: "provided build_token was invalid" }
        render json: response, status: 400
      end
    else
      response = { id: "user.not_exist",
                   message: "User (username: #{params[:username]}) does not exist" }
      render json: response, status: 404
    end
  end
end
