#!/bin/sh
set -ex

[ -n $BOX_ARCH ]    || exit 1
[ -n $BOX_NAME ]    || exit 1
[ -n $BOX_VERSION ] || exit 1

BOX_PATH="build/$BOX_NAME/$BOX_VERSION/$BOX_ARCH"

[ -f "$BOX_PATH/$BOX_NAME-$BOX_VERSION-$BOX_ARCH.box" ] || exit 1

SHA256SUM="$(sha256sum $BOX_PATH/$BOX_NAME-$BOX_VERSION-$BOX_ARCH.box | awk '{print $1}')"
VAGRANT_USER="${VAGRANT_USER:-`vagrant cloud auth whoami --machine-readable | awk '{print $NF}'`}"

mkdir -p $BOX_PATH

echo "{
  \"name\": \"$VAGRANT_USER/$BOX_NAME\",
  \"description\": \"\",
  \"versions\": [
    {
      \"version\": \"$BOX_VERSION\",
      \"providers\": [
        {
          \"name\": \"libvirt\",
          \"url\": \"$BOX_PATH/$BOX_NAME-$BOX_VERSION-$BOX_ARCH.box\",
          \"checksum-type\": \"sha256\",
          \"checksum\": \"$SHA256SUM\"
        }
      ]
    }
  ]
}" > $BOX_PATH/manifest.json
