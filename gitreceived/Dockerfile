FROM ubuntu:14.04
MAINTAINER speed "blaz@roave.com"

RUN sudo add-apt-repository ppa:brightbox/ruby-ng
RUN apt-get -y update &&  apt-get -y install git ruby2.1 wget && apt-get clean
RUN wget https://storage.googleapis.com/golang/go1.2.2.linux-amd64.tar.gz -O - | tar -C /usr/local -xz
ENV PATH $PATH:/usr/local/go/bin
ENV GOROOT $HOME/go
ENV PATH $PATH:$GOROOT/bin
RUN go get github.com/tools/godep

RUN git clone https://github.com/flynn/gitreceived.git /opt/gitreceived
RUN cd /opt/gitreceived && godep go build

RUN gem install excon docker-api json

ADD receive /bin/dawn-receive
ADD authorize /bin/dawn-authorize
EXPOSE 22

cmd ["/opt/gitreceived", "/bin/dawn-authorize", "/bin/dawn-receive"]
