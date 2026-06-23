#!/bin/bash
# Definitions common to these scripts
echo load config from $(dirname "$0")/config.sh

source $(dirname "$0")/config.sh

# If we assume the directory is named after the package,
PACKAGENAME=$(basename `readlink -f .`)
TARGZFILES=$(find . -maxdepth 1 -type d -name "${PACKAGENAME}-*" | sort)
echo TARG: $TARGZFILES

if [ "$(printf '%s\n' "$TARGZFILES" | sed '/^$/d' | wc -l)" -ne 1 ] || [ ! -d "$TARGZFILES" ]; then
   echo "Error: expected exactly one ${PACKAGENAME}-* source directory."
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

# Get upstream version from source directory name (e.g. liblognorm-2.1.0+adiscon1/)
UPSTREAM_VERSION=$(basename "$TARGZFILES" | sed "s/^${PACKAGENAME}-//" | sed 's|/$||')

if [ -z "$UPSTREAM_VERSION" ] || [ "$UPSTREAM_VERSION" = "." ] || [ ! -d "$szPrepareDir" ]; then
    echo "Unable to determine upstream version or source directory does not exist."
    exit 1
fi

echo "Using PPA: $UPLOAD_PPA"
echo "Using Debian branch: $szBranch"
echo "Detected UPSTREAM_VERSION: $UPSTREAM_VERSION"

echo "REMOVE / CLEANUP Existing $szPrepareDir/debian"
rm -r "$szPrepareDir/debian"

echo "COPY $szPlatform/$szBranch/debian to $szPrepareDir/debian"
cp -r $szPlatform/$szBranch/debian $szPrepareDir || exit 1

read -p "Generate Changelog entry for $szPlatform/$szBranch automatically (y/n)? " GEN_CHANGELOG
cd $szPrepareDir
if [ "$GEN_CHANGELOG" == "y" ]; then
    echo ""
    echo "=== SUBVERSION (per Ubuntu suite) ==="
    echo "Counter for packaging revisions on THIS suite only (noble, focal, ...)."
    echo "It becomes part of the Debian version, e.g. 2.1.0+adiscon1-0adiscon1noble1."
    echo ""
    echo "  SUBVERSION 1  = first upload of this upstream version to this suite"
    echo "                  (new release or new vendor suffix like +adiscon1)"
    echo "  SUBVERSION 2+ = packaging-only fix; same source tarball as before"
    echo ""
    echo "If you changed the upstream version (e.g. plain 2.1.0 -> 2.1.0+adiscon1),"
    echo "always start at 1 for each suite — old noble2/noble3 entries do not carry over."
    echo ""
    read -p "Enter SUBVERSION number (default is 1): " SUBVERSION
    SUBVERSION=${SUBVERSION:-1}
    echo "Using SUBVERSION: $SUBVERSION"

    NEW_ENTRY="$PACKAGENAME ($UPSTREAM_VERSION-0adiscon1$szPlatform$SUBVERSION) $szPlatform; urgency=low

  * Packages for ${UPSTREAM_VERSION} on ${szPlatform}

 -- Adiscon package maintainers <adiscon-pkg-maintainers@adiscon.com>  $(date -R)"
    echo -e "$NEW_ENTRY\n$(cat debian/changelog)" > debian/changelog
    echo "Automatic changelog entry added:"
    echo "$NEW_ENTRY"
else
    read -p "Generate Changelog entry for $szPlatform/$szBranch (y/n)? " GEN_CHANGELOG
    if [ "$GEN_CHANGELOG" == "y" ]; then
        dch -D $szPlatform -i
    fi
    SUBVERSION=1
fi

# debuild -sa uploads the .orig.tar.gz; -sd uploads only debian/ changes (manual opt-in)
DEBUILD_MODE="-sa"

echo ""
echo "=== debuild mode ==="
echo "  -sa  Include ${PACKAGENAME}_${UPSTREAM_VERSION}.orig.tar.gz in the upload. (default)"
echo "       Use for SUBVERSION 1 and whenever unsure."
echo "  -sd  Upload only debian/ changes; Launchpad reuses the orig from a prior upload."
echo "       Only use for SUBVERSION 2+ AFTER -sa was already accepted on the PPA."
echo ""
if [ "${SUBVERSION:-1}" -gt 1 ] 2>/dev/null; then
    echo "NOTE: SUBVERSION > 1 — you may type -sd if the orig is already on the PPA."
    echo "      Default stays -sa (safer if unsure)."
fi
echo ""
read -p "debuild mode: -sa (include orig) or -sd (packaging-only) [-sa]? " MODE
case "${MODE}" in
    -sd) DEBUILD_MODE="-sd" ;;
    ""|-sa) DEBUILD_MODE="-sa" ;;
    *) echo "Invalid debuild mode: ${MODE}"; exit 1 ;;
esac

# Build Source package now!
if [ -v PACKAGE_SIGNING_KEY_ID ]; then
    echo "RUN debuild -S $DEBUILD_MODE -rfakeroot -k $PACKAGE_SIGNING_KEY_ID"
    debuild -S "$DEBUILD_MODE" -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"
else
    echo "RUN WITHOUT KEY debuild -S $DEBUILD_MODE -rfakeroot -us -uc"
    debuild -S "$DEBUILD_MODE" -rfakeroot -us -uc
fi
if [ $? -ne 0 ]; then
    echo "FAIL in debuild for $PACKAGENAME $UPSTREAM_VERSION on $szPlatform"
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
