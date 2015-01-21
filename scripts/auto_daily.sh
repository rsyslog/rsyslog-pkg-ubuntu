#!/bin/bash
echo build all daily packages

#rsyslog
cd ~/proj/rsyslog-pkg-ubuntu/rsyslog
rm -fv *.tar.gz
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel
cp -v ~/proj/rsyslog/*.tar.gz .
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel
