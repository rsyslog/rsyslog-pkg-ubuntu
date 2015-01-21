#!/bin/bash
# Build daily snapshot rsyslog package
# ***current working directory must be project dir (e.g. rsyslog)***

#set -o xtrace

# params
szPlatform=$1
szBranch=$2

# GPG KEY
PACKAGE_SIGNING_KEY_ID=E8724174

# only a single .tar.gz must exist at any time
szSourceFile=`ls *.tar.gz`
szSourceBase=`basename $szSourceFile .tar.gz`
VERSION=`echo $szSourceBase|cut -d- -f2`
szReplaceFile=`echo $szSourceBase | sed 's/-/_/'`
tar xfz $szSourceFile
mv $szSourceFile $szReplaceFile.orig.tar.gz

cd $szSourceBase
cp -r ../$szPlatform/$szBranch/debian .
# create dummy changelog entry
echo "rsyslog ($VERSION-0adiscon1$szPlatform) $szPlatform; urgency=low" > debian/changelog
echo "" >> debian/changelog
echo "  * daily build" >> debian/changelog
echo "" >> debian/changelog
echo " -- Adiscon package maintainers <adiscon-pkg-maintainers@adiscon.com>  `date -R`" >> debian/changelog 

# Build Source package now!
debuild -S -sa -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"

# we now need to climb out of the working tree, all distributable
# files are generated in the home directory.
cd ..

# Upload changes to PPA now!
dput -f ppa:adiscon/$szBranch `ls *.changes`

#cleanup
exit # do this for testing
rm -rf $szSourceBase
