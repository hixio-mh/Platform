FROM ubuntu:quantal

RUN apt-get update

RUN apt-get install -y --force-yes git build-essential python software-properties-common

# MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

RUN add-apt-repository ppa:chris-lea/node.js
RUN add-apt-repository ppa:chris-lea/redis-server

RUN apt-get update

RUN apt-get install -y --force-yes mongodb-10gen redis-server nginx nodejs

RUN apt-get clean

ADD ./provisioning/roles/common/files/nginx.conf /etc/nginx/nginx.conf

# create the dir for mongodb
RUN mkdir -p /data/db/

ADD ./ /vagrant

ENTRYPOINT mongod --port 45452 > /dev/null & redis-server --port 23521 > /dev/null & nginx > /dev/null
