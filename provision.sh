#!/bin/bash

# fix locale problem
echo "export LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh
echo "export LANG=en_US.utf-8" >> /etc/profile.d/locale.sh

yum install -y epel-release 
yum install -y pam_script
yum install -y docker
systemctl enable --now docker
# Update packages
# yum -y update

# set permissive mode
setenforce 0

# Let's begin
groupadd admin
sudo useradd allday
sudo useradd workday 
usermod root -a -G admin
usermod allday -a -G admin

echo "Otus2021"|sudo passwd --stdin workday 
echo "Otus2021"|sudo passwd --stdin allday

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

echo "auth       required     pam_script.so" >> /etc/pam.d/sshd
echo "auth       required     pam_script.so" >> /etc/pam.d/su

cat <<'EOF' > /etc/pam_script
#!/bin/bash
# if user group=admin then exit
if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then exit 0
fi
# check day of week
if [[ `date +%u` > 5 ]]
then exit 1
else exit 0
fi
EOF

chmod +x /etc/pam_script
systemctl restart sshd

# allow user allday work with Docker
setfacl -m u:allday:rw /var/run/docker.sock
# allow user allday restart Docker
sudo echo "allday ALL=(ALL) NOPASSWD: /bin/systemctl * docker" >> /etc/sudoers