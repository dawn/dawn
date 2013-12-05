class Api::Account::KeysController < ApiController

  before_action :find_key, only: [:show, :destroy]

  def test
    render text: current_user.sign_in_count
  end

  def create
    if !Key.where(fingerprint: params[:fingerprint]).exists?
      Key.create!(user: current_user,
                  key: params[:key],
                  fingerprint: params[:fingerprint])
      render status: 200, text: "Added pubkey!"
    else
      render status: 409, text: "Key already exists!"
    end
  end

  def index
    @keys = current_user.keys
    render status: 200
  end

  def show
    render 'key'
  end

  def destroy
    @key.destroy
    render status: 200
  end

  def find_key
    if key = current_user.keys.find(params[:id])
      @key = key
    else
      render status: 404
    end
  end
  private :find_key

end