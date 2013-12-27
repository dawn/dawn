# TODO

Things we still need to finish, to get to a usable platform.

* besides killing, we should also remove the container
* manually calculate ssh fingerprint
* dawn run: one-off containers running a single command then getting destroyed
* dawn ps should list uptime as well
* logging: allow us to specify drains (uses logplex drains to post logs to a drain)
* Integrate the [gitlab-shell](https://github.com/gitlabhq/gitlab-shell) or an OpenSSH patch, so we can allow per-repository/(per-branch) access control.
* Validate the scale parameters using a proctype list that combines the Procfile with the default process types from buildpacks

      #"git show master:Procfile" --> to retrieve the procfile and parse it [git show <ref>:<file>]
      def proctypes
        Dir.chdir "#{Dir.home("git")}/#{git}" do
          procfile = `git show master:Procfile`

          return YAML.load_file('Procfile').symbolize_keys
        end
      end

* Services: db, queues, caches, mail servers, file storage
* Inject the ENV config into the releases
* Replace shelling out with calls to [Docker API](https://github.com/swipely/docker-api)
* Resource limiting: constraints on CPU, memory, bandwidth, disk space...
* Par app metrics
* Metrics: global!, so we can monitor the entire server
* Monitoring: restart any crashed gear
* Adding custom domains
* Using custom SSH keys
* use OAuth2 to make a provider for token generation, authentication and authorization
  * https://devcenter.heroku.com/articles/oauth


* integrate payments
* manage several environments at once
* rollback to specific release
* use grsecurity patches