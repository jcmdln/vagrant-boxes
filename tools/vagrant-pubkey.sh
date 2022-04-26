#!/bin/sh
# SPDX-License-Identifier: ISC

set -eux -o pipefail

[ -n $VAGRANT_PUBKEY ] || exit 1

mkdir -m 0700 -p /home/vagrant/.ssh

if [ -n "$(command -v curl)" ]; then
    curl -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY
elif [ -n "$(command -v wget)" ]; then
    wget -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY
elif [ -n "$(command -v ftp)" ]; then
    ftp -o /home/vagrant/.ssh/authorized_keys $VAGRANT_PUBKEY
else
    exit 1
fi

chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
