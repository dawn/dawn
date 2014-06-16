require 'sshkey'

class Api::Account::KeysController < ApiController
  helper GitHelper

  before_action :find_key, only: [:show, :destroy]

  def create
    key = params[:key].strip
    if SSHKey.valid_ssh_public_key?(key)
      key = strip_sshkey(key)
      fingerprint = SSHKey.fingerprint(key)
      if !Key.where(fingerprint: fingerprint).exists?
        @key = current_user.keys.build(key: key, fingerprint: fingerprint)
        if @key.save
          render 'key', status: 200
        else
          head 422
        end
      else
        head 422
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
