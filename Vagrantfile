# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/vivid64"
    if Vagrant.has_plugin?("vagrant-cachier")
      # Configure cached packages to be shared between instances of the same base box.
      # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
      config.cache.scope = :box
    end

    master.vm.synced_folder "./environment_production", "/etc/puppetlabs/code/environments/production"

    master.vm.provider "virtualbox" do |vb|
      #   # Display the VirtualBox GUI when booting the machine
      #   vb.gui = true
      #
      #   # Customize the amount of memory on the VM:
        vb.memory = "3072"
    end

    master.vm.network "private_network", ip: "192.168.1.254", virtualbox__intnet: "nxosv_network1"

    master.vm.provision "shell", privileged: false, inline: <<-SHELL
      sudo wget https://apt.puppetlabs.com/puppetlabs-release-pc1-vivid.deb
      sudo dpkg -i puppetlabs-release-pc1-vivid.deb
      sudo apt-get update
      sudo apt-get -y install puppetserver
      sudo sh -c 'echo "dns_alt_names = localhost, master" >> /etc/puppetlabs/puppet/puppet.conf'
      sudo sh -c 'echo "autosign = true" >> /etc/puppetlabs/puppet/puppet.conf'
      sudo service puppetserver start
      sudo /opt/puppetlabs/bin/puppet module install puppetlabs-ciscopuppet
    SHELL

  end


  config.vm.define "n9kv1" do |n9kv1|
        n9kv1.vm.box = "n9kv"

        if Vagrant.has_plugin?("vagrant-cachier")
          config.cache.disable!
        end

        n9kv1.ssh.insert_key = false
        n9kv1.vm.boot_timeout = 420
        n9kv1.vm.synced_folder '.', '/vagrant', disabled: true
        n9kv1.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
        n9kv1.vm.network "private_network", ip: "192.168.1.2", auto_config: false, virtualbox__intnet: "nxosv_network1"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network2"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network3"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network4"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network5"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network6"
        n9kv1.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network7"
        n9kv1.vm.provider :virtualbox do |vb|
                vb.customize ['modifyvm',:id,'--nicpromisc2','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc3','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc4','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc5','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc6','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc7','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc8','allow-all']
        end
        n9kv1.vm.provision "shell", privileged: true, inline: <<-SHELL
          sleep 30 #otherwise the interfaces might not be ready for configuration 

          # Configure Eth1/1 with unique MAC and IP

          echo -e 'hostname n9kv1\ndefault interface Ethernet1/1\ninterface Ethernet1/1\n no shutdown\n no switchport\n\n mac-address 1.1.1'> /tmp/mac-cfg
          vsh -r /tmp/mac-cfg
          ip add add 192.168.1.1/24 dev Eth1-1

          echo "192.168.1.254    master">>/etc/hosts
          echo "nameserver 10.0.2.3" > /etc/resolv.conf
          vsh -c 'copy running-config startup-config'

          ip netns exec management rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
          ip netns exec management rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-reductive
          ip netns exec management yum -y install http://yum.puppetlabs.com/puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm
          ip netns exec management yum -y install puppet

          echo -e '[main]\nserver = master\n[agent]\npluginsync  = true\nignorecache = true' > /etc/puppetlabs/puppet/puppet.conf

          ip netns exec management /opt/puppetlabs/puppet/bin/gem install --no-rdoc --no-ri cisco_node_utils

          echo -e '\n\n----------------\n\nProvisioning complete, next connect to the NX-OSv instance ("vagrant ssh n9kv1") and run the puppet agent ("sudo /opt/puppetlabs/bin/puppet agent -t")\n'

        SHELL
  end
 
  config.vm.define "n9kv2" do |n9kv2|
        n9kv2.vm.box = "n9kv"

        if Vagrant.has_plugin?("vagrant-cachier")
          config.cache.disable!
        end

        n9kv2.ssh.insert_key = false
        n9kv2.vm.boot_timeout = 420
        n9kv2.vm.synced_folder '.', '/vagrant', disabled: true
        n9kv2.vm.network "forwarded_port", guest: 80, host: 8081, auto_correct: true
        n9kv2.vm.network "private_network", ip: "192.168.1.3", auto_config: false, virtualbox__intnet: "nxosv_network1"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network2"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network3"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network4"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network5"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network6"
        n9kv2.vm.network "private_network", auto_config: false, virtualbox__intnet: "nxosv_network7"
        n9kv2.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm",:id,"--nicpromisc2","allow-all"]
                vb.customize ['modifyvm',:id,'--nicpromisc3','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc4','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc5','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc6','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc7','allow-all']
                vb.customize ['modifyvm',:id,'--nicpromisc8','allow-all']
        end
        n9kv2.vm.provision "shell", privileged: true, inline: <<-SHELL
          sleep 30 #otherwise the interfaces might not be ready for configuration 

          # Configure Eth1/1 with unique MAC and IP
          echo -e 'hostname n9kv2\ndefault interface Ethernet1/1\ninterface Ethernet1/1\n no shutdown\n no switchport\n\n mac-address 1.1.2'> /tmp/mac-cfg
          vsh -r /tmp/mac-cfg
          ip add add 192.168.1.2/24 dev Eth1-1

          echo "192.168.1.254    master">>/etc/hosts
          echo "nameserver 10.0.2.3" > /etc/resolv.conf
          vsh -c 'copy running-config startup-config'

          ip netns exec management rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
          ip netns exec management rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-reductive
          ip netns exec management yum -y install http://yum.puppetlabs.com/puppetlabs-release-pc1-cisco-wrlinux-5.noarch.rpm
          ip netns exec management yum -y install puppet

          echo -e '[main]\nserver = master\n[agent]\npluginsync  = true\nignorecache = true' > /etc/puppetlabs/puppet/puppet.conf

          ip netns exec management /opt/puppetlabs/puppet/bin/gem install --no-rdoc --no-ri cisco_node_utils

          echo -e '\n\n----------------\n\nProvisioning complete, next connect to the NX-OSv instance ("vagrant ssh n9kv2") and run the puppet agent ("sudo /opt/puppetlabs/bin/puppet agent -t")\n'
        SHELL
  end
end