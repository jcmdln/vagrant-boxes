// SPDX-License-Identifier: ISC

source "qemu" "guix" {
  accelerator = "kvm"
  boot_command = [
    "<leftCtrlOn><leftAltOn><f4><leftAltOff><leftCtrlOff><enter>",
    "passwd<enter>vagrant<enter>vagrant<enter>",
    "herd start ssh-daemon<enter>",
  ]
  boot_wait = "30s"
  cpus = 2
  disk_compression = true
  disk_interface = "virtio-scsi"
  disk_size = "20G"
  format = "qcow2"
  headless = true
  http_directory = "./assets/guix"
  memory = 2048
  qemuargs = [
    ["-accel", "kvm"],
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-cpu", "qemu64"],
    ["-machine", "q35"],
  ]
  shutdown_command = "shutdown"
  ssh_agent_auth = false
  ssh_password = "vagrant"
  ssh_username = "root"
  ssh_timeout = "30m"
}

build {
  name = "guix"

  source "source.qemu.guix" {
    name = "guix-1.3.0-x86_64"
    output_directory = "./build/${replace(source.name, "-", "/")}"
    vm_name = "${source.name}.qcow2"
    iso_checksum = "sha256:f2b30458fa1736eeee3b82f34aab1d72f3964bef0477329bb75281d2b7bb6d4b"
    iso_url = "https://ftp.gnu.org/gnu/guix/guix-system-install-1.3.0.x86_64-linux.iso"
  }

  provisioner "file" {
    name = "guix-config"
    source = "./assets/guix/config.scm"
    destination = "/root/config.scm"
  }

  provisioner "shell" {
    name = "guix-install"
    script = "./assets/guix/install.sh"
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
