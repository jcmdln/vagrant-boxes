#!/bin/sh

set -ex -o pipefail

[ -n "$(command -v awk)" ]      || exit 1
[ -n "$(command -v jq)" ]      || exit 1
[ -n "$(command -v vagrant)" ] || exit 1

MANIFEST="$1"
if [ -z "$MANIFEST" ]; then
    echo "error: no manifest provided"
    exit 1
fi

if [ -n "$2" ]; then
    echo "error: too many operands"
    exit 1
fi

BOX_CHECKSUM=$(jq -r '.versions[0].providers[0].checksum' $MANIFEST)
BOX_CHECKSUM_TYPE=$(jq -r '.versions[0].providers[0]."checksum-type"' $MANIFEST)
BOX_NAME=$(jq -r '.name' $MANIFEST)
BOX_URL=$(jq -r '.versions[0].providers[0].url' $MANIFEST)
BOX_VERSION=$(jq -r '.versions[0].version' $MANIFEST)
VAGRANT_USER="${VAGRANT_USER:-`vagrant cloud auth whoami --machine-readable | awk '{print $NF}'`}"

vagrant cloud publish --no-private \
    --checksum=$BOX_CHECKSUM \
    --checksum-type=$BOX_CHECKSUM_TYPE \
    $BOX_NAME $BOX_VERSION libvirt $BOX_URL
