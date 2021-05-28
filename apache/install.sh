#!/bin/bash

yum install -y httpd

# remove default Apache port from config
sed -i '/Listen 80/d' /etc/httpd/conf/httpd.conf

# install httpd service
cp /vagrant/apache/httpd@.srvc /etc/systemd/system/httpd@.service
cp /vagrant/apache/template.conf /etc/httpd/conf.d/template.conf
# copy Apache test configs with modified PIDs and listen port
cp /vagrant/apache/test-configs/httpd{1,2} /etc/sysconfig

# Enable and start httpd1 and httpd2 services
systemctl enable --now httpd@httpd1.service
systemctl enable --now httpd@httpd2.service
