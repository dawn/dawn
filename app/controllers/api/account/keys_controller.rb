class Api::Account::KeysController < ApiController
  helper GitHelper

  before_action :find_key, only: [:show, :destroy]

  def create
    key = strip_sshkey(params.require(:key))
    @key = current_user.keys.create(key: key)
    if @key.save
      render 'key', status: 200
    else
      response = { id: "key.save.fail",
                   message: "saving the key has failed",
                   error: @key.errors.to_h }
      render json: response, status: 422
    end
  end

  def index
    @keys = current_user.keys
    render status: 200
  end

  def show
    render 'key', status: 200
  end

  def destroy
    if @key.destroy
      render json: { message: "key removed successfully" }, status: 200
    else
      response = { id: "key.destroy.fail",
                   message: "key could not be removed for some unknown reason" }
      render json: response, status: 500
    end
  end

  private def find_key
    if key = current_user.keys.where(id: params[:id]).first
      @key = key
    else
      response = { id: "key.not_exist",
                   message: "Key (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end
end
