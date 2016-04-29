#!/bin/bash
echo create new Ubuntu release


#libfastjson
for PROJECT in libfastjson libestr liblogging \
               librelp liblognorm libgt libksi rsyslog
do
	echo "**** $PROJECT ****"
	mkdir $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT/yakkety
	cp -r $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT/xenial/* $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT/yakkety
	git add $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT/yakkety
done
