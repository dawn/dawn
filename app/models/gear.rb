class Gear
  include Mongoid::Document
  include Mongoid::Timestamps

  # before_create create a docker container and run the worker, set port/ip/container_id
  before_create do |gear|
    gear.number = app.gears.where(type: type).count + 1 # TEMP? might not be cross process safe, need to make it Atomic
    gear.port = 5000 # temp?

    logshuttle = {
      procid: name,
      :'logplex-token' => app.logplex_tokens['app'],
      :'logs-url' => "http://#{ENV['DAWN_HOST']}:8601/logs"
    }

    opts = logshuttle.map {|key, val| "-#{key}=#{val.inspect}" }.join(" ")
    command = %{/bin/bash -c '/start #{type} | /opt/log-shuttle/log-shuttle #{opts}'}
                                                           # FUGLY, FIX!
    gear.container_id = `docker run -d -e PORT=#{port} #{app.releases.last.image} #{command}`

    info = JSON.parse(`docker inspect #{container_id}`).first
    gear.ip = info["NetworkSettings"]["IPAddress"]

    # update Hipache with the new gear IP/ports (only add web gears)
    redis_key = "frontend:#{app.url}"
    $redis.rpush(redis_key, "http://#{gear.ip}:#{gear.port}") if gear.type == :web
  end

  before_destroy do |gear|
    # remove gear from Hipache
    redis_key = "frontend:#{app.url}"
    $redis.lrem(redis_key, 1, "http://#{gear.ip}:#{gear.port}") if gear.type == :web
  end

  after_destroy do # destroy the accompanying docker container
    stop
  end

  validates_uniqueness_of :name, :container_id, :ip

  field :type, type: Symbol # worker type: web/...
  field :number, type: Integer # 1,2,3

  field :port, type: Integer # outbound port of the container
  field :ip, type: String # network IP of the container
  field :container_id, type: String # pid/identifier of the Docker container

  def name # full name: web.1, mailer.3 (type.number)
    "#{type}.#{number}"
  end

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
