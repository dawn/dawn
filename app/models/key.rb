class Key < ActiveRecord::Base # SSH public key representation

  private def gitlab_keys(arg)
    system("/opt/gitlab-shell/bin/gitlab-keys #{arg}")
  end

  after_create do
    gitlab_keys("add-key \"key-#{id}\" \"#{key}\"")
  end

  before_destroy do
    gitlab_keys("rm-key \"key-#{id}\"")
  end

  belongs_to :user

end