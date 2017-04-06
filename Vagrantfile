# -*- mode: ruby -*-
# vi: set ft=ruby :

NODES = 3 # The NODES must be three for the vagrant snapshot'd environment
DISKS = 3

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.insert_key = false

  # skip vagrant-registration
  config.registration.skip = true

  config.vm.synced_folder ".", "/vagrant", :disabled => true

  # nodes
  (1..NODES).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname="node#{i}.example.com"
      node.vm.box = "node#{i}_origin_1.5.0.rc"
      #node.vm.box_url = "https://s3.amazonaws.com/fusor-vagrant/origin_1.5.0_rc/node1_origin_1.5.0.rc.box"
      node.vm.box_url = "http://ec2-23-22-86-129.compute-1.amazonaws.com/pub/vagrant_boxes/origin_1.5.0_rc/node#{i}_origin_1.5.0.rc.box"

      node.vm.network :private_network,
        :ip => "192.168.166.#{5+i}",
        :libvirt__netmask => "255.255.255.0",
        :libvirt__network_name => "centos_cluster_net",
        :libvirt__dhcp_enabled => false
        (0..DISKS-1).each do |d|
          node.vm.provider :libvirt do  |lv|
              driverletters = ('b'..'z').to_a
              lv.storage :file, :device => "vd#{driverletters[d]}", :path => "atomic-disk-#{i}-#{d}.disk", :size => '1024G'
              lv.driver = "kvm"
              lv.memory = 4096
              lv.cpus =2
          end
        end
    end
  end

  # master node
  config.vm.define "master" do |master|
    master.vm.hostname="master.example.com"
    master.vm.box = "master_origin_1.5.0.rc"
    #master.vm.box_url = "https://s3.amazonaws.com/fusor-vagrant/origin_1.5.0_rc/master_origin_1.5.0.rc.box"
    master.vm.box_url = "http://ec2-23-22-86-129.compute-1.amazonaws.com/pub/vagrant_boxes/origin_1.5.0_rc/master_origin_1.5.0.rc.box"

    master.vm.network :private_network,
      :ip => "192.168.166.5",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__network_name => "centos_cluster_net",
      :libvirt__dhcp_enabled => false
    master.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 8192
      libvirt.cpus = 4
    end
  end

  config.vm.provision :ansible do |ansible|
      ansible.verbose = true
      ansible.limit = "all"
      ansible.playbook = "site.yml"
      ansible.inventory_path = "./inventory"
  end
end
