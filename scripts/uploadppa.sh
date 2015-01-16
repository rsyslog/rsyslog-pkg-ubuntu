#!/bin/bash
# Definitions common to these scripts
source $(dirname "$0")/config.sh

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
TARGZFILES=` ls -d */ | grep $PACKAGENAME`
# TARGZFILES=` ls -d */`

echo "--------------------------------------"
echo "--- Prep Release and Upload to PPA ---"
echo "--------------------------------------"
select szPrepareDir in $TARGZFILES
do
	echo "Select BRANCH:"
	select szBranch in $BRANCHES
        do
        	echo "Select Ubuntu DIST:"
        	select szPlatform in $PLATFORM
        	do
        	        break;
        	done
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

read -p "Generate Changelog entry for $szPlatform/$szBranch/$szDebian (y/n)? " RESULT
cd $szPrepareDir
cp -r $szPlatform/$szBranch/debian $szPrepareDir
if [ "$RESULT" == "y" ]; then
	dch -D $szPlatform -i
fi

# Build Source package now!
debuild -S -sa -rfakeroot -k"$KEY_ID"

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

