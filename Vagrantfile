# -*- mode: ruby -*-
# vi: set ft=ruby :
require "fileutils"

CONFIG_FILE = File.expand_path("config_file.rb")
if File.exist?(CONFIG_FILE)
  require CONFIG_FILE
end

if $vm_memory < 512
  puts "WARNING: Your machine should have at least 512 MB of memory"
end

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  (1..$node_count).each do |node|

    config.vm.box = $node_box
    config.vm.define vm_name = "kube#{node}" do |kube|
      kube.hostmanager.aliases = "kube#{node}"
      kube.vm.hostname = "kube#{node}"
      kube.vm.network "private_network", ip: "#{$subnet}.1#{node}", auto_config: true

      kube.vm.provider "libvirt" do |lv|
        lv.driver = "kvm"
        lv.memory = $vm_memory
        lv.cpus = $vm_vcpus
        lv.machine_virtual_size = $vm_disk
      end
    end
  end

  config.vm.box = $master_box
  config.vm.define vm_name = "master" do |kube|
    kube.hostmanager.aliases = "master"
    kube.vm.hostname = "master"
    kube.vm.network "private_network", ip: "#{$subnet}.2#{$node_count}", auto_config: true

    kube.vm.provider "libvirt" do |lv|
      lv.driver = "kvm"
      lv.memory = $vm_memory
      lv.cpus = $vm_vcpus
      lv.machine_virtual_size = $vm_disk
      end
  end
end
