##
# mapic/ubuntu:latest
#

# base image
FROM ubuntu:xenial

# maintainer
MAINTAINER knutole@mapic.io

# upgrade ubuntu
RUN apt-get update --fix-missing -y
RUN apt-get install software-properties-common -y 
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

# install basics
RUN apt-get update -y
RUN apt-get install -y \ 
	wget \
	fish \
	htop \
	curl \
	unzip \
	bmon \
	nmon \
	nmap \
	pigz \
	build-essential \
  python-software-properties \
  subversion \
  zip \
  mlocate \
  redis-tools \ 
  git \
  protobuf-compiler \
  libprotobuf-dev \
  apt-transport-https \
  make \
  sudo \
  nano \
  host \
  dnsutils

# ensure everything up to date
RUN apt-get update --fix-missing -y

# install node-js
ADD ./install-nodejs.sh /tmp/
RUN sh /tmp/install-nodejs.sh

# set node path
ENV NODE_PATH /usr/local/lib/node_modules

# install node deps
RUN npm install -g grunt-cli
RUN npm install -g nodemon
RUN npm install -g forever
RUN npm install -g mocha
RUN npm install -g node-pre-gyp 
RUN npm install -g npm-check-updates 
RUN npm install -g karma 

# set terminal
ENV TERM xterm

# entrypoint
CMD ['bash']