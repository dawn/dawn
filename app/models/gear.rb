class Gear < ActiveRecord::Base
  validates_uniqueness_of :container_id, :ip
  validates_uniqueness_of :number, scope: :proctype # only one number with the same proctype

  before_create do |gear|  # initialize started_at
    gear.started_at = Time.now
  end

  # before_create create a docker container and run the worker, set port/ip/container_id
  before_create do |gear|
    gear.number = app.gears.where(proctype: proctype).count + 1 # TEMP? might not be cross process safe, need to make it Atomic
    gear.port = 5000 # temp?

    logshuttle = {
      procid: name,
      :'logplex-token' => app.logplex_tokens['app'],
      :'logs-url' => "http://#{ENV['DAWN_HOST']}:8601/logs"
    }

    opts = logshuttle.map {|key, val| "-#{key}=#{val.inspect}" }.join(" ")
    command = %{/bin/bash -c '/start #{proctype} 2>&1 | /opt/log-shuttle/log-shuttle #{opts}'}
                                                           # FUGLY, FIX!
    gear.container_id = `docker run -d -e PORT=#{port} #{app.releases.first.image} #{command}`.chomp

    info = JSON.parse(`docker inspect #{container_id}`).first
    gear.ip = info["NetworkSettings"]["IPAddress"]

    # update Hipache with the new gear IP/ports (only add web gears)
    redis_key = "frontend:#{app.url}"
    $redis.rpush(redis_key, "http://#{gear.ip}:#{gear.port}") if gear.proctype == "web"
  end

  before_destroy do |gear|
    # remove gear from Hipache
    redis_key = "frontend:#{app.url}"
    $redis.lrem(redis_key, 1, "http://#{gear.ip}:#{gear.port}") if gear.proctype == "web"
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

  def kill
    `docker kill #{container_id}`
    clear_started_at
  end

  def start
    `docker start #{container_id}`
    reset_started_at
  end

  def stop
    `docker stop #{container_id}`
    clear_started_at
  end

  def restart
    `docker restart #{container_id}`
    reset_started_at
  end

  def remove
    `docker rm #{container_id}`
    clear_started_at
  end

  belongs_to :app
end