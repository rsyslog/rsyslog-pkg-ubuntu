#!/bin/bash
# Definitions common to these scripts
source $(dirname "$0")/config.sh

TARGZFILES=`ls -d rsyslog*/ | xargs -l basename`

echo "-------------------------------------"
echo "--- DEBMaker                      ---"
echo "-------------------------------------"

select szSourceBase in $TARGZFILES
do
        echo "Updating for '$szSourceFile'
        "
        break;
done

cd $szSourceBase
dch -i
debuild -S -rfakeroot -k"$KEY_ID"

