FROM progrium/buildstep
MAINTAINER speed "blaz.hrast@gmail.com"

RUN apt-get update
RUN apt-get install -y --force-yes golang
RUN git clone https://github.com/heroku/log-shuttle.git /opt/log-shuttle
RUN go get github.com/kr/godep
ENV PATH=$PATH:$GOPATH/bin
RUN "cd /opt/log-shuttle; godep go build"
RUN apt-get clean
