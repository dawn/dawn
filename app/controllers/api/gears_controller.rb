class Api::GearsController < ApiController

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

  def find_app
    if app = App.find_by(id: app_params[:id])
      @app = app
    else
      head 404
    end
  end
  private :find_app

  def find_gear
    if gear = @app.gears.find_by(id: gear_params[:id])
      @gear = gear
    else
      head 404
    end
  end
  private :find_gear

  def app_params
    params.require(:app).permit(:name, :git)
  end
  private :app_params

  def gear_params
    params.require(:gear).permit(:id, :name)
  end
  private :gear_params

end