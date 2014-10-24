!#/bin/sh

pbuilder-dist precise update
pbuilder-dist precise login
apt-get install libzmq-dev

pbuilder-dist precise i386 update
pbuilder-dist precise login
apt-get install libzmq-dev

