#!/bin/bash
# Prequitsites: tarballs must exist in $INFRAHOME/repo/<project>
# for all to be built projects. These tarballs must have been created
# by "make dist". The tarball must be copied to this packages home
# directory. Only one tarball must exist at the same time.
echo build all daily packages
date

#libestr
cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/libestr
rm -fv *.tar.gz
cp -v $INFRAHOME/repo/libestr/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v $INFRAHOME/repo/libestr/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master



exit 1




cp -v $INFRAHOME/repo/libestr/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v $INFRAHOME/repo/libestr/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 

#liblogging
cd ~/proj/rsyslog-pkg-ubuntu/liblogging
rm -fv *.tar.gz
cp -v ~/proj/liblogging/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v ~/proj/liblogging/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master
cp -v ~/proj/liblogging/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v ~/proj/liblogging/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 

#librelp
cd ~/proj/rsyslog-pkg-ubuntu/librelp
rm -fv *.tar.gz
cp -v ~/proj/librelp/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v ~/proj/librelp/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master
cp -v ~/proj/librelp/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v ~/proj/librelp/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 

#liblognorm
cd ~/proj/rsyslog-pkg-ubuntu/liblognorm
rm -fv *.tar.gz
cp -v ~/proj/liblognorm/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v ~/proj/liblognorm/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master
cp -v ~/proj/liblognorm/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v ~/proj/liblognorm/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 

#libgt
cd ~/proj/rsyslog-pkg-ubuntu/libgt
rm -fv *.tar.gz
cp -v ~/proj/libgt/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v ~/proj/libgt/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master
cp -v ~/proj/libgt/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v ~/proj/libgt/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 

#rsyslog
cd ~/proj/rsyslog-pkg-ubuntu/rsyslog
rm -fv *.tar.gz
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh utopic v8-devel master
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master

date
