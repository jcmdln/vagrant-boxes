// SPDX-License-Identifier: ISC

source "qemu" "builder" {
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  format = "qcow2"
  headless = true
  memory = 2048
  qemuargs = [
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
  ]
  shutdown_command = "echo vagrant | sudo -S poweroff"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_timeout = "30m"
  ssh_username = "vagrant"
}

build {
  name = "fedora"

  source "source.qemu.builder" {
    name = "fedora-36-x86_64"
    boot_command = [
      "e<down><down><end> ",
      "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg ",
      "<leftCtrlOn>x<leftCtrlOff>"
    ]
    http_directory = "./assets/fedora"
    iso_checksum = "file:https://mirrors.kernel.org/fedora/releases/36/Server/x86_64/iso/Fedora-Server-36-1.5-x86_64-CHECKSUM"
    iso_url = "https://mirrors.kernel.org/fedora/releases/36/Server/x86_64/iso/Fedora-Server-netinst-x86_64-36-1.5.iso"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
  }

  post-processor "vagrant" {
    compression_level = 9
    keep_input_artifact = true
    output = "./build/${replace(source.name, "-", "/")}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "./assets/${split("-", source.name)[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    environment_vars = [
      "BOX_NAME=${split("-", source.name)[0]}",
      "BOX_VERSION=${split("-", source.name)[1]}",
      "BOX_ARCH=${split("-", source.name)[2]}",
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}

build {
  name = "nixos"

  source "source.qemu.builder" {
    name = "nixos-22.05-x86_64"
    boot_command = [
      "sudo -i<enter>",
      "curl -LO http://{{ .HTTPIP }}:{{ .HTTPPort }}/configuration.nix<enter><wait5>",
      "curl -LO http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.sh<enter><wait5>",
      "bash install.sh<enter>"
    ]
    http_directory = "./assets/nixos"
    // FIXME: https://github.com/hashicorp/packer/issues/12039
    // iso_checksum = "file:https://channels.nixos.org/nixos-22.05/latest-nixos-minimal-x86_64-linux.iso.sha256"
    // iso_url = "https://channels.nixos.org/nixos-22.05/latest-nixos-minimal-x86_64-linux.iso"
    iso_checksum = "sha256:03bd1df7cc5773f17884959757b78df68c30aa5eec2fbe4563ac3385b20cd4e0"
    iso_url = "https://releases.nixos.org/nixos/22.05/nixos-22.05.3377.c9389643ae6/nixos-minimal-22.05.3377.c9389643ae6-x86_64-linux.iso"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
  }

  post-processor "vagrant" {
    compression_level = 9
    keep_input_artifact = true
    output = "./build/${replace(source.name, "-", "/")}/${source.name}.box"
    provider_override = "libvirt"
    vagrantfile_template = "./assets/${split("-", source.name)[0]}/Vagrantfile.template"
  }

  post-processor "shell-local" {
    environment_vars = [
      "BOX_NAME=${split("-", source.name)[0]}",
      "BOX_VERSION=${split("-", source.name)[1]}",
      "BOX_ARCH=${split("-", source.name)[2]}",
    ]
    script = "./tools/vagrant-manifest.sh"
  }
}

// FIXME: OpenBSD fails to boot using efi
// build {
//   name = "openbsd"

//   source "source.qemu.builder" {
//     name = "openbsd-7.1-amd64"
//     boot_command = [
//       "a<enter><wait5>",
//       "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait15>",
//       "i<enter>",
//     ]
//     http_directory = "./assets/openbsd"
//     iso_checksum = "file:https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/SHA256"
//     iso_url = "https://cdn.openbsd.org/pub/OpenBSD/7.1/amd64/install71.img"
//     output_directory = "./build/openbsd/7.1"
//     vm_name = "${source.name}.qcow2"
//   }

//   provisioner "shell" {
//     script = "./tools/vagrant-pubkey.sh"
//   }

//   provisioner "shell" {
//     inline = [
//       "set -eux",
//       "cp /etc/examples/doas.conf /etc/doas.conf",
//       "echo 'permit nopass vagrant as root' >> /etc/doas.conf",
//       "doas -C /etc/doas.conf",
//       "while [ -n \"$(syspatch -c)\" ]; do syspatch||true; done"
//     ]
//   }

//   post-processor "vagrant" {
//     compression_level = 9
//     keep_input_artifact = true
//     output = "./build/${replace(source.name, "-", "/")}/${source.name}.box"
//     provider_override = "libvirt"
//     vagrantfile_template = "./assets/${split("-", source.name)[0]}/Vagrantfile.template"
//   }

//   post-processor "shell-local" {
//     environment_vars = [
//       "BOX_NAME=${split("-", source.name)[0]}",
//       "BOX_VERSION=${split("-", source.name)[1]}",
//       "BOX_ARCH=${split("-", source.name)[2]}",
//     ]
//     script = "./tools/vagrant-manifest.sh"
//   }
// }
