#!/bin/bash
echo download tar to be released: $1

rm -v *.tar.gz
wget $1

TARGZFILE=`ls *.tar.gz`

if [ `echo $TARGZFILE | wc -l` -ne 1 ]; then 
   echo only a single source tar file is supported
   exit 1
fi

echo "-------------------------------------"
echo "--- DEBMaker                      ---"
echo "-------------------------------------"

echo "Repacking '$TARGZFILE'"

szSourceBase=`basename $TARGZFILE .tar.gz`
szReplaceFile=`echo $szSourceBase | sed 's/-/_/'`

tar xfz $TARGZFILE
mv $TARGZFILE $szReplaceFile.orig.tar.gz

