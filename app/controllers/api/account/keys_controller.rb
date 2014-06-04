require 'sshkey'

class Api::Account::KeysController < ApiController
  before_action :find_key, only: [:show, :destroy]

  def create
    fingerprint = SSHKey.fingerprint(params[:key])
    if !Key.where(fingerprint: fingerprint).exists?
      @key = current_user.keys.build(key: params[:key], fingerprint: fingerprint)
      if @key.save
        render 'key', status: 200
      else
        head 500
      end
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
    if @key.destroy
      head 200
    else
      head 500
    end
  end

  private def find_key
    if key = current_user.keys.where(id: params[:id]).first
      @key = key
    else
      head 404
    end
  end
end
