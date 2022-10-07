# SPDX-License-Identifier: ISC

ENV["VAGRANT_NO_PARALLEL"] = "yes"

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-libvirt"]

  config.vm.provider "libvirt" do |v|
    v.cpus = 2
    v.memory = 2048
  end

  config.vm.define "fedora" do |c|
    c.vm.box = "jcmdln/fedora"

    c.nfs.verify_installed = false
    c.vm.synced_folder '.', '/vagrant', disabled: true
  end

  config.vm.define "openbsd" do |c|
    c.vm.box = "jcmdln/openbsd"
  end

  config.vm.define "nixos" do |c|
    c.vm.box = "jcmdln/nixos"
  end
end
