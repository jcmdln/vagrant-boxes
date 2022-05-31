# SPDX-License-Identifier: ISC

ENV["VAGRANT_DEFAULT_PROVIDER"] = "libvirt"
ENV["VAGRANT_NO_PARALLEL"] = "yes"

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-libvirt", "vagrant-hostmanager"]

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = false

  config.nfs.verify_installed = false
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider "libvirt" do |v|
    v.cpus = 2
    v.memory = 2048
  end

  config.vm.define "fedora" do |c|
    c.vm.box = "jcmdln/fedora"
    c.vm.provider "libvirt" do |v|
      v.loader = "/usr/share/OVMF/OVMF_CODE.fd"
    end
  end

  config.vm.define "openbsd" do |c|
    c.ssh.shell = "/bin/ksh -l"
    c.ssh.sudo_command = "doas %c"
    c.vm.box = "jcmdln/openbsd"
  end
end
