#!/bin/bash
# Usage: repack.sh <release-tarball-url> [vendor-suffix]
# Example: repack.sh https://github.com/rsyslog/liblognorm/releases/download/v2.1.0/liblognorm-2.1.0.tar.gz +adiscon1
echo download tar to be released: $1
VENDOR_SUFFIX="${2:-}"

rm -fv *.tar.gz 2>/dev/null || true

wget --no-check-certificate "$1" || { echo "Error: wget failed"; exit 1; }

TARGZFILE=$(ls *.tar.gz 2>/dev/null || true)

if [ -z "$TARGZFILE" ] || [ ! -f "$TARGZFILE" ]; then
   echo "Error: expected exactly one .tar.gz after download."
   exit 1
fi

echo "-------------------------------------"
echo "--- DEBMaker                      ---"
echo "-------------------------------------"

echo "Repacking '$TARGZFILE'"

szSourceBase=`basename $TARGZFILE .tar.gz`
szReplaceFile=`echo $szSourceBase | sed 's/-/_/'`

tar xfz $TARGZFILE
rm -f $TARGZFILE

SOURCE_DIR="$szSourceBase"
if [ -n "$VENDOR_SUFFIX" ]; then
    echo "Applying vendor suffix: $VENDOR_SUFFIX"
    szReplaceFile="${szReplaceFile}${VENDOR_SUFFIX}"
    mv "$szSourceBase" "${szSourceBase}${VENDOR_SUFFIX}"
    SOURCE_DIR="${szSourceBase}${VENDOR_SUFFIX}"
fi

# Orig tarball must contain the same top-level directory as the source tree
tar czf "${szReplaceFile}.orig.tar.gz" "$SOURCE_DIR" || { echo "Error: failed to create orig tarball"; exit 1; }

echo "Created ${szReplaceFile}.orig.tar.gz and ${SOURCE_DIR}/"
