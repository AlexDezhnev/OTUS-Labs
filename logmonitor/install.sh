#!/bin/bash

cp /vagrant/logmonitor/logmonitor.sh /usr/bin/logmonitor.sh
cp /vagrant/logmonitor/logmonitor.srvc /etc/systemd/system/logmonitor.service
cp /vagrant/logmonitor/logmonitor.timer /etc/systemd/system/logmonitor.timer
cp /vagrant/logmonitor/logmonitor.conf /etc/sysconfig/logmonitor

systemctl enable --now logmonitor.timer
