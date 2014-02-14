#!/bin/bash
TARGZFILES=`ls *.tar.gz`

echo "-------------------------------------"
echo "--- DEBMaker                      ---"
echo "-------------------------------------"

select szSourceFile in $TARGZFILES
do
        echo "Repacking '$szSourceFile'"
        break;
done

szSourceBase=`basename $szSourceFile .tar.gz`
szReplaceFile=`echo $szSourceBase | sed 's/-/_/'`

tar xfz $szSourceFile
mv $szSourceFile $szReplaceFile.orig.tar.gz

