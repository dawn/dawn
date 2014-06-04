class Api::AppsubController < ApiController

  private def find_app
    if app = App.where(id: params[:app_id]).first
      @app = app
    else
      response = { id: "app.not_exist",
                   message: "App (id: #{params[:app_id]}) does not exist" }
      render json: response, status: 404
    end
  end

end