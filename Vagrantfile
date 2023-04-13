ENV["VAGRANT_NO_PARALLEL"] = "yes"

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-libvirt"]

  config.nfs.verify_installed = false
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider "libvirt" do |v|
    v.cpus = 2
    v.memory = 2048
  end

  config.vm.define "centos" do |c|
    c.vm.box = "jcmdln/centos"
  end

  config.vm.define "fedora" do |c|
    c.vm.box = "jcmdln/fedora"
  end

  config.vm.define "guix" do |c|
    c.vm.box = "jcmdln/guix"
  end

  config.vm.define "nixos" do |c|
    c.vm.box = "jcmdln/nixos"
  end

  config.vm.define "openbsd" do |c|
    c.vm.box = "jcmdln/openbsd"
  end
end
