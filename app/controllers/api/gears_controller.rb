class Api::GearsController < ApiController

  before_action :find_gear, only: [:show, :update, :restart, :destroy]

  def create
    head 403
  end

  def index
    @gears = Gears.all
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
    @gears = Gear.all
    @gears.each &:restart
    head 200
  end

  def destroy
    head 403
  end

  private def find_gear
    if gear = Gear.where(id: params[:id]).first
      @gear = gear
    else
      response = { id: "gear.not_exist",
                   message: "Gear (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

end