// SPDX-License-Identifier: ISC

source "qemu" "nixos" {
  accelerator = "kvm"
  boot_command = [
    "sudo -i<enter>",
    "passwd<enter>vagrant<enter>vagrant<enter>",
    "systemctl start sshd.service<enter>"
  ]
  boot_wait = "30s"
  cpus = var.cpus
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  firmware = var.firmware
  format = "qcow2"
  headless = var.headless
  http_directory = "./assets/nixos"
  memory = 2048
  qemuargs = [
    ["-accel", var.qemu_accel],
    ["-cpu", var.qemu_cpu],
    ["-machine", var.qemu_machine],
  ]
  shutdown_command = "poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_username = "root"
  ssh_timeout = "30m"
}

build {
  name = "nixos"

  source "source.qemu.nixos" {
    name = "nixos-22.05-x86_64"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "sha256:03bd1df7cc5773f17884959757b78df68c30aa5eec2fbe4563ac3385b20cd4e0"
    iso_url = "https://releases.nixos.org/nixos/22.05/nixos-22.05.3377.c9389643ae6/nixos-minimal-22.05.3377.c9389643ae6-x86_64-linux.iso"
  }

  source "source.qemu.nixos" {
    name = "nixos-22.11-x86_64"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "sha256:53fa8398deb867b27f93f84bc2af6065f61ae4560be42368345c666e29b8282b"
    iso_url = "https://releases.nixos.org/nixos/22.11/nixos-22.11.968.9d692a724e7/nixos-minimal-22.11.968.9d692a724e7-x86_64-linux.iso"
  }

  provisioner "shell" {
    name = "nixos-install"
    script = "./assets/nixos/install.sh"
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
