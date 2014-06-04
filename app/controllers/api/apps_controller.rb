class Api::AppsController < ApiController
  actions = [:index, :create]
  before_action :find_app, except: actions
  before_action :verify_app_owner, except: actions

  def index
    if name = params[:name]
      @apps = current_user.apps.where(name: name)
    else
      @apps = current_user.apps
    end
    render status: 200
  end

  def create
    appname = params[:name]
    if App.where(name: appname).first
      response = { id: "app.exists", message: "App #{appname} already exists" }
      render json: response, status: 409
    else
      @app = App.new(name: appname, user: current_user)
      if @app.save
        render 'app', status: 200
      else
        head 500
      end
    end
  end

  def show
    render 'app'
  end

  def update
    if @app.update(name: params[:name])
      render 'app', status: 200
    else
      head 500
    end
  end

  def get_env
    render 'env', status: 200
  end

  def update_env
    if @app.update(env: params[:env])
      render 'env', status: 200
    else
      head 500
    end
  end

  def destroy
    @app.destroy
    head 200
  end

  def formation
    render status: 200
  end

  def scale
    @app.scale(params[:formation])
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
    if !@app.drains.where(url: params[:url]).exists?
      @drain = @app.drains.create(app: @app, url: params[:url])
      if @domain.save
        render 'drains/drain', status: 200
      else
        # :TODO: handle save error
        head 500
      end
    else
      head 409
    end
  end

  def create_domain
    if !@app.domains.where(url: params[:url]).exists?
      @domain = @app.domains.create(app: @app, url: params[:url])
      if @domain.save
        render 'domains/domain', status: 200
      else
        # :TODO: handle save error
        head 500
      end
    else
      response = { id: 'domain.exists',
                   message: "Domain #{params[:url]} exists" }
      render json: response, status: 409
    end
  end

  # fetch scoped subresources
  def gears
    @gears = @app.gears
    render 'gears/index', status: 200
  end

  def drains
    @drains = @app.drains
    render 'drains/index', status: 200
  end

  def domains
    @domains = @app.domains
    render 'domains/index', status: 200
  end

  def gears_restart
    @app.gears.each &:restart
    head 200
  end

  private def find_app
    if app = App.where(id: params[:id]).first
      @app = app
    else
      response = { id: "app.not_exist",
                   message: "App (id: #{params[:id]}) does not exist" }
      render json: response, status: 404
    end
  end

  private def verify_app_owner
    unless @app.user == current_user
      head 401
    end
  end
end
