This repository provides Vagrant boxes which are built with Packer and
automated with [tools/](./tools/).

# Using

Install system dependencies:

```sh
# Fedora Linux
sudo dnf install coreutils curl gawk jq packer vagrant
```

Build with Packer:

```sh
# Build all boxes
packer build .

# Build all NixOS boxes
packer build -only=*.nixos* .

# Build a specific NixOS box
packer build -only=qemu.nixos-22.05-x86_64 .
```

Add boxes by `manifest.json`:

```sh
vagrant box add build/fedora/36/x86_64/manifest.json
vagrant box add build/guix/1.3.0/x86_64/manifest.json
vagrant box add build/nixos/22.05/x86_64/manifest.json
vagrant box add build/openbsd/7.1/amd64/manifest.json
```

Start boxes:

```sh
vagrant up
```

# Publishing

I created a [./tools/vagrant-publish.sh](./tools/vagrant-publish.sh) which uses
the manifest [./tools/vagrant-manifest.sh](./tools/vagrant-manifest.sh) creates
during a Packer build instead of hand-typing out what boxes we built.

Ensure that `vagrant cloud auth whoami` shows you are logged in.

```sh
BOX_NAME="nixos" BOX_VERSION="22.04" BOX_ARCH="x86_64" \
sh ./tools/vagrant-publish.sh
```
