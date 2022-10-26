// SPDX-License-Identifier: ISC

source "qemu" "openbsd" {
  accelerator = "kvm"
  boot_command = [
    "a<enter><wait5>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait15>",
    "i<enter>",
  ]
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  format = "qcow2"
  headless = true
  http_directory = "./assets/openbsd"
  memory = 2048
  qemuargs = [
    ["-accel", "kvm"],
    //["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-cpu", "qemu64"],
    ["-machine", "q35"],
  ]
  shutdown_command = "shutdown -h -p now"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_username = "root"
  ssh_timeout = "30m"
}

build {
  name = "openbsd"

  source "source.qemu.openbsd" {
    name = "openbsd-7.2-amd64"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.2/amd64/SHA256"
    iso_url = "https://cdn.openbsd.org/pub/OpenBSD/7.2/amd64/install72.iso"
  }

  provisioner "shell" {
    name = "vagrant-pubkey"
    script = "./tools/vagrant-pubkey.sh"
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

  provisioner "shell" {
    name = "openbsd-syspatch"
    inline = [
      "set -ex",
      "while [ -n \"$(syspatch -c)\" ]; do syspatch || true; done"
    ]
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
