source "qemu" "centos" {
  accelerator = "kvm"
  boot_command = [
    "e<down><down><end> ",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg ",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
  boot_wait = "30s"
  cpus = var.cpus
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  firmware = var.firmware
  format = "qcow2"
  headless = var.headless
  http_directory = "packer/assets/centos"
  memory = 2048
  qemuargs = [
    ["-accel", var.qemu_accel],
    ["-cpu", var.qemu_cpu],
    ["-machine", var.qemu_machine],
  ]
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_username = "vagrant"
  ssh_timeout = "30m"
}

build {
  name = "centos"

  source "source.qemu.centos" {
    name = "centos-8stream-x86_64"
    output_directory = "build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "file:http://mirror.cs.vt.edu/pub/CentOS/8-stream/isos/x86_64/CHECKSUM"
    iso_url = "http://mirror.cs.vt.edu/pub/CentOS/8-stream/isos/x86_64/CentOS-Stream-8-20230404.0-x86_64-boot.iso"
  }

  source "source.qemu.centos" {
    name = "centos-9stream-x86_64"
    output_directory = "build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-dvd1.iso.SHA256SUM"
    iso_url = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
  }

  provisioner "shell" {
    name = "vagrant-pubkey"
    script = "tools/vagrant-pubkey.sh"
  }

  post-processor "vagrant" {
    name = "vagrant-box"
    compression_level = 9
    keep_input_artifact = true
    output = "build/${replace(source.name, "-", "/")}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "packer/assets/${split("-", source.name)[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    name = "vagrant-manifest"
    environment_vars = [
      "BOX_NAME=${split("-", source.name)[0]}",
      "BOX_VERSION=${split("-", source.name)[1]}",
      "BOX_ARCH=${split("-", source.name)[2]}",
    ]
    script = "tools/vagrant-manifest.sh"
  }
}
