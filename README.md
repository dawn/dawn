Dawn
====
[![Dependency Status](https://gemnasium.com/dawn/dawn.svg)](https://gemnasium.com/dawn/dawn)
[![Code Climate](https://codeclimate.com/github/dawn/dawn.png)](https://codeclimate.com/github/dawn/dawn)

Hello, welcome to Dawn, a PaaS that leverages Ruby on Rails and Docker. It implements a Heroku-like interface,
with an API-first approach. Initial development started in October 2013 intending to be launched as a commercial
service eventually, however due to the increasing competition in the PaaS market, and the lack of time, we've
released it as open-source. Enjoy!

Our current development stack is ubuntu 14.04, running docker, ruby 2.1.2 (rails 4.1.1), postgresql, redis, logplex and hipache.

Future goal is to port the platform onto coreOS, and split the app into several containers (using a similar setup
to what userspace apps will use -- dogfeeding us our own stack). Doing so will make the platform more modular, easier
to deploy and scale, and faster to provision.

## Features

* Releasing apps onto the platform via git
* Building app containers via Buildstep
* Importing ENV variables into the app space
* Retrieving app logs, and setting up drain urls, to which logs can be submitted via HTTP POST
* Scaling per-proctype

## Prerequisites
* A system capable of running amd64 VMs (for our development box)
* Vagrant >= 1.6.2
* Ansible >= 1.6.2
* Patience (if you have a bad network connection and/or not so fancy computer)

## Installation (Development)

First, make sure to initialize git submodules (we currently use a submodule for erlang provisioning).
```
git submodule update --init
```

Setting up a development environment is pretty easy, as Vagrant automatically runs the Ansible playbooks provided.
All it takes to get the box up and running is:

```shell
$ vagrant up
$ script/provision -l vagrant
```

The initial provisioning run might take a while, because we pull and compile several dependencies.

To provision your own server, simply add it under a different group inside `provisioning/hosts`, then run
```
$ script/provision -l <group>
```

### dnsmasq
The box IP needs to resolve to dawn.dev and dawnapp.dev (configurable in config/application.yml). You can add an alias to
/etc/resolv.conf, or use your own method of doing so. We suggest using dnsmasq, with the following line
in it's configuration:

```
# /etc/dnsmasq.conf
...
address=/dev/192.168.33.10
```

All set! Your box is now ready to use.

```
curl http://api.dawn.dev/healthcheck
```

[Our client](https://github.com/dawn/dawn-cli) is recommended currently, as it's the most feature complete, however, a
web interface is also in the works, available under [dashboard.dawn.dev](http://dashboard.dawn.dev).

### Using the CLI utility

The client can be easily installed via Rubygems.

```
$ gem install dawn-cli
```

A list of all available commands along with descriptions is available under `dawn help`.

Workflow usually looks like this: First we log into our Dawn account.

```
$ dawn login
Username: Speed
Password: test1234
```

The utility then stores the API token under `~/.netrc` for further use. (Note that our format is currently incompatible with `curl -n`, because we use `Authorization: Token` instead of `Authorization: Basic`. This will change in the near future.)

Next up, we need to add our ssh key, in order to be authorized to push to the platform. This will automatically take your

```
dawn key:add
```

Then, we initialize our project on the Dawn platform.

```
$ cd awesome-app
$ dawn init
```

And we're done! To build our app, simply push to the `dawn` remote.

```
$ git push dawn master
Counting objects: 148, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (107/107), done.
Writing objects: 100% (148/148), 11.90 KiB | 0 bytes/s, done.
Total 148 (delta 46), reused 0 (delta 0)
       Ruby app detected
-----> Compiling Ruby/Rack
-----> Using Ruby version: ruby-2.1.0
-----> Installing dependencies using 1.5.2
       Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
       Fetching gem metadata from https://rubygems.org/..........
       Fetching additional metadata from https://rubygems.org/..
       Installing daemons (1.1.9)
       Using bundler (1.5.2)
       Installing tilt (1.4.1)
       Installing rack (1.5.2)
       Installing rack-protection (1.5.2)
       Installing sinatra (1.4.4)
       Installing eventmachine (1.0.3)
       Installing thin (1.6.1)
       Your bundle is complete!
       Gems in the groups development and test were not installed.
       It was installed into ./vendor/bundle
       Bundle completed (20.25s)
       Cleaning up the bundler cache.
-----> Discovering process types
       Procfile declares types -> web
       Default process types for Ruby -> rake, console, web

-----> Launching... done, v1
      http://awesome-app.dawnapp.dev deployed to Dawn
To git@dawn.dev:ruby-sample.git
 * [new branch]      master -> master
```

## Proposed features

* [ ] dawn run: one-off containers running a single command then getting destroyed
* [ ] Adding custom domains
* [ ] Services: db, queues, caches, mail servers, file storage
* [ ] Rollback to a specific release
* [X] Inject the ENV config into the releases
* [ ] Resource limiting: constraints on CPU, memory, bandwidth, disk space...
* [ ] Per app metrics
* [ ] Global server metrics, so we can monitor the entire server
* [ ] Monitoring: restart any crashed gear
* [ ] Manage different release environments

* [ ] Use a grsecurity patched kernel (or coreOS)

* [ ] Use OAuth2 to make a provider for token generation, authentication and authorization
  * https://devcenter.heroku.com/articles/oauth

* [ ] Logging: allow us to specify drains (uses logplex drains to post logs to a drain)

## FAQ
### vagrant provision stalls at dawn/buildstep
Buildstep takes quite a bit to build, in the case that it shows no sign of
movement, you can also try to build it manually:
```shell
dawn$ vagrant ssh
vagrant@ubuntu-14:~$ cd /app
vagrant@ubuntu-14:/app$ docker build -t dawn/buildstep .
```

### bundle install fails in a SSL error
Try running the provisioning again, it's probably a network error.

### API is not working after a VM reboot
This is because we're still using the foreman generated upstart files, that don't watch for vagrant-mounted event. This will be resolved in the near future, but for now, ssh into the box and restart the service. It should take about 30-60 seconds to restart.

```
vagrant ssh
vagrant@ubuntu-14:~$ sudo restart dawn
```

### API is not working after a system sleep/hybernation
Vagrant sometimes seems to unmount the shared folder `/app` on such occasions. Run `vagrant reload`.

## Documentation
[API documentation](http://dawn.github.io/docs/) is available. We're in the process of providing online CLI documentation and guides as well.


## Known Problems
- dashboard.dawn.dev doesn't work
#7
[Dawn Dashboard](https://github.com/dawn/dawn-dashboard)

## Have Questions?
Hit us up on the irc on freenode #dawn

But please, don't really *hit us*
