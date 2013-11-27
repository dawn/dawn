class Api::AppsController < ApiController

  before_action :find_app, only: [:edit, :show, :update, :destroy]

  def index
    @apps = current_user.apps
    render
  end

  def create
    App.create!(name: params[:name], user: current_user)
    render status: 200
  end

  def edit
    render 'app'
  end

  def show
    render 'app'
  end

  def update
    if @app.update(app_params)
      render status: 200
    else
      render status: 500 # 422 could work too
    end
  end

  def destroy
    if @app.user == current_user
      @app.destroy
      render status: 200
    else
      render status: 403
    end
  end

  def find_app
    if app = App.find_by(name: params[:name])
      @app = app
    else
      @app = nil
      render status: 404
    end
  end
  private :find_app

  def app_params
    param.require(:app).permit(:name, :git)
  end
  private :app_params

end