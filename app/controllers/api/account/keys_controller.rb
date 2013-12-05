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
  end

  def find_key
    @key = Key.find(params[:key][:id])
  end
  private :find_key

end