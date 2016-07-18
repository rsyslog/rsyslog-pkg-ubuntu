#!/bin/bash
# Prequitsites: tarballs must exist in $INFRAHOME/repo/<project>
# for all to be built projects. These tarballs must have been created
# by "make dist". The tarball must be copied to this packages home
# directory. Only one tarball must exist at the same time.
echo build all daily packages
date
set -v
set -x


#libfastjson
for PROJECT in libfastjson libestr liblogging \
               librelp liblognorm libgt libksi rsyslog
do
	for PLATFORM in precise trusty vivid wily xenial yakkety
	do
		cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT
		rm -fv *.tar.gz
		cp -v $INFRAHOME/repo/$PROJECT/*.tar.gz .
		$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
	done
done
