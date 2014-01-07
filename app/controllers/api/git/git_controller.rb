class Api::Git::GitController < ActionController::Metal

  include ActionController::Head        # for header only responses

  def allowed
    key = Key.where(id: params[:key_id]).first
    return head 404 unless key
    return head 403 unless @key.user.apps.where(name: params[:project]).exists?
    action  = params[:action]
    ref     = params[:ref]
    head 200
  end

end