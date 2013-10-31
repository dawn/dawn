class Api::KeysController < ApiController

  def test
    render text: current_user.sign_in_count
  end

  def index
    render status: 200, json: current_user.keys.to_json
  end

  def create
    if !Key.where(fingerprint: params[:fingerprint]).exists?

      Key.create!(
        user: current_user,
        key: params[:key],
        fingerprint: params[:fingerprint]
      )

      render status: 200, text: "Added pubkey!"
    else
      render status: 409, text: "Key already exists!"
    end
  end
end
