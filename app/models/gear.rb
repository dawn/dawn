class Gear
  include Mongoid::Document
  include Mongoid::Timestamps

  # before_create create a docker container and run the worker, set port/ip/container_id
  before_create do |gear|
    gear.name = "#{type}.#{app.gears.where(type: type).count + 1}" # TEMP? might not be cross process safe, need to make it Atomic
    gear.port = 5000 # temp?
                                                           # FUGLY, FIX!
    gear.container_id = `docker run -d -e PORT=#{port} #{app.releases.last.image} /bin/bash -c "/start #{type}"`
    info = JSON.parse(`docker inspect #{container_id}`).first
    gear.ip = info["NetworkSettings"]["IPAddress"]
  end

  after_destroy do # destroy the accompanying docker container
    kill
  end

  validates_uniqueness_of :name, :container_id, :ip

  field :type, type: String # worker type: web/...
  field :name, type: String # full name: web.1, mailer.3

  field :port, type: Integer # outbound port of the container
  field :ip, type: String # network IP of the container
  field :container_id, type: String # pid/identifier of the Docker container

  def kill
    `docker kill #{container_id}`
  end

  def start
    `docker start #{container_id}`
  end

  def stop
    `docker stop #{container_id}`
  end

  def restart # use docker restart
    `docker restart #{container_id}`
  end

  belongs_to :app
end