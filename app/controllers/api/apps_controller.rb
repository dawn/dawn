class Api::AppsController < ApiController
  actions = [:index, :create]
  before_action :find_app, except: actions
  before_action :verify_app_owner, except: actions

  def index
    @apps = current_user.apps
    render status: 200
  end

  def create
    appname = app_params.require(:name)
    if App.where(name: appname).first
      response = { id: "app.exists", message: "App #{appname} already exists" }
      render json: response, status: 409
    else
      @app = App.new(name: appname, user: current_user)
      if @app.save
        render 'app', status: 200
      else
        response = { id: "app.save.fail",
                     message: "App (name: #{@app.name}) saving has failed" }
        response[:errors] = @app.errors.to_h

        render json: response, status: 422
      end
    end
  end

  def show
    render 'app', status: 200
  end

  def update
    if @app.update(app_params.permit(:name))
      render 'app', status: 200
    else
      head 422
    end
  end

  def get_env
    render 'env', status: 200
  end

  def update_env
    @app.release!(app_params.require(:env))
    render 'env', status: 200
  end

  def destroy
    if @app.destroy
      response = { message: "App removed successfully" }
      render json: response, status: 200
    else
      head 500
    end
  end

  def formation
    render status: 200
  end

  def scale
    @app.scale(app_params.require(:formation))
    head 200
  end

  def logs
    opts = { }
    opts[:tail] = true if params[:tail]
    opts[:num]  = params[:num] if params.key?(:num)
    @logs = @app.logs(opts)
    render status: 200
  end

  # starts a one-off container session
  require 'shellwords'
  def run
    head 400 unless params[:command]

    if env['rack.hijack']
      env['rack.hijack'].call

      socket = env['rack.hijack_io']
      begin
        socket.flush
        socket.sync = true

        container = Docker::Container.create(
          'Image'     => @app.releases.last.image,
          'Cmd'       => Shellwords.split(params[:command]),
          'Tty'       => true,
          'OpenStdin' => true,
          'StdinOnce' => false
        )

        socket.write "#{params} started\n"

        container.tap(&:start).attach(stdin: socket, tty: true) do |type, msg|
          socket.write(msg)
        end

        socket.write "returned\n"
      ensure
        socket.close
      end
    end
  end

  # -- new subresources
  def create_gear
    head
  end

  def create_drain
    url = params.require(:drain).require(:url)
    if !@app.drains.where(url: url).exists?
      @drain = @app.drains.create(app: @app, url: url)
      if @domain.save
        render 'drains/drain', status: 200
      else
        # :TODO: handle save error
        head 422
      end
    else
      head 409
    end
  end

  def create_domain
    url = params.require(:drain).require(:url)
    if !@app.domains.where(url: url).exists?
      @domain = @app.domains.create(app: @app, url: url)
      if @domain.save
        render 'domains/domain', status: 200
      else
        # :TODO: handle save error
        head 422
      end
    else
      response = { id: 'domain.exists',
                   message: "Domain #{params[:url]} exists" }
      render json: response, status: 409
    end
  end

  def create_release
    @release = @app.release!
    if @release.save
      render 'releases/release', status: 200
    else
      # :TODO: handle save error
      head 422
    end
  end

  # fetch scoped subresources
  def gears
    @gears = @app.gears
    render 'api/gears/index', status: 200
  end

  def drains
    @drains = @app.drains
    render 'api/drains/index', status: 200
  end

  def domains
    @domains = @app.domains
    render 'api/domains/index', status: 200
  end

  def releases
    @releases = @app.releases
    render 'api/releases/index', status: 200
  end

  def gears_restart
    @app.gears.each &:restart
    render json: { message: "gears have been restarted" }, status: 200
  end

  private def app_params
    params.require(:app)
  end

  private def find_app
    app = App.where(id: params[:id]).first
    app = App.where(name: params[:id]).first unless app
    if app
      @app = app
    else
      response = { id: "app.not_exist",
                   message: "App (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

  private def verify_app_owner
    unless @app.user == current_user
      response = { id: "app.not_owner",
                   message: "App (id: #{params[:id]}) does not belong to the current user" }
      render json: response, status: 401
    end
  end
end
