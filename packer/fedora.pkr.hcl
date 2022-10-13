// SPDX-License-Identifier: ISC

source "qemu" "fedora" {
  accelerator = "kvm"
  boot_command = [
    "e<down><down><end> ",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg ",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  format = "qcow2"
  headless = true
  http_directory = "./assets/fedora"
  memory = 2048
  qemuargs = [
    ["-accel", "kvm"],
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-cpu", "qemu64"],
    ["-machine", "q35"],
  ]
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_username = "vagrant"
  ssh_timeout = "30m"
}

build {
  name = "fedora"

  source "source.qemu.fedora" {
    name = "fedora-36-x86_64"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "file:https://mirrors.kernel.org/fedora/releases/36/Server/x86_64/iso/Fedora-Server-36-1.5-x86_64-CHECKSUM"
    iso_url = "https://mirrors.kernel.org/fedora/releases/36/Server/x86_64/iso/Fedora-Server-netinst-x86_64-36-1.5.iso"
  }

  provisioner "shell" {
    name = "vagrant-pubkey"
    script = "./tools/vagrant-pubkey.sh"
  }

  post-processor "vagrant" {
    name = "vagrant-box"
    compression_level = 9
    keep_input_artifact = true
    output = "./build/${replace(source.name, "-", "/")}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "./assets/${split("-", source.name)[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    name = "vagrant-manifest"
    environment_vars = [
      "BOX_NAME=${split("-", source.name)[0]}",
      "BOX_VERSION=${split("-", source.name)[1]}",
      "BOX_ARCH=${split("-", source.name)[2]}",
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}