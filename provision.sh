#!/bin/bash

# fix locale problem
echo "export LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh
echo "export LANG=en_US.utf-8" >> /etc/profile.d/locale.sh

<<<<<<< Updated upstream
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
=======
yum update -y
yum install -y vim

# we could not listen to some ports when enforcing mode is enabled
# set permissive mode
setenforce 0

/vagrant/monitor/setup.sh
/vagrant/fcgi/setup.sh
/vagrant/httpd/setup.sh
>>>>>>> Stashed changes
