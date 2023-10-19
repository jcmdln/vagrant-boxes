source "qemu" "openbsd" {
  accelerator = var.accelerator
  boot_command = [
    "a<enter><wait5>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait15>",
    "i<enter>",
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
  net_device = "virtio-net"
  output_directory = "build/${replace(source.name, "-", "/")}/"
  shutdown_command = "shutdown -h -p now"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "root"
  vm_name = "${source.name}.qcow2"
}

build {
  name = "openbsd"

  source "source.qemu.openbsd" {
    name = "openbsd-7.3-amd64"
    iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.3/amd64/SHA256"
    iso_url = "https://cdn.openbsd.org/pub/OpenBSD/7.3/amd64/install73.iso"
  }

  source "source.qemu.openbsd" {
    name = "openbsd-7.4-amd64"
    iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.4/amd64/SHA256"
    iso_url = "https://cdn.openbsd.org/pub/OpenBSD/7.4/amd64/install74.img"
  }

  provisioner "shell" {
    name = "vagrant-pubkey"
    script = "tools/vagrant-pubkey.sh"
  }

  provisioner "shell" {
    name = "vagrant-passwordless-doas"
    inline = [
      "set -ex",
      "cp /etc/examples/doas.conf /etc/doas.conf",
      "echo \"permit nopass vagrant as root\" >> /etc/doas.conf",
      "doas -C /etc/doas.conf",
    ]
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
