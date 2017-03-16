# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.insert_key = false

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.define "node1" do |node1|
    node1.vm.hostname="node1.example.com"
    node1.vm.box = "origin-node1.box"
    node1.vm.network :private_network,
      :ip => "192.168.156.6",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__network_name => "centos_cluster_net",
      :libvirt__dhcp_enabled => false
    node1.vm.synced_folder ".", "/vagrant", type: "nfs"
    node1.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 4096
      libvirt.cpus = 2
    end
  end

  config.vm.define "node2" do |node2|
    node2.vm.hostname="node2.example.com"
    node2.vm.box = "origin-node2.box"
    node2.vm.network :private_network,
      :ip => "192.168.156.7",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__network_name => "centos_cluster_net",
      :libvirt__dhcp_enabled => false
    node2.vm.synced_folder ".", "/vagrant", type: "nfs"
    node2.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 4096
      libvirt.cpus = 2
    end
  end

  config.vm.define "master" do |master|
    master.vm.hostname="master.example.com"
    master.vm.box = "origin-master.box"

    master.vm.provision :shell, :path => "setup.sh", :args => "master"
    master.vm.network :private_network,
      :ip => "192.168.156.5",
      :libvirt__netmask => "255.255.255.0",
      :libvirt__network_name => "centos_cluster_net",
      :libvirt__dhcp_enabled => false
    master.vm.synced_folder ".", "/vagrant", type: "nfs"
    master.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 8192
      libvirt.cpus = 4
    end
  end
end
