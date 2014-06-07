FROM progrium/buildstep
MAINTAINER speed "blaz@roave.com"

RUN apt-get update
RUN apt-get install -y --force-yes software-properties-common
RUN add-apt-repository ppa:duh/golang
RUN apt-get update
RUN apt-get install -y --force-yes golang
RUN git clone https://github.com/heroku/log-shuttle.git /opt/log-shuttle
ENV GOPATH $HOME/go
RUN go get github.com/kr/godep
ENV PATH $PATH:$GOPATH/bin
RUN cd /opt/log-shuttle && godep go build
RUN apt-get clean
