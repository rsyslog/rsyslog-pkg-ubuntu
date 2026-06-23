#!/bin/bash
# Build daily snapshot package
# ***current working directory must be project dir (e.g. rsyslog)***

# Note: Launchpad does not work with the git hash inside the version
# number, because it checks if the version number as whole is larger
# than what exists. This obviously is not always the case with hashes.
# As such, we rename the version to todays date and time. It looks like
# this works sufficiently good, even when the source code has the
# "right" (hash-based) version number.

#set -o xtrace  # useful for debugging
#set -v

echo package build for `pwd` $1/$2/$3
date

# params
szPlatform=$1		# trusty, vivid, ...
UPLOAD_PPA=$2		# path of the ppa (e.g. v8-devel)
BRANCH=$3		# branch to use (e.g. master)
			# Note: this must match the tarball branch
CUSTOMBUILD_ARG=${4:-""}
DEBUILD_ARG=${5:-""}
if [ -n "$CUSTOMBUILD_ARG" ]; then
    CUSTOMBUILD="-$CUSTOMBUILD_ARG"
else
    CUSTOMBUILD="-$(date +%Y%m%d%H%M%S)"
fi
# Always -sa by default: CUSTOMBUILD is part of upstream version (new .orig name each time).
# Opt in to -sd only for packaging-only re-uploads when orig is already on the PPA.
DEBUILD_MODE="-sa"
case "$DEBUILD_ARG" in
    -sd|sd) DEBUILD_MODE="-sd" ;;
esac
#if [ -z "$CUSTOMBUILD" ]; then
#fi

rm -fv *.orig.tar.gz # clean up if left over, temporary work file!
# only a single .tar.gz must exist at any time
ls -l *.tar.gz # debug output
szSourceFile=`ls *.tar.gz`
szSourceBase=`basename $szSourceFile .tar.gz`
VERSION=`echo $szSourceBase|cut -d- -f2`
PURE_VERSION=`echo $VERSION|cut -d. -f1-3`
# Check if VERSION contains _x and create VERSION_RAW by removing _x
if [[ "$VERSION" =~ _[0-9]+$ ]]; then
    VERSION_TAR_GZ=$(echo "$VERSION" | sed 's/_[0-9]\+$//')
else
    VERSION_TAR_GZ=$VERSION
fi
LAUNCHPAD_VERSION=`echo $VERSION | cut -d. -f1-3`${CUSTOMBUILD}
PROJECT=`echo $szSourceBase | cut -d- -f1`
PROJECT_SONAME=$PROJECT$(cat CURR_LIBSONAME 2>/dev/null || true)
VERSION_FILE="LAST_VERSION.$BRANCH.$szPlatform"
szReplaceFile="${PROJECT}_$LAUNCHPAD_VERSION"

echo PROJECT $PROJECT
echo PROJECT_SONAME $PROJECT_SONAME
echo VERSION $VERSION
echo PURE_VERSION $PURE_VERSION
echo VERSION_TAR_GZ: $VERSION_TAR_GZ
echo LAUNCHPAD_VERSION $LAUNCHPAD_VERSION
echo Platform $szPlatform
echo PPA $PPA
echo UPLOAD_PPA $UPLOAD_PPA
echo VERSION_FILE $VERSION_FILE
echo szSourceFile $szSourceFile
echo ReplaceFile $szReplaceFile

if [ -z "$PROJECT" ]; then
	echo "variable PROJECT is unset" | mutt -s "$0 script error" $RS_NOTIFY_EMAIL
	exit
fi
if [ -z "$PROJECT_SONAME" ]; then
	echo "variable PROJECT_SONAME is unset" | mutt -s "$0 script error" $RS_NOTIFY_EMAIL
	exit
fi
if [ -z "$VERSION" ]; then
	echo "variable VERSION is unsetn" | mutt -s "$0 script error" $RS_NOTIFY_EMAIL
	exit
fi
if [ -z "$szPlatform" ]; then
	echo "variable szPlatform is unset" | mutt -s "$0 script error" $RS_NOTIFY_EMAIL
	exit
fi
if [ -z "$PPA" ]; then
	echo "variable PPA is unset" | mutt -s "$0 script error" $RS_NOTIFY_EMAIL
	exit
fi

# $VERSION_FILE must not exist. If it does not exist, an
# error message is emitted (this is OK) and the build is
# done. So you can delete it to trigger a new build.
if [ "$VERSION" == "`cat $VERSION_FILE`" ]; then
	echo "version $VERSION already built, exiting"
	rm *.tar.gz
	exit 0
fi

# clean up any old cruft (if it exists)
rm -f $PROJECT_*.changes
rm -f $PROJECT_*.dsc
rm -f $PROJECT_*.build
rm -f $PROJECT_*.debian.tar.gz
rm -f $PROJECT_*.orig.tar.gz
# Delete work dirs from previous runs (pre-vendor and vendor-suffixed names)
if [[ -d "./$LAUNCHPAD_VERSION" ]]; then
	echo "REMOVE existing directory $LAUNCHPAD_VERSION !"
	rm -rf "./$LAUNCHPAD_VERSION"
