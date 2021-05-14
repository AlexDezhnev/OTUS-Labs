echo "192.168.50.10:/var/nfs-share    /mnt    nfs    rw,vers=3,proto=udp,x-systemd.automount   0 0" >> /etc/fstab
sudo systemctl start nfs
sudo mount 192.168.50.10:/var/nfs-share /mnt