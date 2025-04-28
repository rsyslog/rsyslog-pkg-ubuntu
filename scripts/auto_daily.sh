#! /bin/bash
# Prequitsites: tarballs must exist in $INFRAHOME/repo/<project>
# for all to be built projects. These tarballs must have been created
# by "make dist". The tarball must be copied to this packages home
# directory. Only one tarball must exist at the same time.

#set -o xtrace  # useful for debugging
#set -v
#set -x

source $RSI_SCRIPTS/config.sh

PROJECTS=${1:-"libestr liblogging libfastjson liblognorm librelp rsyslog"}
PPAREPO=$2	# daily-stable experimental
PPABRANCH=$3	# v8-stable
CUSTOMBUILD=$4	# Custom build if any

# Abort the script if PPAREPO is not set
if [ -z "$PPAREPO" ]; then
    echo "Error: PPAREPO is not set."
    exit 1
fi

echo BUILD Daily packages for $PROJECTS on REPO $PPAREPO with PPABRANCH $PPABRANCH
date

for PROJECT in $PROJECTS
do
	# Ubuntu (bionic 18.04, ) 20.04 and 22.04
	for PLATFORM in focal jammy noble
	do
		echo BUILD $PROJECT for $PLATFORM
		cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT
		rm -fv *.tar.gz
		cp -v $INFRAHOME/repo/$PROJECT/*.tar.gz .
		echo DIR $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT RUN: $INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM $PPAREPO $PPABRANCH $CUSTOMBUILD
		$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM $PPAREPO $PPABRANCH $CUSTOMBUILD
	done
done
