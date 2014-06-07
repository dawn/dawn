FROM adbl/erlang:r16b03-1
MAINTAINER speed "blaz@roave.com"

RUN apt-get update
RUN apt-get install -y --force-yes git
RUN git clone https://github.com/heroku/logplex.git /opt/logplex
RUN cd /opt/logplex && ./rebar --config public.rebar.config get-deps compile

ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

# TODO: start and link a redis container, pass in options on run

EXPOSE 8001

CMD ['/usr/local/bin/run']