rsyslog-pkg-ubuntu
==================

[![CI PR runner](https://github.com/rsyslog/rsyslog-pkg-ubuntu/workflows/CI%20PR%20runner/badge.svg)](https://github.com/rsyslog/rsyslog-pkg-ubuntu/actions?query=workflow%3A%22CI+PR+runner%22)
[![Install rsyslog packages from OBS](https://github.com/rsyslog/rsyslog-pkg-ubuntu/workflows/Install%20rsyslog%20packages%20from%20OBS/badge.svg?branch=master)](https://github.com/rsyslog/rsyslog-pkg-ubuntu/actions?query=workflow%3A%22Install+rsyslog+packages+from+OBS%22)
[![Install rsyslog packages from PPA](https://github.com/rsyslog/rsyslog-pkg-ubuntu/workflows/Install%20rsyslog%20packages%20from%20PPA/badge.svg)](https://github.com/rsyslog/rsyslog-pkg-ubuntu/actions?query=workflow%3A%22Install+rsyslog+packages+from+PPA%22)

This respository contains the sources needed to build Ubuntu rsyslog
packages. It is our goal to create the best possible packages for
the current releases of this platform.

Packages are available as PPAs.
See: http://www.rsyslog.com/ubuntu-repository/

Contributors and co-maintainers are welcome.

Script descriptions are in [INSTALL](INSTALL.md).

Project Goals
-------------

- provide excellent packages via PPAs in a timely manner
- provide scripts to be used by others who do build on their own
- learn how to collaborate on package development
- gain experience

This project is currently kind of a pilot project for other collaboration
and packaging efforts. Among others, we would like to build packages for
other platforms. We also want to create a better (and easier to manage)
extended testbench system. We will consider Buildbot and SuSE OBS at a
later stage. But before going into this larger projects, we want to gain
experience in this packaging project.

PPA Structure
-------------
We intend to maintain two different sets of PPAs:

1. regular release builds (v8-stable)
2. daily builds (v8-devel)

The regular release builds are just that: for each release, we want
to create packages for all current Ubuntu platforms very close to the
rsyslog release.

In order to facilitate "leading edge users" daily builds shall
provide the most current available rsyslog software. They base on
the project's git master branch. They will be built automatically
once a day if there has been change since the previous build.

All other branches are explicitely to be considered experimental and
are not to be used for productive environments.

Packages Provided
-----------------
Packages are to be provided for the full rsyslog infrastructure. This
includes libraries tightly coupled into the rsyslog infrastructure and
essentially maintained by the same team. Examples for these are librelp
and liblognorm.

We try to avoid providing unrelated softwares, even if that means we
cannot package some of rsyslog's functionality. The main driving force
behind this is that by providing packages, we also take responsibility
for security issues in them and so we have an additional burden of
monitoring this "external" software. As such, we can grant and exception
of the general rule if and only if a member of such third-party software
is also a member of rsyslog's release team AND commits to keeping the
packages current.

Currently available
-------------------
Supporting libraries:
- libfastjson
- liblogging
- liblognorm
- librelp

Sub-packages for rsyslog to provide specific functionality:
- rsyslog (base package, always needed)
- rsyslog-doc
- rsyslog-elasticsearch
- rsyslog-imptcp
- rsyslog-kafka (>=14.04)
- rsyslog-mmanon
- rsyslog-mmfields
- rsyslog-mmjsonparse
- rsyslog-mmnormalize
- rsyslog-mmrm1stspace
- rsyslog-mmutf8fix
- rsyslog-mongodb (>=16.04)
- rsyslog-mysql
- rsyslog-pgsql
- rsyslog-pmnormalize (>=16.04)
- rsyslog-relp
- rsyslog-utils

How to install
--------------

1. Open a Terminal
2. Enter the following command:
```
sudo add-apt-repository ppa:adiscon/v8-stable 
```
3. Then update your apt cache:
```
sudo apt-get update
```
4. Finally install the new rsyslog version:
```
sudo apt-get install rsyslog
```


File System Structure
---------------------
```
 .                 our "home directory"
  scripts          contains all scripts to use
  project          files to build project-specific package
                   (project is rsyslog, librelp, ...)
    common         "base" package build control files
      branch       ... for this specific branch (e.g. master, v8-stable)
    ubuntu-ver     "overrides" of package control files for this
                   specific Ubuntu version (e.g. trusty, precise, ...)
      branch       ... for this specific branch (e.g. master, v8-stable)
                   note that "branch" may not exist if not needed
		   (e.g. common contains everything necessary to build
		   the package)
```


Overall idea of the build Process
---------------------------------
NOTE: as of now, this information is correct for the daily builds process.
The legacy manual build process does not currently use this scheme. The
legacy process shall be updated ASAP.


This repo contains scripts and control files to build rsyslog and its
immediate helpers, like librelp. It may also contain the necessary things
to build packages for non-close helpers if they fulful the criteria layed
out at the top of the page.

Each package has its own directory in the top directory. Each of them 
contains a directory named "common" and directories for the specific
Ubuntu branches (like trusty or precise). The idea here is that we have a
lot of information that is common to all Ubuntu versions. In order to
make changes easier, we keep most stuff in "common" and just keep
exceptions in the "ubuntu-ver" directories. When building we use a
working directory for each package build. The scripts first copy
"common" to it, and the copy the correct "ubuntu-ver" over that data.
That way, we can keep generic stuff in "common" and override it with
Ubuntu version specific additional stuff. This is especially useful when
new Ubuntu versions appear, in which case we usually can just use the
regular "common" stuff without the need to dig deeper into details. Of
course, this depends on the magnitude of changes done in the new Ubuntu
versions, but experience tells this used to work rather well.

Note that "common" probably needs to be updated from time to time, and
this may lead to it becoming incompatible with older versions of Ubuntu.
If this happens, we should update common the match the majority of versions,
and especially the newer ones. So we may need to migrate some stuff from
"common" to one or more older "ubuntu-ver" (which previously needed no
override). This approach will enable us to keep up with Ubuntu development.

From time to time, we should evaluate if the "common"/"ubuntu-ver" override
mechanism actually provides benefit over just keeping everything in 
"ubuntu-ver". If there are no compelling benefits, we may want to go to
an "ubuntu-ver", only approach. Note, thought, that pre-2015 we had such
an "ubuntu-ver" only approach and it lead to delays when new Ubuntu versions
came out. We tried to solve this with the introduction of "common" and
the policy layed out here.

The build process currently has the PPA system "in mind". That means all
scripts generate the necessary control files and load them up to launchpad.
The actual build is then performed by launchpad.


What to do on new Ubuntu Release?
---------------------------------
Let's assume vivid is the current release and wily the next one.

For all projects, do

- create new "wily" subdirectory in project dir
- cp -r vivid/* wily
- make adaptions to wily files, if necessary
- git add wily

--> this procedure ensures we start with the latest version. It's most
likely that this will work on the newer version as well.

Next, update all scripts, namely auto_daily.sh to include the "wily" release.


What to do if a new package for an existing project is to be added?
===================================================================
In general, this should happen only for new functionality. However,
if we need to enable something in older builds, that's of course
possible, but requires more editing work.

In general, control files in all Ubuntu versions need to be edited for
all versions we maintain. For the current build, with rsyslog, this
usually means you need to edit v8-stable and master, as well as 
v7-stable, as long as we maintain it for the platform. As v7-stable
will not receive updates any longer, you usually do not need to look
at that. If a new feature is added to master, you can edit it only
there, for obvious reasons. When this feature becomes released, you
can simply copy the master control files to v8-stable and are
(hopefully) set. 

If, however, something was forgotten (or we just discovered we could already
have done it), you need to edit all control files along all versions
supported. If there are e.g. 5 Ubuntu platforms and there are master,
v8-stable and v7-stable for all of them, that unfortunately means you 
need to apply the same edit 15 times in the case of rsyslog.
That's ugly, but the way it currently is. We are open to contributions
that make this easier (but please contribute code, not "just" ideas -
that's because we have many good ideas ourselfs, but no time to
code them up ;)).


How to generate an official release?
====================================
- cd to rsyslog-pkg-ubuntu/<project>
- ./repack.sh <release tarball url>
- ./uploadppa.sh
- select repository
- select platform
- make changelog entry (more detail instructions, pls)
- copy back?
- upload?
-
