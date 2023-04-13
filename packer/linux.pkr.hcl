source "qemu" "linux" {
  accelerator = var.accelerator
  boot_wait = "30s"
  cdrom_interface = "virtio"
  cpu_model = var.cpu_model
  cpus = var.cpus
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  firmware = var.firmware
  format = "qcow2"
  headless = var.headless
  http_directory = "packer/assets/${split("_", "${source.name}")[0]}"
  machine_type = var.machine_type
  memory = var.memory
  net_device = "virtio-net-pci"
  output_directory = "build/${replace(source.name, "_", "/")}/"
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "vagrant"
  vm_name = "${source.name}.qcow2"
}

build {
  name = "linux"

  source "source.qemu.linux" {
    name = "centos_9-stream_x86_64"
    boot_command = [
      "e<down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
      "<leftCtrlOn>x<leftCtrlOff>",
    ]
    iso_checksum = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM"
    iso_url = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
  }

  // source "source.qemu.linux" {
  //   name = "debian_11_amd64"
  //   boot_command = [
  //     "e<down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
  //     "<leftCtrlOn>x<leftCtrlOff>",
  //   ]
  //   iso_checksum = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
  //   iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
  // }

  source "source.qemu.linux" {
    name = "fedora_37_x86_64"
    boot_command = [
      "e<down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
      "<leftCtrlOn>x<leftCtrlOff>",
    ]
    iso_checksum = "file:https://mirrors.kernel.org/fedora/releases/37/Everything/x86_64/iso/Fedora-Everything-37-1.7-x86_64-CHECKSUM"
    iso_url = "https://mirrors.kernel.org/fedora/releases/37/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-37-1.7.iso"
  }

  provisioner "shell" {
    name = "vagrant-pubkey"
    script = "tools/vagrant-pubkey.sh"
  }

  post-processor "vagrant" {
    name = "vagrant-box"
    compression_level = 9
    keep_input_artifact = true
    output = "build/${replace(source.name, "_", "/")}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "packer/assets/${split("_", "${source.name}")[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    name = "vagrant-manifest"
    environment_vars = [
      "BOX_NAME=${split("_", "${source.name}")[0]}",
      "BOX_VERSION=${split("_", "${source.name}")[1]}",
      "BOX_ARCH=${split("_", "${source.name}")[2]}",
    ]
    script = "tools/vagrant-manifest.sh"
  }
}
