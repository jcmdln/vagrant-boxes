#!/bin/sh
set -ex

VAGRANT_PUBKEY="${VAGRANT_PUBKEY:-https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub}"

mkdir -m 0700 -p /home/vagrant/.ssh

curl -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY ||
wget -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY ||
ftp -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY ||
exit 1

unset VAGRANT_PUBKEY

chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
