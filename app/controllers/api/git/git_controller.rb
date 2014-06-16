class Api::Git::GitController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::Rendering   # enables rendering
  include ActionController::Renderers::All # enables render json and friends
  include ActionController::Head        # for header only responses

  include GitHelper

  def allowed
    key = params[:key].strip
    username = params[:username]
    if SSHKey.valid_ssh_public_key?(key)
      key = strip_sshkey(key)
      if user = User.where(username: username).first
        if user.keys.where(key: key).first
          head 200
        else
          head 403 # forbidden? maybe, sure, why the hell not
        end
      else
        head 404
      end
    else
      head 404
    end
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
