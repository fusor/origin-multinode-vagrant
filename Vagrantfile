# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  servers.each do |servers|
    if servers["ram"] < 512
      puts "WARNING: Your machine should have at least 512 MB of memory"
    end

    config.vm.define servers["name"] do |srv|
      srv.vm.hostname= servers["name"] + ".example.com"
      srv.hostmanager.aliases = servers["name"]
      srv.vm.box = servers["box"]
      srv.vm.box_url = servers["box_url"]
      srv.vm.network :private_network,
        :ip => servers["ip"]
        # :libvirt__netmask => "255.255.255.0",
        # :libvirt__network_name => "centos_cluster_net",
        # :libvirt__dhcp_enabled => false
      srv.vm.provider :libvirt do |lv|
        lv.driver = "kvm"
        lv.memory = servers["ram"]
        lv.cpus = servers["vcpus"]
        lv.machine_virtual_size = servers["disk"]
      end
    end
  end
end
