# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']

MACHINES = {
  :server => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.39',
        :disks => {
          :sata1 => {
            :dfile => './sata-server-1.vdi',
            :size => 2048,
            :port => 2
          }
      
        }
  },
  :client => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.38',
        :disks => {
          :sata1 => {
            :dfile => './sata-client-1.vdi',
            :size => 100,
            :port => 2
          }
        },
      
  }
        

}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      # box.vm.network "forwarded_port", guest: 8080, host: 8080
      # box.vm.network "forwarded_port", guest: 8443, host: 8443
      # box.vm.network "forwarded_port", guest: 8022, host: 8022

      #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

      #box.vm.network "public_network", use_dhcp_assigned_default_route: true
      box.vm.network "private_network", ip: boxconfig[:ip_addr]

      box.vm.provider :virtualbox do |vb|
        vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
        vb.customize ["modifyvm", :id, "--memory", "2048"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        #second_disk = "./server1-1.vmdk" 
        #vb.customize ['createhd', '--filename', './sata-server-1.vdi','--variant', 'Fixed', '--size', 2048]
        #vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './sata-server-1.vdi']
        vb.name = boxname.to_s

        boxconfig[:disks].each do |dname, dconf|
           unless File.exist?(dconf[:dfile])
             vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
           end
           vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
        end
      end
 
      case boxname.to_s
        when "server"

          box.vm.provision "shell", run: "always", inline: <<-SHELL
            parted /dev/sdb mklabel gpt -s
            parted /dev/sdb mkpart primary 0% 100% -s
            mkfs -j -t ext4 /dev/sdb1
            mkdir /etc/backup
            mount /dev/sdb1 /etc/backup

            mkdir ~/serverlab
            echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCW+VHI6di+7jZZhnYiCUciVO3oCSJ1xkV+8TINsNy1Itek0BUnorH+Mh6wC5eHoFVsid39v5A5ypzYZvJWhjwu4LNBJFroNhPnpmSBoA7Xk9U+slDI1A6pImop3qQbncMbYMdeyK5yoQO9bgJKDoQG7ak99qp24C4koFHGXO9Bejhenkkct2j0iTQreRyv2y3oSeOvsvQcBFuYS3H0FPhTUII8dx+/tjOTYFaxiA+EkWhuyXfhnrUd60BN5+ajqEgtv4CYZm2MBzDWu3Sor142Ms3R/FbwF1MJKd7JHOzJcTARfnpBqBZi+Or+l9+Pdl8yzxbxO0+9yaj7MGP9eyVT" >> /home/vagrant/.ssh/authorized_keys
            cp /vagrant/id_rsa /home/vagrant/.ssh/
            chown vagrant:vagrant /home/vagrant/.ssh/id_rsa 
            chmod 0600 /home/vagrant/.ssh/id_rsa
            echo "192.168.11.38  client" >> /etc/hosts
            echo "192.168.11.39  server" >> /etc/hosts
          SHELL

          config.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode="2.0"
            ansible.playbook = "playbook-server.yml"
          end

        when "client"

          box.vm.provision "shell", run: "always", inline: <<-SHELL
            mkdir ~/client
            echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCW+VHI6di+7jZZhnYiCUciVO3oCSJ1xkV+8TINsNy1Itek0BUnorH+Mh6wC5eHoFVsid39v5A5ypzYZvJWhjwu4LNBJFroNhPnpmSBoA7Xk9U+slDI1A6pImop3qQbncMbYMdeyK5yoQO9bgJKDoQG7ak99qp24C4koFHGXO9Bejhenkkct2j0iTQreRyv2y3oSeOvsvQcBFuYS3H0FPhTUII8dx+/tjOTYFaxiA+EkWhuyXfhnrUd60BN5+ajqEgtv4CYZm2MBzDWu3Sor142Ms3R/FbwF1MJKd7JHOzJcTARfnpBqBZi+Or+l9+Pdl8yzxbxO0+9yaj7MGP9eyVT" >> /home/vagrant/.ssh/authorized_keys
            cp /vagrant/id_rsa /home/vagrant/.ssh/
            chown vagrant:vagrant /home/vagrant/.ssh/id_rsa 
            chmod 0600 /home/vagrant/.ssh/id_rsa
            echo "192.168.11.38  client" >> /etc/hosts
            echo "192.168.11.39  server" >> /etc/hosts
          SHELL

          config.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode="2.0"
            ansible.playbook = "playbook-client.yml"
          end
          
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            ssh-keyscan server >> ~/.ssh/known_hosts
            BORG_PASSPHRASE=Borg_123456789 borg init --encryption=keyfile borg@server:client_repo
          SHELL
        end

      end
   end
end