source "qemu" "guix" {
  accelerator = var.accelerator
  boot_command = [
    "<leftCtrlOn><leftAltOn><f4><leftAltOff><leftCtrlOff><enter>",
    "passwd<enter>vagrant<enter>vagrant<enter>",
    "herd start ssh-daemon<enter>",
  ]
  boot_wait = "60s"
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
  net_device = "virtio-net-pci"
  output_directory = "build/${replace(source.name, "-", "/")}/"
  shutdown_command = "shutdown"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "root"
  vm_name = "${source.name}.qcow2"
}

build {
  name = "guix"

  source "source.qemu.guix" {
    name = "guix-1.3.0-x86_64"
    iso_checksum = "sha256:f2b30458fa1736eeee3b82f34aab1d72f3964bef0477329bb75281d2b7bb6d4b"
    iso_url = "https://ftpmirror.gnu.org/gnu/guix/guix-system-install-1.3.0.x86_64-linux.iso"
  }

  source "source.qemu.guix" {
    name = "guix-1.4.0-x86_64"
    iso_checksum = "sha256:087a97dba2319477185471a28812949cc165e60e58863403e4a606c1baa05f81"
    iso_url = "https://ftpmirror.gnu.org/gnu/guix/guix-system-install-1.4.0.x86_64-linux.iso"
  }

  provisioner "shell" {
    name = "setup-partitions"
    script = "packer/assets/guix/setup-partitions.sh"
  }

  provisioner "file" {
    name = "guix-config"
    source = "packer/assets/guix/config.scm"
    destination = "/root/config.scm"
  }

  provisioner "shell" {
    name = "guix-install"
    inline = [
      "set -ex",
      "herd start cow-store /mnt",
      "mkdir /mnt/etc",
      "cp /root/config.scm /mnt/etc/config.scm",
      "guix system init /mnt/etc/config.scm /mnt",
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
