#!/bin/bash
echo build all daily packages

# GPG KEY
KEY_ID=AEF0CF8E

cd ~/proj/rsyslog-pkg-ubuntu/rsyslog
rm -fv *.tar.gz
cp ~/proj/rsyslog/*.tar.gz ~/proj/rsyslog-pkg-ubuntu/rsyslog

cd ~/proj/rsyslog-pkg-ubuntu/rsyslog

~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel
~/proj/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel
