#!/bin/bash
# Definitions common to these scripts
echo load config from $(dirname "$0")/config.sh

source $(dirname "$0")/config.sh

#set -o xtrace  # use for debugging

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
#PACKAGENAME="$PACKAGENAME`cat CURR_LIBSONAME`"
TARGZFILES=` ls -d */ | grep $PACKAGENAME`
echo TARG: $TARGZFILES

if [ `echo $TARGZFILES | wc -l` -ne 1 ]; then 
   echo only a single source tar file is supported
   exit 1
fi

# clean any left-overs from previous runs
rm -fv *.changes *.debian.tar.gz

echo "-------------------------------------------"
echo "--- Prep Release for $TARGZFILES"
echo "-------------------------------------------"
szPrepareDir=$TARGZFILES
echo "Select package repository:"
select szBranch in $BRANCHES
do
	echo "Select Ubuntu DIST:"
	select szPlatform in $PLATFORM
	do
		break;
	done
	break;
done

#szSourceBase=`basename $szSourceFile .tar.gz`
#szSourceBase=`echo $szSourceBase | sed 's/_/-/'`
#
#echo "$szSourceBase";
#exit; 

#tar xfz $szSourceFile 
#mv $szSourceFile $szReplaceFile.orig.tar.gz

read -p "Generate Changelog entry for $szPlatform/$szBranch (y/n)? " RESULT
cp -r $szPlatform/$szBranch/debian $szPrepareDir || exit 1
cd $szPrepareDir
if [ "$RESULT" == "y" ]; then
	dch -D $szPlatform -i
fi

# Build Source package now!
if [ -v PACKAGE_SIGNING_KEY_ID ]; then
	echo "RUN debuild -S -sa -rfakeroot -k $PACKAGE_SIGNING_KEY_ID
	debuild -S -sa -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"
else
	echo "RUN WITHOUT KEY debuild -S -sa -rfakeroot -us -uc
    debuild -S -sa -rfakeroot -us -uc
fi
if [ $? -ne 0 ]; then
	echo "FAIL in debuild for $PACKAGENAME $VERSION on $szPlatform"
    exit 1
fi

# Fix filepermissions
chmod -f g+w *

# we now need to climb out of the working tree, all distributable
# files are generated in the home directory.
cd ..

if [ "$RESULT" == "y" ]; then
	szDebian="debian"
	echo    # (optional) move to a new line
	read -p "Copy $szPrepareDir$szDebian folder back to $szPlatform/$szBranch/$szDebian (y/n)? " RESULT
	echo    # (optional) move to a new line 
	if [ "$RESULT" == "y" ]; then
		cp -r $szPrepareDir$szDebian $szPlatform/$szBranch/
		echo "$szPrepareDir$szDebian copied back."
	fi
fi

echo "-------------------------------------"
echo "--- ls *.changes ---"
ls -al 
ls *.changes

echo "-------------------------------------"
echo "--- Select change file for upload ---"
echo "-------------------------------------"
CHANGESFILES=`ls *.changes`

if [ -z "$CHANGESFILES" ]; then
	echo "FAILED: ls *.changes No changefiles found"
	exit 1
fi

echo "Select Changefile:"
select szChangeFile in $CHANGESFILES
do
	break;
done

# Upload changes to PPA now!
echo "Sign $szChangeFile"
debsign -k $PACKAGE_SIGNING_KEY_ID $szChangeFile
echo "Upload to ppa:adiscon/$szBranch"
dput -f ppa:adiscon/$szBranch $szChangeFile
if [ $? -ne 0 ]; then
	echo "FAILED dput, PPA upload to Launchpad ppa:adiscon/$szBranch for $PACKAGENAME failed"
	exit 1
fi

# cleanup
rm -v *.changes
rm -v *.debian.tar.gz
# Fix filepermissions
chmod -f g+w *
