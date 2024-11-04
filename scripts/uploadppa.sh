#!/bin/bash
# Definitions common to these scripts
echo load config from $(dirname "$0")/config.sh

source $(dirname "$0")/config.sh

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
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
select UPLOAD_PPA in $BRANCHES
do
    echo "Select Ubuntu DIST:"
    select szPlatform in $PLATFORM
    do
        break;
    done
    break;
done

# Set Debian branch based on available subfolders in $szPlatform
DEBIAN_BRANCHES=($(ls -d $szPlatform/*/ | xargs -n 1 basename))
if [ ${#DEBIAN_BRANCHES[@]} -eq 0 ]; then
    echo "No available Debian branch subfolders found in $szPlatform"
    exit 1
fi

echo "Select Debian branch:"
select szBranch in "${DEBIAN_BRANCHES[@]}"
do
    if [ -n "$szBranch" ]; then
        break;
    fi
    echo "Invalid selection. Please try again."
done

# Get VERSION from the tarball name
VERSION=$(echo $TARGZFILES | grep -oP '(?<=-)[0-9]+\.[0-9]+\.[0-9]+')

if [ -z "$VERSION" ]; then
    echo "Unable to determine version from tarball name."
    exit 1
fi

echo "Using PPA: $UPLOAD_PPA"
echo "Using Debian branch: $szBranch"
echo "Detected VERSION: $VERSION"

echo "REMOVE / CLEANUP Existing $szPrepareDir/debian"
rm -r $szPrepareDir/debian

echo "COPY $szPlatform/$szBranch/debian to $szPrepareDir/debian"
cp -r $szPlatform/$szBranch/debian $szPrepareDir || exit 1

read -p "Generate Changelog entry for $szPlatform/$szBranch automatically (y/n)? " GEN_CHANGELOG
cd $szPrepareDir
if [ "$GEN_CHANGELOG" == "y" ]; then
    read -p "Enter SUBVERSION number (default is 1): " SUBVERSION
    SUBVERSION=${SUBVERSION:-1}
    echo "Using SUBVERSION: $SUBVERSION"

    NEW_ENTRY="$PACKAGENAME ($VERSION-0adiscon1$szPlatform$SUBVERSION) $szPlatform; urgency=low

  * Packages for ${VERSION} on ${szPlatform}

 -- Adiscon package maintainers <adiscon-pkg-maintainers@adiscon.com>  $(date -R)"
    echo -e "$NEW_ENTRY\n$(cat debian/changelog)" > debian/changelog
    echo "Automatic changelog entry added:"
    echo "$NEW_ENTRY"
else
    read -p "Generate Changelog entry for $szPlatform/$szBranch (y/n)? " GEN_CHANGELOG
    if [ "$GEN_CHANGELOG" == "y" ]; then
        dch -D $szPlatform -i
    fi
fi

# Build Source package now!
if [ -v PACKAGE_SIGNING_KEY_ID ]; then
    echo "RUN debuild -S -sa -rfakeroot -k $PACKAGE_SIGNING_KEY_ID"
    debuild -S -sa -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"
else
    echo "RUN WITHOUT KEY debuild -S -sa -rfakeroot -us -uc"
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

if [ "$GEN_CHANGELOG" == "y" ]; then
    szDebian="debian"
    echo    # (optional) move to a new line
    read -p "Copy $szPrepareDir$szDebian folder back to $szPlatform/$szBranch/$szDebian (y/n)? " COPYBACK
    echo    # (optional) move to a new line 
    if [ "$COPYBACK" == "y" ]; then
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
debsign --no-re-sign -k $PACKAGE_SIGNING_KEY_ID $szChangeFile
echo "Upload to $UPLOAD_PPA"
dput -f ppa:adiscon/$UPLOAD_PPA $szChangeFile
if [ $? -ne 0 ]; then
    echo "FAILED dput, PPA upload to Launchpad $UPLOAD_PPA for $PACKAGENAME failed"
    exit 1
fi

# cleanup
rm -v *.changes
rm -v *.debian.tar.xz
# Fix filepermissions
chmod -f g+w *
