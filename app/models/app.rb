require 'fileutils'

class App
  include Mongoid::Document
  include Mongoid::Timestamps

  before_validation :ensure_name, :unless => Proc.new { |model| model.persisted? }

  before_validation :create_logplex_channel, :unless => Proc.new { |model| model.persisted? }
  def create_logplex_channel
    # create a new logplex channel
    resp = Logplex.post(
      expects: 201,
      path: '/channels',
      body: {tokens: [:app, :dawn]}.to_json,
      headers: { "Content-Type" => "application/x-www-form-urlencoded" }
    )
    resp = JSON.parse(resp.body)

    self.logplex_id = resp['channel_id']
    self.logplex_tokens = resp['tokens'].symbolize_keys
  end

  before_create do
    create_git_repo
  end
  before_destroy do
    delete_git_repo

    # delete logplex channel
    Logplex.delete(path: "/v2/channels/#{logplex_id}")
  end

  # after_update = don't do this on create
  after_update do # rebuild and redeploy if config was changed
    if env_changed?
      build
      deploy!
    end
  end

  field :name, type: String
  field :env, type: Hash, default: {} # master env config (on change, build new release)
  field :git, type: String # git repo location

  field :formation, type: Hash, default: {web: 1} # formation - how many gears of what type do we have

  field :version, type: Integer, default: 0 # release version tracker

  field :logplex_id, type: Integer
  field :logplex_tokens, type: Hash

  validates :name,
    uniqueness: true,
    presence: true,
    format: {with: /\A[a-z][a-z\d-]+\z/}, # a-z + 0-9 + -, must start with a-z
    length: { minimum: 3, maximum: 16 }

  validates :logplex_id,
    uniqueness: true,
    presence: true

  def build
    self.inc(version: 1) # increment current version

    image_name = "#{user.username}/#{name}"

    # build image using buildpacks (buildstep)
    git_ref = 'master'

    Dir.chdir "#{Dir.home("git")}/#{git}" do
      begin
        #tarname = "app-#{Time.now.to_i}.tar"
        #begin
        #  # .. import ENV config
        #  `git archive #{git_ref} -o #{tarname}`
        #  # create profile.d
        #  Dir.mkdir(".profile.d")
        #  # write dawn.env variables file
        #  File.open(".profile.d/dawn.env", "w"){|f|env.each{|k,v|f.puts("#{k}=#{v}")}}
        #  # concate .profile.d to archive
        #  `tar -rf #{tarname} .profile.d`
        #ensure
        #  FileUtils.rm_rf(".profile.d") # we no longer need the profile.d so remove it
        #end
        #IO.popen "cat #{tarname} | /#{Rails.root}/script/buildstep #{image_name}" do |fd|
        IO.popen "git archive #{git_ref} | /#{Rails.root}/script/buildstep #{image_name}" do |fd|
          puts "\e[1G#{fd.readline}" until fd.eof? # \e[1G gets rid of that pesky 'remote:' text
        end
      #ensure
        #FileUtils.rm_rf("#{tarname}")
      end
    end

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
    old_formation = self.formation.with_indifferent_access
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
        gears.where(type: gear_type).order_by(:number.desc).limit(diff.abs).destroy
      end
    end
    # we keep missing values and overwrite duplicates with
    # new ones --> Hash#merge
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
      FileUtils.rm_rf(git)
    end
  end
  private :delete_git_repo

  belongs_to :user
  has_many :releases, order: :created_at.desc
  has_many :gears, dependent: :destroy
end
