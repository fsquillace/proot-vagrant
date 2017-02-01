#!/bin/bash

set -eu

sudo apt update
sudo apt install -y build-essential gawk autoconf autotools-dev python cmake uthash-dev git ruby

sudo gem install droxi

mkdir -p /home/vagrant/.config/droxi
cat /vagrant/droxirc > /home/vagrant/.config/droxi/droxirc
chown vagrant:vagrant /home/vagrant/.config/droxi/droxirc
