Dawn
====

Hello, welcome to dawn a paas using ruby on rails and Docker.

## System Requirements
* 64 Bit System, capable of running 64 bit VMs
* Quad Core CPU (vagrant gets pretty mean with lower cpus)
* Linux or Mac, we have not tested this on Windows.
* Ruby 1.9.x, 2.0.x, 2.1.x (recommended)
* Docker
* Vagrant >= 1.6.2
* Ansible >= 1.6.2
* Network Connection (for initial installation)
* Patience (if you have a bad network connection and or not so fancy computer)




## Installation (Development)


### dawn GET
```shell
git clone https://github.com/dawn/dawn.git
```


### ansible GET
#### Linux
Arch users:
```shell
pacman -S ansible
```


### vagrant GET
#### Linux
Arch users:
```shell
pacman -S vagrant
```


### dawn setup vagrant box
```shell
cd <where_dawn_is>
vagrant up --provision
# in the case that the above fails, try re-running the provisioning
vagrant provision
```


### dnsmasq! or some other method of IP routing
We used dnsmasq in development
```
# /etc/dnsmasq.conf
...
address=/dev/192.168.33.10
```


### test the dawn ip
```shell
curl dawn.dev:5000
```
This should output some jumbled html, if not, check the troublshoot section.




## Troubleshoot
### vagrant provision stalls at dawn/buildstep
Buildstep takes quite a bit to build, in the case that it shows no sign of
movement:
```shell
dawn$ vagrant ssh
vagrant@ubuntu-14:~$ cd /app
vagrant@ubuntu-14:/app$ docker build -t dawn/buildstep .
```


### bundle install fails in a SSL error
Try running the provisioning again.
```shell
vagrant provision
```

OR:
```shell
dawn$ vagrant ssh
vagrant@ubuntu-14:~$ cd /app
vagrant@ubuntu-14:/app$ bundle install --path vendor/bundle
```


### logplex "default already exists"
This has been fixed recently, however in the case the error strikes again:
```shell
# insert fix here
```






And now back to the original README
== README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* ~~Ruby version~~

* ~~System dependencies~~

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.


# Logplex

```
INSTANCE_NAME=`hostname` \
  LOGPLEX_CONFIG_REDIS_URL="redis://localhost:6733" \
  LOGPLEX_REDGRID_REDIS_URL="redis://localhost:6733" \
  LOCAL_IP="127.0.0.1" \
  LOGPLEX_COOKIE=dawnplex \
  LOGPLEX_AUTH_KEY=123 \
  erl -name logplex@`hostname` -pa ebin -env ERL_LIBS deps -s logplex_app -setcookie ${LOGPLEX_COOKIE} -config sys
```

```
logplex_cred:store(logplex_cred:grant('full_api', logplex_cred:grant('any_channel', logplex_cred:rename(<<"dawn">>, logplex_cred:new(<<"dawn">>, <<"salvorhardin">>))))).
```

