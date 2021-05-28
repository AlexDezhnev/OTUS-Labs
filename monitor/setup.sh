#!/bin/bash

cp /vagrant/logmon/logmon.sh /usr/bin/logmon.sh
cp /vagrant/logmon/logmon.service /etc/systemd/system/logmon.service
cp /vagrant/logmon/logmon.timer /etc/systemd/system/logmon.timer
cp /vagrant/logmon/logmon.conf /etc/sysconfig/logmon

systemctl enable --now logmon.timer
