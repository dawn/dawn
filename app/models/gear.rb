class Gear < ActiveRecord::Base
  validates_uniqueness_of :container_id, :ip
  validates_uniqueness_of :number, scope: :proctype # only one number with the same proctype

  before_create do |gear|  # initialize started_at
    gear.started_at = Time.now
  end

  # before_create create a docker container and run the worker, set port/ip/container_id
  before_validation unless: ->(model){ model.persisted? } do |gear|
    # TEMP? might not be cross process safe, need to make it Atomic
    gear.number = app.gears.where(proctype: proctype).count + 1
    gear.port = 5000 # temp?

    gear.spawn

    # update Hipache with the new gear IP/ports (only add web gears)
    return unless gear.proctype == "web"
    $redis.rpush("frontend:#{app.url}", url)
  end

  def spawn
    logshuttle = {
      procid: name,
      :'logplex-token' => app.logplex_tokens['app'],
      :'logs-url' => "http://#{ENV['DAWN_LOGPLEX_URL']}:8601/logs"
    }.map {|key, val| "-#{key}=#{val.inspect}" }.join(" ")

    container = Docker::Container.create(
      'Image' => app.releases.first.image,
      'Cmd'   => ["/bin/bash", "-c", "/start #{proctype} 2>&1 | /opt/log-shuttle/log-shuttle #{logshuttle}"],
      'Env'   => app.env.map { |k,v| "#{k}=#{v}" }.concat(["PORT=#{port}"])
    ).start

    self.container_id = container.id
    self.ip = container.json["NetworkSettings"]["IPAddress"]

    save! if !new_record?
  end

  before_destroy do |gear|
    # remove web gears from Hipache
    return unless gear.proctype == "web"
    $redis.lrem("frontend:#{app.url}", 1, url)
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

  def url
    "http://#{ip}:#{port}"
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
