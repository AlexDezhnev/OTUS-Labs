# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:inetRouter => {
        :box_name => "centos/7",
        #:public => {:ip => '10.10.10.1', :adapter => 1},
        :net => [
            {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
        ],
        routes: [
            { dst: "192.168.0.0/16", src: "192.168.255.2", connection: "System eth1" },
        ],
        masquerade: true,
        isRouter: true,
  },
 
  :centralRouter => {
        :box_name => "centos/7",
        :net => [
            {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
            {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
            {ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
            {ip: '192.168.0.65', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "mgt-net"},
                ],
        routes: [
            { dst: "192.168.1.0/24", src: "192.168.0.35", connection: "System eth3" },
            { dst: "192.168.2.0/24", src: "192.168.0.34", connection: "System eth3" },
        ],
        gateway: { ip: "192.168.255.1", connection: "System eth1" },
        dns: { ip: "9.9.9.9", connection: "System eth1" },
        isRouter: true,
  },
  
  :centralServer => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   #{adapter: 3, auto_config: false, virtualbox__intnet: true},
                   #{adapter: 4, auto_config: false, virtualbox__intnet: true},
                ],
        gateway: { ip: "192.168.0.1", connection: "System eth1" },
        dns: { ip: "9.9.9.9", connection: "System eth1" },
  },

  :office1Router => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.0.34', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
               {ip: '192.168.2.1', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "dev1-net"},
               {ip: '192.168.2.65', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "test1-net"},
               {ip: '192.168.2.129', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "manager1-net"},
               {ip: '192.168.2.193', adapter: 6, netmask: "255.255.255.192", virtualbox__intnet: "hw1-net"},
            ],
    gateway: { ip: "192.168.0.33", connection: "System eth1" },
    dns: { ip: "9.9.9.9", connection: "System eth1" },
    isRouter: true,
  },

  :office1Server => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.2.66', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test1-net"},
               #{adapter: 3, auto_config: false, virtualbox__intnet: true},
               #{adapter: 4, auto_config: false, virtualbox__intnet: true},
            ],
    gateway: { ip: "192.168.2.1", connection: "System eth1" },
    dns: { ip: "9.9.9.9", connection: "System eth1" },
  },

  :office2Router => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.0.35', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
               {ip: '192.168.1.1', adapter: 3, netmask: "255.255.255.128", virtualbox__intnet: "dev2-net"},
               {ip: '192.168.1.129', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "test2-net"},
               {ip: '192.168.1.193', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "hw2-net"},
            ],
    gateway: { ip: "192.168.0.33", connection: "System eth1" },
    dns: { ip: "9.9.9.9", connection: "System eth1" },
    isRouter: true,
  },

  :office2Server => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.1.130', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "test2-net"},
               #{adapter: 3, auto_config: false, virtualbox__intnet: true},
               #{adapter: 4, auto_config: false, virtualbox__intnet: true},
            ],
    gateway: { ip: "192.168.1.1", connection: "System eth1" },
    dns: { ip: "9.9.9.9", connection: "System eth1" },
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    # Disable shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
        SHELL

        box.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode="2.0"
          ansible.playbook = "playbook.yml"
        end

        if boxconfig[:masquerade] then
          box.vm.provision "shell", inline: <<-SHELL
              iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
          SHELL
        end

        if boxconfig[:isRouter] then
          box.vm.provision "shell", inline: <<-SHELL
              echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
              sysctl -p /etc/sysctl.conf
          SHELL
        end

        if boxconfig[:routes] then
          boxconfig[:routes].each do |route|
              box.vm.provision "shell" do |s|
                  s.inline = <<-SHELL
                      nmcli connection modify "$1" +ipv4.routes "$2 $3"
                      nmcli connection up "$1"
                  SHELL
                  s.args = [route[:connection], route[:dst], route[:src]]
              end
          end
        end

        if boxconfig[:dns] then
          box.vm.provision "shell" do |s|
              s.inline = <<-SHELL
                  nmcli connection modify "$1" ipv4.dns "$2"
                  nmcli connection up "$1"
                  route del -net 0.0.0.0 eth0
              SHELL
              s.args = [boxconfig[:dns][:connection], boxconfig[:dns][:ip]]
          end
        end

        if boxconfig[:gateway] then
          box.vm.provision "shell" do |s|
              s.inline = <<-SHELL
                  nmcli connection modify "$1" ipv4.gateway "$2"
                  nmcli connection up "$1"
              SHELL
              s.args = [boxconfig[:gateway][:connection], boxconfig[:gateway][:ip]]
          end
        end

    end
  
  end
  
end

