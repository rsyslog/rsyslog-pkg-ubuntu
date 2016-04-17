#!/bin/bash
# Prequitsites: tarballs must exist in $INFRAHOME/repo/<project>
# for all to be built projects. These tarballs must have been created
# by "make dist". The tarball must be copied to this packages home
# directory. Only one tarball must exist at the same time.
echo build all daily packages
date


#libfastjson
for PROJECT in libfastjson libestr liblogging \
               librelp liblognorm libgt libksi rsyslog
do
	for PLATFORM in precise trusty vidid wily xenial
	do
		cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/$PROJECT
		rm -fv *.tar.gz
		cp -v $INFRAHOME/repo/$PROJECT/*.tar.gz .
		$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
	done
done
exit


#libestr
for PLATFORM in precise trusty vidid wily xenial
	cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/libestr
	rm -fv *.tar.gz
	cp -v $INFRAHOME/repo/libestr/*.tar.gz .
	$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
done


#liblogging
for PLATFORM in precise trusty vidid wily xenial
	cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/liblogging
	rm -fv *.tar.gz
	cp -v $INFRAHOME/repo/liblogging/*.tar.gz .
	$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
done


#librelp
for PLATFORM in precise trusty vidid wily xenial
	cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/librelp
	rm -fv *.tar.gz
	cp -v $INFRAHOME/repo/librelp/*.tar.gz .
	$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
done

#liblognorm
for PLATFORM in precise trusty vidid wily xenial
	cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/liblognorm
	rm -fv *.tar.gz
	cp -v $INFRAHOME/repo/liblognorm/*.tar.gz .
	$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
done

#libgt
for PLATFORM in precise trusty vidid wily xenial
	cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/libgt
	rm -fv *.tar.gz
	cp -v $INFRAHOME/repo/libgt/*.tar.gz .
	$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh $PLATFORM v8-devel master
done

#libksi
cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/libksi
rm -fv *.tar.gz
cp -v $INFRAHOME/repo/libksi/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v $INFRAHOME/repo/libksi/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master 
cp -v $INFRAHOME/repo/libksi/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master 
cp -v $INFRAHOME/repo/libksi/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh wily v8-devel master 

#rsyslog
cd $INFRAHOME/repo/rsyslog-pkg-ubuntu/rsyslog
rm -fv *.tar.gz
cp -v $INFRAHOME/repo/rsyslog/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh precise v8-devel master
cp -v $INFRAHOME/repo/rsyslog/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh trusty v8-devel master
cp -v $INFRAHOME/repo/rsyslog/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh vivid v8-devel master
cp -v $INFRAHOME/repo/rsyslog/*.tar.gz .
$INFRAHOME/repo/rsyslog-pkg-ubuntu/scripts/auto_daily_project.sh wily v8-devel master

date
