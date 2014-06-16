class Release < ActiveRecord::Base

  validates_presence_of :image

  # if a new release was added, redeploy (destroy all gears and recreate)
  after_create do # replace with after_add in app?
    deploy!
  end

  def version
    app.releases.index(self)
  end

  # using the latest release, destroy old gears and
  # generate new ones
  def deploy!
    app.gears.destroy_all # destroy old gears

    # recreate hipache node
    redis_key = "frontend:#{app.url}"
    $redis.del(redis_key)
    $redis.rpush(redis_key, app.name)

    app.formation.each do |proctype, count| # generate new gears
      count.to_i.times do
        app.gears.create!(proctype: proctype)
      end
    end
  end

  belongs_to :app
end
