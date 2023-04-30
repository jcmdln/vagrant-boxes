This repository provides Vagrant boxes which are built with Packer and
automated with [tools/](./tools/).

# Using

## Prepare

### Fedora Linux

```sh
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install -y --repo=hashicorp packer vagrant
sudo dnf install -y coreutils curl gawk jq libvirt-client
vagrant plugin install vagrant-hostmanager vagrant-libvirt
```

## Build

```sh
# Build all boxes
packer build packer/

# Build all Fedora boxes
packer build -only=fedora.* packer/

# Build a specific Fedora box
packer build -only=fedora.qemu.fedora-38-x86_64 packer/
```

You can get a full list of sources to build using `packer inspect packer/`.

## Run

Add boxes by `manifest.json`:

```sh
# Add a single box by manifest
vagrant box add build/fedora/38/x86_64/manifest.json

# Add all boxes by manifest
find build/ -type f -name 'manifest.json' -exec vagrant box add {} \;
```

Start boxes:

```sh
# Start all boxes
vagrant up

# Start a specific box
vagrant up fedora
```

## Publish

I created [./tools/vagrant-publish.sh](./tools/vagrant-publish.sh) which uses
the [./tools/vagrant-manifest.sh](./tools/vagrant-manifest.sh) generated during
the Packer build for _mostly_ automated publishing.

Ensure that `vagrant cloud auth whoami` shows you are logged in.

```sh
./tools/vagrant-publish.sh build/fedora/38/x86_64/manifest.json
```

Log in and manually release the box.

# Notes

## Delete all boxes and libvirt images

```
for BOX in $(vagrant box list | awk '{print $1}'); do
    vagrant box remove --force --all $BOX; done &&
for VOLUME in $(sudo virsh vol-list --pool default | awk '/.img/ {print $1}'); do
    sudo virsh vol-delete --pool default $VOLUME; done
```
