#!/bin/sh
# SPDX-License-Identifier: ISC

set -eux -o pipefail

[ -n $BOX_ARCH ]    || exit 1
[ -n $BOX_NAME ]    || exit 1
[ -n $BOX_VERSION ] || exit 1

BOX_PATH="build/$BOX_NAME/$BOX_VERSION/$BOX_ARCH"

mkdir -p $BOX_PATH

echo "{
  \"name\": \"jcmdln/$BOX_NAME\",
  \"description\": \"\",
  \"versions\": [
    {
      \"version\": \"$BOX_VERSION\",
      \"providers\": [
        {
          \"name\": \"libvirt\",
          \"url\": \"$BOX_PATH/$BOX_NAME.box\"
        }
      ]
    }
  ]
}" > $BOX_PATH/manifest.json
