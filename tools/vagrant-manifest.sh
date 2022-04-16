#!/bin/bash
#
# This script is intended to be run by Packer and should not be used directly
# as it requires environment variables only known at build time.

set -eux -o pipefail

[ -n $BOX_ARCH ]    || exit 1
[ -n $BOX_NAME ]    || exit 1
[ -n $BOX_VERSION ] || exit 1

BOX_PATH="build/$BOX_NAME/$BOX_VERSION/$BOX_ARCH"
MANIFEST="$BOX_PATH/manifest.json"

mkdir -p $BOX_PATH

sed "
    /name\"/     s/\/openbsd/\/$BOX_NAME/;
    /version\"/  s/[0-9]\.[0-9]/$BOX_VERSION/;
    /url\"/      s/build.*\"/build\/$BOX_NAME\/$BOX_VERSION\/$BOX_ARCH\/openbsd.box\"/
" ./tools/sample.manifest.json > $MANIFEST
