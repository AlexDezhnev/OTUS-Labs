#!/bin/bash

# fix locale problem
echo "export LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh
echo "export LANG=en_US.utf-8" >> /etc/profile.d/locale.sh

yum -y install mailx
# Update packages
# yum -y update

# set permissive mode
setenforce 0

# Let's begin
cp /vagrant/scripts/*.sh /home/vagrant
cp /vagrant/logs/*.log /home/vagrant
cd /home/vagrant
chmod +x *.sh
echo "1" > last_line.txt
crontab /vagrant/cronfile