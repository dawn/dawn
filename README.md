Dawn
====

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

Setting up a development environment is pretty easy, as Vagrant automatically runs the Ansible playbooks provided.
All it takes to get the box up and running is:

```shell
vagrant up
```

The initial provisioning run might take a while, because we pull and compile several dependencies.

In case you need to run the provisioning again in the future:

```shell
vagrant provision
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

All set! Your box is now ready to use. Point your browser to http://dawn.dev, and it should show a landing page.

[Our client](https://github.com/dawn/dawn-cli) is recommended currently, as it's the most feature complete, however, a
web interface is also in the works, available under [dashboard.dawn.dev](http://dashboard.dawn.dev).

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

## API Documentation
[Docs](http://dawn.github.io/docs/)

## Have Questions?
Hit us up on the irc on freenode #dawn

But please, don't really *hit us*
