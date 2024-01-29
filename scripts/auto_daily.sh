#!/bin/bash
# Prequitsites: tarballs must exist in $INFRAHOME/repo/<project>
# for all to be built projects. These tarballs must have been created
# by "make dist". The tarball must be copied to this packages home
# directory. Only one tarball must exist at the same time.
echo build all daily packages
date
set -v
set -x

source $RSI_SCRIPTS/config.sh

PPADAILY=daily-stable
PPABRANCH=master
PROJECTS=${1:-"libestr liblogging libfastjson liblognorm librelp rsyslog"}
CUSTOMBUILD=${2}

for PROJECT in $PROJECTS
do
	# Ubuntu (bionic 18.04, ) 20.04 and 22.04
	for PLATFORM in focal jammy
	do
		cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT
		rm -fv *.tar.gz
		cp -v $INFRAHOME/repo/$PROJECT/*.tar.gz .
		$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM $PPADAILY $PPABRANCH $CUSTOMBUILD
	done
done
