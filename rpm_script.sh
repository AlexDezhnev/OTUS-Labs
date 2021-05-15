#!/bin/bash

# Install required packets
yum install -y \
  redhat-lsb-core \
  wget \
  rpmdevtoools \
  rpm-build \
  createrepo \
  yum-utils \
  gcc

##############################
# NGINX with OpenSSL support #
##############################

# get and install SRPN NGINX packet
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

# install OpenSSL
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz --directory /usr/lib

# install NGINX dependencies for errors avoiding
yum-builddep /root/rpmbuild/SPECS/nginx.spec -y

# search and replace NGINX configuration string for latest OpenSSL suport
sed -i 's|--with-debug|--with-openssl=/usr/lib/openssl-1.1.1k|' /root/rpmbuild/SPECS/nginx.spec

# build NGINX RPM with SSL support
rpmbuild --bb /root/rpmbuild/SPECS/nginx.spec

# install NGINX from local RPM
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
# add access to directory listing
sed -i '/index  index.html index.htm;/a autoindex on;' /etc/nginx/conf.d/default.conf
systemctl enable --now nginx

####################################
# create my REPO and publish NGINX #
####################################
mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/

# add rpm repo to available list
cat >> /etc/yum.repos.d/custom.repo << EOF
[custom]
name=custom-repo
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF