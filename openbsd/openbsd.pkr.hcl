# SPDX-License-Identifier: ISC

variable "os_arch" {
  type = string
  default = "amd64"
}

variable "os_mirror" {
  type = string
  default = "https://cdn.openbsd.org/pub/OpenBSD"
}

variable "os_version" {
  type = string
  default = "7.0"
}

variable "qemu_accel" {
  type = string
  default = "kvm"
}

variable "qemu_cpu" {
  type = string
  default = "host"
}

variable "qemu_ssh_timeout" {
  type = string
  default = "15m"
}

locals {
  version_flat = replace("${var.os_version}", ".", "")
  iso_name = "cd${local.version_flat}.iso"
  mirror_path = "${var.os_mirror}/${var.os_version}/${var.os_arch}"
  output_path = "./build/openbsd/${var.os_version}/${var.os_arch}"
}

source "qemu" "openbsd" {
  accelerator = "${var.qemu_accel}"
  boot_command = [
    "a<enter>",
    "<wait5>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter>",
    "<wait15>",
    "i<enter>",
  ]
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "100G"
  format = "qcow2"
  headless = true
  http_directory = "./openbsd"
  iso_checksum = "file:${local.mirror_path}/SHA256"
  iso_url = "${local.mirror_path}/${local.iso_name}"
  memory = 2048
  net_device = "virtio-net"
  output_directory = "${local.output_path}"
  qemuargs = [
    ["-accel", "${var.qemu_accel}"],
    ["-cpu", "${var.qemu_cpu}"],
    ["-machine", "q35"],
  ]
  shutdown_command = "shutdown -h -p now"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "${var.qemu_ssh_timeout}"
  ssh_username = "root"
  vm_name = "openbsd.qcow2"
}

build {
  sources = ["sources.qemu.openbsd"]

  provisioner "shell" {
    inline = [
      "cp /etc/examples/doas.conf /etc/doas.conf",
      "echo 'permit nopass vagrant' >> /etc/doas.conf",
      "doas -C /etc/doas.conf",
    ]
  }

  # Package the image as a Vagrant box
  post-processor "vagrant" {
    compression_level = 9
    keep_input_artifact = true
    output = "${local.output_path}/openbsd.box"
    provider_override = "libvirt"
  }

  # Generate Vagrant manifest.json
  post-processor "shell-local" {
    environment_vars = [
      "BOX_ARCH=${var.os_arch}",
      "BOX_NAME=openbsd",
      "BOX_VERSION=${var.os_version}"
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}
