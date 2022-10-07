# SPDX-License-Identifier: ISC

variable "os_arch" {
  type = string
  default = "x86_64"
}

variable "os_version" {
  type = number
  default = 22.05
}

variable "qemu_accel" {
  type = string
  default = "kvm"
}

variable "qemu_bios" {
  type = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
}

variable "qemu_cpu" {
  type = string
  default = "qemu64"
}

variable "qemu_machine" {
  type = string
  default = "q35"
}

variable "qemu_ssh_timeout" {
  type = string
  default = "15m"
}

locals {
  output_path = "./build/nixos/${var.os_version}/${var.os_arch}"
}

source "qemu" "nixos" {
  accelerator = "${var.qemu_accel}"
  boot_command = [
    "sudo -i<enter><wait2>",
    "curl -LO http://{{ .HTTPIP }}:{{ .HTTPPort }}/configuration.nix<enter><wait5>",
    "curl -LO http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.sh<enter><wait5>",
    "bash install.sh<enter>"
  ]
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "25G"
  format = "qcow2"
  headless = true
  http_directory = "./nixos"
  # FIXME: Vagrant can't verify NixOS' checksum format?
  # iso_checksum = "file:https://channels.nixos.org/nixos-${var.os_version}/latest-nixos-minimal-${var.os_arch}-linux.iso.sha256"
  iso_checksum = "sha256:03bd1df7cc5773f17884959757b78df68c30aa5eec2fbe4563ac3385b20cd4e0"
  iso_url = "https://channels.nixos.org/nixos-${var.os_version}/latest-nixos-minimal-${var.os_arch}-linux.iso"
  memory = 2048
  output_directory = "${local.output_path}"
  qemuargs = [
    ["-accel", "${var.qemu_accel}"],
    ["-bios", "${var.qemu_bios}"],
    ["-cpu", "${var.qemu_cpu}"],
    ["-machine", "${var.qemu_machine}"],
  ]
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "${var.qemu_ssh_timeout}"
  ssh_username = "vagrant"
  vm_name = "nixos-${var.os_version}-${var.os_arch}.qcow2"
}

build {
  sources = ["sources.qemu.nixos"]

  post-processor "vagrant" {
    compression_level = 9
    keep_input_artifact = true
    output = "${local.output_path}/nixos-${var.os_version}-${var.os_arch}.box"
    provider_override = "libvirt"
    vagrantfile_template = "./nixos/Vagrantfile.template"
  }

  post-processor "shell-local" {
    environment_vars = [
      "BOX_ARCH=${var.os_arch}",
      "BOX_NAME=nixos",
      "BOX_VERSION=${var.os_version}"
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}
