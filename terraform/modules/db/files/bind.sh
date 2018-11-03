#!/bin/bash
set -e

sudo sed -i "s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/" /etc/mongod.conf
sudo service mongod restart