#!/bin/bash

# fix locale problem
echo "export LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh
echo "export LANG=en_US.utf-8" >> /etc/profile.d/locale.sh

# Update packages
yum -y update

# set permissive mode
setenforce 0

# Install log monitor service
/vagrant/logmonitor/install.sh

# Install spawn-fcgi unit
/vagrant/fcgi/install.sh

# start multiple apache configurarions
/vagrant/apache/install.sh