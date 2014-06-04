class Api::Apps::GearsController < Api::AppsubController

  before_action :find_app, only: [:index, :show, :update, :restart, :restart_all, :destroy]
  before_action :find_gear, only: [:show, :update, :restart, :destroy]

  def create
    head 403
  end

  def index
    @gears = @app.gears
    render status: 200
  end

  def show
    render 'gear', status: 200
  end

  def update
    head 403
  end

  def restart
    @gear.restart
    head 200
  end

  def restart_all
    @gears = @app.gears
    @gears.each &:restart
    head 200
  end

  def destroy
    head 403
  end

  private def find_gear
    if gear = @app.gears.where(id: params[:id]).first
      @gear = gear
    else
      response = { id: "gear.not_exist",
                   message: "Gear (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end