class Release

  include Mongoid::Document
  include Mongoid::Timestamps

  # the docker image name of the release (typically <user>/<app>:v<number>)
  field :image, type: String
  field :version, type: Integer

  validates_presence_of :image, :version

  # if a new release was added, redeploy (destroy all gears and recreate)
  #after_create do # replace with after_add in app?
    #app.deploy!
  #end

  belongs_to :app

end