FROM ubuntu:14.04
MAINTAINER speed "blaz@roave.com"

RUN apt-get -y update
RUN apt-get -y install curl
RUN echo deb http://packages.erlang-solutions.com/debian precise contrib >> /etc/apt/sources.list
RUN curl -s http://packages.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add -
RUN apt-get -y update
RUN apt-get -y install openssl libssl-dev
RUN apt-get -y install esl-erlang=1:16.b.3-2
RUN apt-get install -y git
RUN apt-get -y autoremove
RUN git clone https://github.com/heroku/logplex.git /opt/logplex
RUN cd /opt/logplex && ./rebar --config public.rebar.config get-deps compile

ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

EXPOSE 8001 8601

cmd ["/usr/local/bin/run"]
