class Release
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create do
    # build image using buildpacks (buildstep)
    git_ref = 'master'

    Dir.chdir "#{Dir.home("git")}/#{app.git}" do
      IO.popen "git archive #{git_ref} | /home/git/tools/buildstep #{self.image}" do |fd|
        puts "\e[1G#{fd.readline}" until fd.eof? # \e[1G gets rid of that pesky 'remote:' text
      end
    end

    # .. import ENV config

    # .. tag the current image commit with version (user/image:v3, etc., the ':v3' part)
    # `docker tag #{self.image} `
  end

  # if a new release was added, redeploy (destroy all gears and recreate)
  after_create do # replace with after_add in app?
    app.rebuild
    app.deploy!
  end

  validates_presence_of :image, :version

  # the docker image name of the release (typically <user>/<app>:v<number>)
  field :image, type: String
  field :version, type: Integer

  belongs_to :app
end
