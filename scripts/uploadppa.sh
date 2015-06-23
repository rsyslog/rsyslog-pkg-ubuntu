#!/bin/bash
# Definitions common to these scripts
source $(dirname "$0")/config.sh

#set -o xtrace  # use for debugging

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
TARGZFILES=` ls -d */ | grep $PACKAGENAME`

if [ `echo $TARGZFILES | wc -l` -ne 1 ]; then 
   echo only a single source tar file is supported
   exit 1
fi

# clean any left-overs from previous runs
rm -v *.changes *.debian.tar.gz

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
cp -r $szPlatform/$szBranch/debian $szPrepareDir
cd $szPrepareDir
if [ "$RESULT" == "y" ]; then
	dch -D $szPlatform -i
fi

# Build Source package now!
debuild -S -sa -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"

if [ "$RESULT" == "y" ]; then
	# Save Changes back now
	cd ..
	szDebian="debian"
	echo    # (optional) move to a new line
	read -p "Copy $szPrepareDir$szDebian folder back to $szPlatform/$szBranch/$szDebian (y/n)? " RESULT
	echo    # (optional) move to a new line 
	if [ "$RESULT" == "y" ]; then
		cp -r $szPrepareDir$szDebian $szPlatform/$szBranch/
		echo "$szPrepareDir$szDebian copied back."
	fi
fi

CHANGESFILES=`ls *.changes`

echo "-------------------------------------"
echo "--- Select change file for upload ---"
echo "-------------------------------------"

echo "Select Changefile:"
select szChangeFile in $CHANGESFILES
do
        break;
done

# Upload changes to PPA now!
dput -f ppa:adiscon/$szBranch $szChangeFile

# cleanup
rm -v *.changes *.debian.tar.gz
