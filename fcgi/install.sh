#!/bin/bash

# install spawn-fcgi with dependencies
yum install -y epel-release
yum install -y gcc spawn-fcgi httpd php php-cli mod_fcgid

# configure spawn-fcgi unit
cp /vagrant/fcgi/spawn-fcgi.srvc /etc/systemd/system/spawn-fcgi.service
sed -i 's|#SOCKET|SOCKET|' /etc/sysconfig/spawn-fcgi
sed -i 's|#OPTIONS|OPTIONS|' /etc/sysconfig/spawn-fcgi
systemctl enable --now spawn-fcgi.service
