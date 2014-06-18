class App < ActiveRecord::Base
  validates :name, uniqueness: true,
                   presence: true,
                   format: { with: /\A[a-z][a-z\d-]+\z/ }, # a-z + 0-9 + -, must start with a-z
                   length: { minimum: 3, maximum: 16 }

  validates :logplex_id, uniqueness: true,
                         presence: true

  before_validation :ensure_name,            unless: ->(model){ model.persisted? }
  before_validation :create_logplex_channel, unless: ->(model){ model.persisted? }
  before_destroy    :delete_logplex_channel

  def version
    releases.count
  end

  def env
    releases.last.try(:env) || {}
  end

  def release!(penv=env)
    image_name = "#{user.username.downcase}/#{name}"
    # set the release version to the counter
    releases.create!(image: image_name, env: penv)
  end

  # restarts the application (restart the gears)
  def restart
    gears.each(&:restart)
  end

  def proctypes
    return {}
    # normal operation starts here
    return {} if releases.empty?
    repo_path # TODO: fix this, it no longer exists
    Dir.chdir repo_path do
      default_procfile_name = '/app/tmp/heroku-buildpack-release-step.yml'

      app_container = Docker::Container.create(
        'Image' => releases.last.image,
        'Cmd'   => ['cat', default_procfile_name]
      )
      yml = app_container.tap(&:start).attach[0][0] # attach[0][0] the format is so weird..

      def_proc = YAML.safe_load(yml)['default_process_types']
      app_proc = YAML.safe_load(`git show master:Procfile`)

      begin
        app_container.kill.delete force: true
      rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
      end

      return def_proc.merge(app_proc)
    end
  end

  # scales the application to a particular size (in gears)
  def scale(options)
    # retrieve the App's Procfile data
    allowed_proctypes = proctypes.keys
    old_formation = self.formation

    allowed_proctypes.each do |gear_proctype|
      old_count = old_formation[gear_proctype].to_i
      count = options[gear_proctype].to_i || old_count || 0
      if old_count
        diff = count - old_count
      else
        diff = count
      end
      # determine whether we need to add or remove gears
      if diff > 0
        diff.times { gears.create!(proctype: gear_proctype) }
      elsif diff < 0
        # get rid of diff number of gears, from the highest worker number down
        gears.where(type: gear_proctype)
             .order(number: :desc)
             .limit(diff.abs)
             .destroy
      end
    end

    # we keep missing values and overwrite duplicates with new ones
    # --> Hash#merge
    self.formation = old_formation.merge(options)
    self.save!
  end

  # returns url to a log session
  def logs(num: 100, tail: false)
    body = {channel_id: logplex_id.to_s, num: num.to_s}
    # this is fucked up, but if we add tail key, regardless of it's
    # value, it will tail! (even on {tail: false}/{tail: false.to_s})
    body.merge!(tail: tail) if tail
    JSON.parse(Logplex.post(
      expects: 201,
      path: '/v2/sessions',
      body: body.to_json,
    ).body)['url']
  end

  # runs the command inside a new one-time gear/container
  def run(command)
    # ...
  end

  def url
    "#{name}.#{ENV['DAWN_APP_HOST']}"
  end

  def ensure_name
    if name.blank?
      loop do
        self.name = Forgery(:dawn).app_name
        break if name.size.between?(3, 16) &&
                 name =~ /\A[a-z][a-z\d-]+\z/ &&
                 !App.where(name: name).exists?
      end
    end
  end

  def create_logplex_channel
    # create a new logplex channel
    resp = Logplex.post(
      expects: 201,
      path: '/channels',
      body: {tokens: [:app, :dawn]}.to_json,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
    )
    resp = JSON.parse(resp.body)

    self.logplex_id = resp['channel_id']
    self.logplex_tokens = resp['tokens'].symbolize_keys
  end

  # delete logplex channel
  def delete_logplex_channel
    Logplex.delete(path: "/v2/channels/#{logplex_id}")
  end

  belongs_to :user

  has_many :releases, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :gears,    dependent: :destroy
  # since deleting the chan deletes the drains, don't trigger callback
  has_many :drains,   dependent: :delete_all
  has_many :domains,  dependent: :destroy
end
