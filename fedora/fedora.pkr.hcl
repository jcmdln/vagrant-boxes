# SPDX-License-Identifier: ISC

variable "os_arch" {
  type = string
  default = "x86_64"
}

variable "os_mirror" {
  type = string
  default = "https://mirrors.kernel.org/fedora/releases"
}

variable "os_version" {
  type = number
  default = 36
}

variable "os_version_minor" {
  type = number
  default = 1.5
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
  iso_version = "${var.os_version}-${var.os_version_minor}"
  iso_name = "Fedora-Everything-netinst-${var.os_arch}-${local.iso_version}.iso"
  iso_checksum = "Fedora-Everything-${local.iso_version}-${var.os_arch}-CHECKSUM"
  mirror_path = "${var.os_mirror}/${var.os_version}/Everything/${var.os_arch}/iso"
  output_path = "./build/fedora/${var.os_version}/${var.os_arch}"
}

source "qemu" "fedora" {
  accelerator = "${var.qemu_accel}"
  boot_command = [
      "e<down><down><end> ",
      "inst.text ",
      "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg ",
      "<leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_wait = "10s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  format = "qcow2"
  headless = true
  http_directory = "./fedora"
  iso_checksum = "file:${local.mirror_path}/${local.iso_checksum}"
  iso_url = "${local.mirror_path}/${local.iso_name}"
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
  vm_name = "fedora-${var.os_version}-${var.os_arch}.qcow2"
}

build {
  sources = ["sources.qemu.fedora"]

  provisioner "shell" {
    script = "./tools/vagrant-pubkey.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo dnf --refresh -y upgrade --allowerasing --best"
    ]
  }

  post-processor "vagrant" {
    compression_level = 9
    keep_input_artifact = true
    output = "${local.output_path}/fedora-${var.os_version}-${var.os_arch}.box"
    provider_override = "libvirt"
    vagrantfile_template = "./fedora/Vagrantfile.template"
  }

  post-processor "shell-local" {
    environment_vars = [
      "BOX_ARCH=${var.os_arch}",
      "BOX_NAME=fedora",
      "BOX_VERSION=${var.os_version}"
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}
