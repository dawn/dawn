require 'sshkey'

class Api::Account::KeysController < ApiController

  before_action :find_key, only: [:show, :destroy]

  def create
    pbkey       = params[:key]
    fingerprint = SSHKey.fingerprint(pbkey)
    if !Key.where(fingerprint: fingerprint).exists?
      @key = Key.create!(user: current_user, key: pbkey,
                                             fingerprint: fingerprint)
      render 'key', status: 200
    else
      head 409
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
    @key.destroy
    head 204
  end

  def find_key
    if key = current_user.keys.where(id: params[:id]).first
      @key = key
    else
      head 404
    end
  end
  private :find_key

end