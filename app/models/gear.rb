class Gear < ActiveRecord::Base
  validates_uniqueness_of :container_id, :ip
  validates_uniqueness_of :number, scope: :proctype # only one number with the same proctype

  before_create do |gear|  # initialize started_at
    gear.started_at = Time.now
  end

  # before_create create a docker container and run the worker, set port/ip/container_id
  before_create do |gear|
   # TEMP? might not be cross process safe, need to make it Atomic
    gear.number = app.gears.where(proctype: proctype).count + 1
    gear.port = 5000 # temp?

    logshuttle = {
      procid: name,
      :'logplex-token' => app.logplex_tokens['app'],
      :'logs-url' => "http://#{ENV['DAWN_LOGPLEX_URL']}:8601/logs"
    }

    opts = logshuttle.map {|key, val| "-#{key}=#{val.inspect}" }.join(" ")

    container = Docker::Container.create(
      'Image' => app.releases.first.image,
      'Cmd'   => ["/bin/bash", "-c", "/start #{proctype} 2>&1 | /opt/log-shuttle/log-shuttle #{opts}"],
      'Env'   => ["PORT=#{port}"]
    )
    container.start

    gear.container_id = container.id

    info = gear.send(:container).json
    gear.ip = info["NetworkSettings"]["IPAddress"]

    # update Hipache with the new gear IP/ports (only add web gears)
    return unless gear.proctype == "web"
    redis_key = "frontend:#{app.url}"
    $redis.rpush(redis_key, "http://#{gear.ip}:#{gear.port}")
  end

  before_destroy do |gear|
    return unless gear.proctype == "web"
    # remove gear from Hipache
    redis_key = "frontend:#{app.url}"
    $redis.lrem(redis_key, 1, "http://#{gear.ip}:#{gear.port}")
  end

  before_destroy do # destroy the accompanying docker container
    stop && remove
  end

  def name # full name: web.1, mailer.3 (proctype.number)
    "#{proctype}.#{number}"
  end

  def uptime
    started_at ? Time.now - started_at : 0
  end

  private def reset_started_at
    update(started_at: Time.now)
  end

  private def clear_started_at
    update(started_at: nil)
  end

  def container
    Docker::Container.get(container_id)
  end
  private :container

  def kill
    clear_started_at
    container.kill
  end

  def start
    container.start
    reset_started_at
  end

  def stop
    clear_started_at
    container.stop
  end

  def restart
    container.restart
    reset_started_at
  end

  def remove
    clear_started_at
    container.delete
  end

  belongs_to :app
end