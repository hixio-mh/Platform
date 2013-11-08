#! /usr/bin/env bash

##
## Base install
##

# Install base packages
sudo apt-get update
sudo apt-get install git build-essential screen mongodb fabric -y

# This is needed to get fabric working for some reason
sudo pip install fabric

# Install node
wget http://nodejs.org/dist/v0.10.21/node-v0.10.21-linux-x86.tar.gz
cd /usr/local && sudo tar --strip-components 1 -xzf /home/vagrant/node-v0.10.21-linux-x86.tar.gz

# Setup node modules
sudo npm install -g grunt-cli codo coffee-script mocha

##
## Setup database
##

# Create user
mongo --eval "db.addUser(\"adefy_cloud\",\"GFtEA468aF73nYZh\")" adefy_cloud

# Extract archive
cd /vagrant
tar -xzvf adefy_db.tgz

# Restore data
mongorestore

# Clean up
rm dump/ -rf

##
## Copy over ssh keys for vagrant
##
sudo mkdir /home/cris
sudo cp /vagrant/.ssh /home/cris -r
sudo chmod 777 /home/cris -R

##
## Setup project
##

# Install packages, and build line
cd /vagrant/line
sudo npm install
grunt
cd /vagrant
sudo npm install

# Build adefy
grunt full

# Launch dev task!
grunt dev
