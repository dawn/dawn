class App
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create do
    create_git_repo
  end

  # after_update = don't do this on create
  after_update do # rebuild and redeploy if config was changed
    if config_changed?
      rebuild 
      deploy!
    end
  end

  validate :name, 
    uniqueness: true,
    presence: true,
    format: {with: /\A[a-z][a-z\d-]+\z/}, # a-z + 0-9 + -, must start with a-z
    length: { min: 3, max: 16 }

  field :name, type: String
  field :config, type: Hash, default: {} # master env config (on change, build new release)
  field :git, type: String # git repo location

  field :formation, type: Hash, default: {web: 1} # formation - how many gears of what type do we have

  field :version, type: Integer, default: 0 # release version tracker

  def build
    self.inc(version: 1) # increment current version

    image_name = "#{user.username}/#{name}"

    # set the release version to the counter
    releases.build(image: image_name, version: version)
  end
  alias :rebuild :build

  # using the latest release, destroy old gears and 
  # generate new ones
  def deploy!
    image = releases.last.image # TEMP: unused?

    gears.destroy_all # destroy old gears

    # ... destroy old hipache node entries
    redis_key = "frontend:#{name}.#{ENV['DAWN_HOST']}"
    redis = Redis.new
    redis.del(redis_key)
    # ... recreate hipache list
    redis.rpush(redis_key, name)

    formation.each do |type, count| # generate new gears (they autostart/deploy)
      count.times do
        gear = gears.create!(type: type)
        # update Hipache with the new gear IP/ports (only add web gears)
        redis.rpush(redis_key, "#{gear.ip}:#{gear.port}") if gear.type == 'web'
      end
    end
  end

  # restarts the application (restart the gears)
  def restart
    gears.each {|gear| gear.restart }
  end

  # scales the application to a particular size (in gears)
  def scale
    # determine whether we need to add or remove gears
    # ...
  end

  # returns a log stream of the application
  def logs
    # ...
  end

  # runs the command inside a new one-time gear/container
  def run(command)
    # ...
  end

  def url
    "#{name}.#{ENV['DAWN_HOST']}"
  end

  def create_git_repo
    Dir.chdir Dir.home("git") do
      folder = "#{params[:name]}.git"
      raise "Repo exists!" if Dir.exists? folder

      FileUtils.mkdir_p(folder)
      Rugged::Repository.init_at folder, :bare
      self.git = folder

      # add git hook to catch pushes
    end
  end
  private :create_git_repo

  belongs_to :user
  embeds_many :releases, order: :created_at.desc
  has_many :gears, dependent: :destroy
end
