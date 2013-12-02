class Api::GearsController < ApiController

  before_action :find_app, only: [:index, :show, :destroy]
  before_action :find_gear, only: [:show, :destroy]

  def index
    @gears = @app.gears
    render 'gears'
  end

  def show
    render 'gear'
  end

  def destroy
    @gear
  end

  def find_app
    if app = App.find_by(id: app_params[:id])
      @app = app
    else
      render status: 404
    end
  end
  private :find_app

  def find_gear
    if gear = @app.gears.find_by(id: gear_params[:id])
      @gear = gear
    else
      render status: 404
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