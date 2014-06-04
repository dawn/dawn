class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    protocol = Rails.env.production? ? "https://" : "http://"
    port = request.server_port == 80 ? '' : ":#{request.server_port}"
    "#{protocol}dashboard.#{request.domain}#{port}" # TODO: update
  end
end
