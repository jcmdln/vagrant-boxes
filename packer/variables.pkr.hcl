// SPDX-License-Identifier: ISC

variable "cpus" {
  type = number
  default = 2
}

variable "firmware" {
  type = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
}

variable "headless" {
  type = bool
  default = true
}

variable "qemu_accel" {
  type = string
  default = "kvm"
}

variable "qemu_cpu" {
  type = string
  default = "qemu64"
}

variable "qemu_machine" {
  type = string
  default = "q35"
}
