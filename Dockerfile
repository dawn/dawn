FROM ruby:2.1
MAINTAINER speed "blaz@roave.com"

RUN apt-get install -y libssl-dev libpq-dev
RUN gem install foreman
EXPOSE 5000
CMD ["foreman start"]
