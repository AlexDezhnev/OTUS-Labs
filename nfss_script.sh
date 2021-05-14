mkdir -p /var/nfs-share/upload
chmod 777 /var/nfs-share/upload/
systemctl start nfs
echo "/var/nfs-share 192.168.50.11(rw,root_squash,no_all_squash)" >> /etc/exports
exportfs -r
sudo systemctl start firewalld
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --reload