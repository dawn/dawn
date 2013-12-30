class Api::DrainsController < ApiController

  before_action :find_app, only: [:index, :show, :destroy]
  before_action :find_drain, only: [:show, :destroy]

  def create
    drain_url = params[:drain_url]
    if !@app.drains.where(url: drain_url).exists?
      @app.drains.create!(app: @app, url: drain_url)
      render 'drain', status: 200
    else
      head 409
    end
  end

  def index
    @drains = @app.drains
    render status: 200
  end

  def show
    render 'drain', status: 200
  end

  def destroy
    @drain.destroy
    head 204
  end

  def find_app
    if app = App.where(id: params[:app_id]).first
      @app = app
    else
      head 404
    end
  end
  private :find_app

  def find_drain
    if drain = @app.drains.where(id: params[:id]).first
      @drain = drain
    else
      head 404
    end
  end
  private :find_drain

end