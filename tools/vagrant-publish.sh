#!/usr/bin/env sh
# SPDX-License-Identifier: ISC

set -ex

[ -n "$(command -v awk)" ]     || exit 1
[ -n "$(command -v cat)" ]     || exit 1
[ -n "$(command -v date)" ]    || exit 1
[ -n "$(command -v jq)" ]      || exit 1
[ -n "$(command -v vagrant)" ] || exit 1

[ -n $BOX_ARCH ]    || exit 1
[ -n $BOX_NAME ]    || exit 1
[ -n $BOX_VERSION ] || exit 1

BOX_FILENAME="$BOX_NAME-$BOX_VERSION-$BOX_ARCH.box"
BOX_PATH="build/$BOX_NAME/$BOX_VERSION/$BOX_ARCH"

[ -f "$BOX_PATH/$BOX_FILENAME" ] || exit 1

BOX_DATETIME="$(date '+%Y%m%dT%H%M%S')" &&
BOX_PATH="build/$BOX_NAME/$BOX_VERSION/$BOX_ARCH" &&
BOX_SHA256SUM="$(cat $BOX_PATH/manifest.json | jq .versions[0].providers[0].checksum)"
VAGRANT_USER="${VAGRANT_USER:-`vagrant cloud auth whoami --machine-readable | awk '{ print $NF }'`}"

vagrant cloud publish --no-private \
    --checksum=$BOX_SHA256SUM \
    --checksum-type=sha256 \
    $VAGRANT_USER/$BOX_NAME $BOX_VERSION-$BOX_DATETIME \
    libvirt $BOX_PATH/$BOX_FILENAME