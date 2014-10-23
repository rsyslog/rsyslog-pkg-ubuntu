#!/bin/bash
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
debuild -S -rfakeroot -kAEF0CF8E