fi
VENDOR_WORKDIR="${PROJECT}-${PURE_VERSION}+adiscon1${CUSTOMBUILD}"
if [[ -d "./$VENDOR_WORKDIR" ]]; then
	echo "REMOVE existing directory $VENDOR_WORKDIR !"
	rm -rf "./$VENDOR_WORKDIR"
fi

# BEGIN ACTUAL BUILD PROCESS
tar xfz $szSourceFile
if [ $? -ne 0 ]; then
	echo error extracting source tarball
	exit 1
fi
mv $szSourceFile $szReplaceFile.orig.tar.gz

# Vendor suffix when plain upstream version conflicts with Ubuntu primary archive
VENDOR_SUFFIX=""
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
if [ -f "$SCRIPT_DIR/ubuntu_orig_conflict.sh" ]; then
    if bash "$SCRIPT_DIR/ubuntu_orig_conflict.sh" "$PROJECT" "$PURE_VERSION" "$szReplaceFile.orig.tar.gz"; then
        VENDOR_SUFFIX="+adiscon1"
        echo "Applying vendor suffix $VENDOR_SUFFIX (Ubuntu primary orig conflict)"
        LAUNCHPAD_VERSION="${PURE_VERSION}${VENDOR_SUFFIX}${CUSTOMBUILD}"
        szReplaceFile="${PROJECT}_${LAUNCHPAD_VERSION}"
        VENDOR_ORIG="${szReplaceFile}.orig.tar.gz"
        VENDOR_DIR="${PROJECT}-${LAUNCHPAD_VERSION}"
        if [ -d "$szSourceBase" ]; then
            mv "$szSourceBase" "$VENDOR_DIR" || { echo "Error: failed to rename source directory"; exit 1; }
            szSourceBase="$VENDOR_DIR"
        fi
        tar czf "$VENDOR_ORIG" "$VENDOR_DIR" || { echo "Error: failed to create vendor orig tarball"; exit 1; }
        rm -f "${PROJECT}_${PURE_VERSION}${CUSTOMBUILD}.orig.tar.gz"
    fi
fi

if [ -n "$VENDOR_SUFFIX" ]; then
    # Keep ${PROJECT}-${LAUNCHPAD_VERSION}/ — same top-level dir as in VENDOR_ORIG
    SOURCE_WORKDIR="$szSourceBase"
    cd "$SOURCE_WORKDIR"
else
    mv "$szSourceBase" "$LAUNCHPAD_VERSION"
    SOURCE_WORKDIR="$LAUNCHPAD_VERSION"
    cd "$SOURCE_WORKDIR"
fi
ls -l ..
ls -l ../$szPlatform
ls -l ../$szPlatform/$BRANCH
ls -l ../$szPlatform/$BRANCH/debian
cp -rv ../$szPlatform/$BRANCH/debian .
pwd
ls -l

# create new dummy changelog entry
NEW_ENTRY="$PROJECT ($LAUNCHPAD_VERSION-0adiscon1$szPlatform) $szPlatform; urgency=low

  * Packages for ${VERSION} on ${szPlatform}

 -- Adiscon package maintainers <adiscon-pkg-maintainers@adiscon.com>  $(date -R)
"
# Prepend the new changelog entry to the file
echo -e "$NEW_ENTRY\n$(cat debian/changelog)" > debian/changelog
echo " OUTPUT debian/changelog:" 
cat debian/changelog

# Build Source package now!
if [ -v PACKAGE_SIGNING_KEY_ID ]; then
	echo "RUN debuild -S $DEBUILD_MODE -rfakeroot -k $PACKAGE_SIGNING_KEY_ID"
	debuild -S $DEBUILD_MODE -rfakeroot -k"$PACKAGE_SIGNING_KEY_ID"
else
	echo "RUN debuild -S $DEBUILD_MODE -rfakeroot -us -uc"
	debuild -S $DEBUILD_MODE -rfakeroot -us -uc
fi
if [ $? -ne 0 ]; then
	echo "fail in debuild for $PROJECT_SONAME $VERSION on $szPlatform - check cron mail for details" | mutt -s "$PROJECT_SONAME daily build failed!" $RS_NOTIFY_EMAIL
        exit 1
fi

# we now need to climb out of the working tree, all distributable
# files are generated in the home directory.
cd ..

if [ -v PACKAGE_SIGNING_KEY_ID ]; then
	# This only works on bash >4.2 note no $ before the variable name
	# If there is a key defined, upload changes to PPA now!
	echo "Upload to $PPA/$UPLOAD_PPA"
	debsign -k $PACKAGE_SIGNING_KEY_ID `ls *.changes`
	dput -f $PPA/$UPLOAD_PPA `ls *.changes`
	if [ $? -ne 0 ]; then
	         echo "fail in dput, PPA upload to Launchpad failed" | mutt -s "$PROJECT_SONAME daily build failed!" $RS_NOTIFY_EMAIL
		exit 1
	fi
	#cleanup
	echo $VERSION >$VERSION_FILE
	#exit # do this for testing
	rm -rf "$SOURCE_WORKDIR"
	rm -v $szReplaceFile*.dsc $szReplaceFile*.build $szReplaceFile*.changes $szReplaceFile*.upload *.tar.gz
fi
