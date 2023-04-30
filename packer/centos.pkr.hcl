source "qemu" "centos" {
  accelerator = var.accelerator
  boot_command = [
    "e<down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
    "<leftCtrlOn>x<leftCtrlOff>",
  ]
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
  http_directory = "packer/assets/centos"
  machine_type = var.machine_type
  memory = var.memory
  net_device = "virtio-net-pci"
  output_directory = "build/centos/${split("-", "${source.name}")[1]}-stream/${split("-", "${source.name}")[3]}"
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "vagrant"
  vm_name = "${source.name}.qcow2"
}

build {
  name = "centos"

  source "source.qemu.centos" {
    name = "centos-9-stream-x86_64"
    iso_checksum = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM"
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
    output = "build/centos/${split("-", "${source.name}")[1]}-stream/${split("-", "${source.name}")[3]}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "packer/assets/centos/Vagrantfile.template"
  }

  post-processor "shell-local" {
    name = "vagrant-manifest"
    environment_vars = [
      "BOX_NAME=centos",
      "BOX_VERSION=${split("-", "${source.name}")[1]}-stream",
      "BOX_ARCH=${split("-", "${source.name}")[3]}",
    ]
    script = "tools/vagrant-manifest.sh"
  }
}
