require 'fileutils'

class App
  include Mongoid::Document
  include Mongoid::Timestamps

  before_validation :ensure_name, :unless => Proc.new { |model| model.persisted? }
  before_create { create_git_repo }
  before_destroy { delete_git_repo }

  # after_update = don't do this on create
  after_update do # rebuild and redeploy if config was changed
    if config_changed?
      build
      deploy!
    end
  end

  field :name, type: String
  field :config, type: Hash, default: {} # master env config (on change, build new release)
  field :git, type: String # git repo location

  field :formation, type: Hash, default: {web: 1} # formation - how many gears of what type do we have

  field :version, type: Integer, default: 0 # release version tracker

  validates :name,
    uniqueness: true,
    presence: true,
    format: {with: /\A[a-z][a-z\d-]+\z/}, # a-z + 0-9 + -, must start with a-z
    length: { minimum: 3, maximum: 16 }

  def build
    self.inc(version: 1) # increment current version

    image_name = "#{user.username}/#{name}"

    # build image using buildpacks (buildstep)
    git_ref = 'master'

    Dir.chdir "#{Dir.home("git")}/#{git}" do
      IO.popen "git archive #{git_ref} | /#{Rails.root}/script/buildstep #{image_name}" do |fd|
        puts "\e[1G#{fd.readline}" until fd.eof? # \e[1G gets rid of that pesky 'remote:' text
      end
    end

    # .. import ENV config

    # .. tag the current image commit with version (user/image:v3, etc., the ':v3' part)
    # `docker tag #{self.image} `

    # set the release version to the counter
    releases.create!(image: image_name, version: version)
  end

  # using the latest release, destroy old gears and
  # generate new ones
  def deploy!
    image = releases.last.image # TEMP: unused?

    gears.destroy_all # destroy old gears

    # ... destroy old hipache node entries
    redis_key = "frontend:#{url}"
    $redis.del(redis_key)
    # ... recreate hipache list
    $redis.rpush(redis_key, name)

    formation.each do |type, count| # generate new gears (they autostart/deploy)
      count.times do
        gear = gears.create!(type: type)
      end
    end
  end

  # restarts the application (restart the gears)
  def restart
    gears.each(&:restart)
  end

  # scales the application to a particular size (in gears)
  def scale(options)
    old_formation = self.formation
    options.each do |gear_type, count|
      if o = old_formation[gear_type]
        diff = count - o
      else
        diff = count
      end
      # determine whether we need to add or remove gears
      if diff > 0
        diff.times { gears.create!(type: gear_type) }
      elsif diff < 0
        # get rid of diff number of gears, from the highest worker number down
        gears.where(type: gear_type).order_by(:number.desc).limit(abs(diff)).destroy
      end
    end
    self.formation = new_formation
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

  def to_param # override for correct link_to routing
    name
  end

  def ensure_name
    if name.blank?
      loop do
        self.name = Forgery(:dawn).app_name
        break name if valid?
      end
    end
  end

  def create_git_repo
    Dir.chdir Dir.home("git") do
      folder = "#{name}.git"
      raise "Repo exists!" if Dir.exists? folder

      FileUtils.mkdir_p(folder)
      system("git init --bare --shared #{folder}")
      self.git = folder

      # add git hook to catch pushes
      hook = File.join(folder, 'hooks', 'post-receive')
      File.symlink(File.join(Rails.root, 'hooks', 'post-receive'), hook)
      FileUtils.chown_R(nil , ENV['DAWN_GROUP'], folder)
    end
  end
  private :create_git_repo

  def delete_git_repo
    Dir.chdir Dir.home("git") do
      FileUtils.rmdir(git)
    end
  end
  private :delete_git_repo

  belongs_to :user
  has_many :releases, order: :created_at.desc
  has_many :gears, dependent: :destroy
end
