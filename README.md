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

# Build only NixOS boxes
packer build -only=nixos.* .
```

Add and start boxes:

```sh
vagrant box add build/fedora/36/x86_64/manifest.json
vagrant box add build/nixos/22.05/x86_64/manifest.json
vagrant up
```

# Publishing

In this example, we're building `nixos-21.11-x86_64` and publishing it to
Vagrant Cloud using [./tools/vagrant-publish.sh](./tools/vagrant-publish.sh).

Ensure that `vagrant cloud auth whoami` confirms that you are logged in as the
correct user, as we (unfortunately) parse the output of this command.

```sh
packer build . --only="*.nixos-22.05-x86_64"
```

```sh
BOX_NAME="nixos" BOX_VERSION="21.11" BOX_ARCH="x86_64" \
sh ./tools/vagrant-publish.sh
```
