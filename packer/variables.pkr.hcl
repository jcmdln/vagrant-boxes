variable "accelerator" {
  type = string
  default = "kvm"
}

variable "cpu_model" {
  type = string
  default = "Nehalem"
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

variable "machine_type" {
  type = string
  default = "q35"
}

variable "memory" {
  type = number
  default = 2048
}
