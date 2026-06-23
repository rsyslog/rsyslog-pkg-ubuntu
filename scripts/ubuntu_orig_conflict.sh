#!/bin/bash
# Check whether Ubuntu primary archive has a different orig tarball for this version.
# Usage: ubuntu_orig_conflict.sh <package> <version> [local-orig-file]
# Exit 0 if vendor suffix is recommended, 1 if not needed or cannot determine, 2 on error.
PACKAGE="$1"
VERSION="$2"
LOCAL_ORIG="${3:-}"

if [ -z "$PACKAGE" ] || [ -z "$VERSION" ]; then
    echo "Usage: ubuntu_orig_conflict.sh <package> <version> [local-orig-file]" >&2
    exit 2
fi

# Pool directory: lib* packages use libX (e.g. liblognorm -> libl)
if [[ "$PACKAGE" == lib* ]]; then
    POOL_DIR="lib$(echo "$PACKAGE" | cut -c4)"
else
    POOL_DIR=$(echo "$PACKAGE" | cut -c1)
fi
UBUNTU_URL="https://archive.ubuntu.com/ubuntu/pool/universe/${POOL_DIR}/${PACKAGE}/${PACKAGE}_${VERSION}.orig.tar.gz"

TMP_ORIG=$(mktemp)
if ! wget -q -O "$TMP_ORIG" "$UBUNTU_URL" 2>/dev/null; then
    rm -f "$TMP_ORIG"
    exit 1
fi

if [ ! -s "$TMP_ORIG" ]; then
    rm -f "$TMP_ORIG"
    exit 1
fi

UBUNTU_SHA=$(sha256sum "$TMP_ORIG" | awk '{print $1}')

if [ -n "$LOCAL_ORIG" ] && [ -f "$LOCAL_ORIG" ]; then
    LOCAL_SHA=$(sha256sum "$LOCAL_ORIG" | awk '{print $1}')
    rm -f "$TMP_ORIG"
    if [ "$LOCAL_SHA" != "$UBUNTU_SHA" ]; then
        echo "Ubuntu primary has ${PACKAGE}_${VERSION}.orig.tar.gz with different content (vendor suffix recommended)" >&2
        exit 0
    fi
    exit 1
fi

rm -f "$TMP_ORIG"
echo "Ubuntu primary has ${PACKAGE}_${VERSION}.orig.tar.gz (vendor suffix may be required for non-Ubuntu tarballs)" >&2
exit 0
