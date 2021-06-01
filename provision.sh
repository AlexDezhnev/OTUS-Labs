#!/bin/bash

# fix locale problem
echo "export LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh
echo "export LANG=en_US.utf-8" >> /etc/profile.d/locale.sh

# Update packages
yum -y update

# set permissive mode
setenforce 0

# Let's begin
cp /vagrant/scripts/*.sh /home/vagrant
cd /home/vagrant
chmod +x *.sh
./nice.sh