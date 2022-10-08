This repository provides Vagrant boxes which are built with Packer and
automated with [tools/](./tools/).

```sh
# Example of how the `build/` tree is organized
$ tree build/
build/
└── nixos
    └── 22.05
        └── x86_64
            ├── manifest.json
            ├── nixos-22.05-x86_64.box
            └── nixos-22.05-x86_64.qcow2

3 directories, 3 files
```

# Using

Ensure the system dependencies in the following example are installed:

```sh
# Fedora Linux
sudo dnf install coreutils curl gawk packer vagrant-libvirt
```

## Fedora

```sh
packer build -var="os_version=36" -var="os_version_minor=1.5" fedora/fedora.pkr.hcl
vagrant box add build/fedora/36/x86_64/manifest.json
vagrant up fedora
```

## NixOS

```sh
packer build -var="os_version=22.05" nixos/nixos.pkr.hcl
vagrant box add build/nixos/22.05/x86_64/manifest.json
vagrant up nixos
```

## OpenBSD

An OpenBSD base install with no additional packages.

This requires disabling shared and synced folders as these features required
additional packages such as `sudo` and `rsync` are present. These have been
disabled by default in [Vagrantfile.template](openbsd/Vagrantfile.template)

```sh
packer build -var="os_version=7.1" openbsd/openbsd.pkr.hcl
vagrant box add build/openbsd/7.1/amd64/manifest.json
vagrant up openbsd
```
