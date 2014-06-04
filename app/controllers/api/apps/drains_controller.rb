class Api::Apps::DrainsController < Api::AppsubController

  before_action :find_app, only: [:index, :show, :update, :destroy]
  before_action :find_drain, only: [:show, :update, :destroy]

  def create
    if !@app.drains.where(url: params[:url]).exists?
      @drain = @app.drains.create!(app: @app, url: params[:url])
      render 'drain', status: 200
    else
      response = { id: "drain.exists", message: "Drain #{params[:url]} exists" }
      render json: response, status: 409
    end
  end

  def index
    @drains = @app.drains
    render status: 200
  end

  def show
    render 'drain', status: 200
  end

  def update
    if @drain.update(url: params[:url])
      render 'drain', status: 200
    else
      # :TODO: handle error
      head 422
    end
  end

  def destroy
    if @drain.destroy
      head 200
    else
      # for some odd reason, it wouldn't destroy
      head 500
    end
  end

  private def find_drain
    if drain = @app.drains.where(id: params[:id]).first
      @drain = drain
    else
      response = { id: "drain.not_exist",
                   message: "Drain (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end