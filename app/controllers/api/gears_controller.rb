class Api::GearsController < Api::AppsubController

  before_action :find_app, only: [:index, :show, :destroy, :destroy_all]
  before_action :find_gear, only: [:show, :destroy]

  def index
    @gears = @app.gears
    render status: 200
  end

  def show
    render 'gear', status: 200
  end

  def destroy
    @gear.restart
    head 200
  end

  def destroy_all
    @gears = @app.gears
    @gears.each(&:restart)
    head 200
  end

  private def find_gear
    if gear = @app.gears.where(id: params[:id]).first
      @gear = gear
    else
      head 404
    end
  end

end