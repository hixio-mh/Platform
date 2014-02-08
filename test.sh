#!/bin/bash -ex
cd /vagrant
npm install
npm install -g grunt-cli mocha
mongo --port 45452 < setup_db.js
grunt deployTest
