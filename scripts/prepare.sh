#!/bin/bash
# Definitions common to these scripts
source $(dirname "$0")/config.sh

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
TARGZFILES=` ls -d */ | grep $PACKAGENAME`
# TARGZFILES=` ls -d */`

echo "-------------------------------------"
echo "--- Prepare Release               ---"
echo "-------------------------------------"

select szPrepareDir in $TARGZFILES
do
	echo "Select BRANCH:"
	select szBranch in $BRANCHES
        do
        	echo "Select Ubuntu DIST:"
        	select szPlatform in $PLATFORM
        	do
        	        echo "Preparing '$szPrepareDir'"
        	        break;
        	done
        	break;
	done
	break;
done

#szSourceBase=`basename $szSourceFile .tar.gz`
#szSourceBase=`echo $szSourceBase | sed 's/_/-/'`

#echo "$szSourceBase";
#exit; 

#tar xfz $szSourceFile 
#mv $szSourceFile $szReplaceFile.orig.tar.gz

cp -r $szPlatform/$szBranch/debian $szPrepareDir
cd $szPrepareDir
dch -D $szPlatform -i
debuild -S -rfakeroot -k"$KEY_ID"

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

