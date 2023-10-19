source "qemu" "debian" {
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
  http_directory = "packer/assets/${split("-", "${source.name}")[0]}"
  machine_type = var.machine_type
  memory = var.memory
  output_directory = "build/${replace(source.name, "-", "/")}"
  net_device = "virtio-net-pci"
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "vagrant"
  vm_name = "${source.name}.qcow2"
}

build {
  name = "debian"

  source "source.qemu.debian" {
    name = "debian-12-x86_64"
    // iso_checksum = "file:"
    // iso_url = ""
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
    vagrantfile_template = "packer/assets/${split("-", "${source.name}")[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    name = "vagrant-manifest"
    environment_vars = [
      "BOX_NAME=${split("-", "${source.name}")[0]}",
      "BOX_VERSION=${split("-", "${source.name}")[1]}",
      "BOX_ARCH=${split("-", "${source.name}")[2]}",
    ]
    script = "tools/vagrant-manifest.sh"
  }
}
