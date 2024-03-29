#!/bin/sh
set -ex

# Create a GPT partition table
parted /dev/sda -- mklabel gpt

# Create and format /boot partition
parted /dev/sda -- mkpart ESP fat32 1MiB 1GiB
parted /dev/sda -- set 1 esp on
mkfs.fat -F 32 -n boot /dev/sda1

# Create and format btrfs partition
parted /dev/sda -- mkpart primary 1GiB -1MiB
mkfs.btrfs -L guix /dev/sda2

# Create btrfs subvolumes
mount -t btrfs /dev/sda2 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/gnu
umount /mnt

# Mount partitions
mount -o compress=zstd,subvol=root /dev/disk/by-label/guix /mnt
mkdir -p /mnt/{boot,home,gnu}
mount /dev/disk/by-label/boot /mnt/boot
mkdir -p /mnt/boot/efi
mount -o compress=zstd,subvol=home /dev/disk/by-label/guix /mnt/home
mount -o noatime,compress=zstd,subvol=gnu /dev/disk/by-label/guix /mnt/gnu
