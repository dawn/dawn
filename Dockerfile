FROM ruby:2.1
MAINTAINER speed "blaz@roave.com"

RUN gem install foreman
EXPOSE 5000
CMD ["foreman", "start"]
