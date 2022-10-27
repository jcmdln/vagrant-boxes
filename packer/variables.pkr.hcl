// SPDX-License-Identifier: ISC

variable "cpus" {
  type = number
  default = 2
}
variable "headless" {
  type = bool
  default = true
}

variable "qemu_accel" {
  type = string
  default = "kvm"
}

variable "qemu_bios" {
  type = string
  #default = "/usr/share/OVMF/OVMF_CODE.fd"
  default = "/nix/store/p4217lmxk0v3bbbisvx06vy4kb12kp0i-OVMF-202202-fd/FV/OVMF_CODE.fd"
}

variable "qemu_cpu" {
  type = string
  default = "qemu64"
}

variable "qemu_machine" {
  type = string
  default = "q35"
}
