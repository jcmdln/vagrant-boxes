variable "accelerator" {
  type = string
  default = "kvm"
}

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

variable "memory" {
  type = number
  default = 2048
}

variable "qemu_cpu" {
  type = string
  default = "Nehalem"
}

variable "qemu_machine" {
  type = string
  default = "q35"
}
