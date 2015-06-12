rsyslog-pkg-ubuntu
==================

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

1. regular release builds
2. daily builds

The regular release builds are just that: for each release, we want
to create packages for all current Ubuntu platforms very close to the
rsyslog release.

In order to facilitate "leading edge users" daily builds shall
provide the most current available rsyslog software. They base on
the project's git master branch. They will be build automatically
once a day if there has been change since the previous build.

Packages Provided
-----------------
Packages are to be provided for the full rsyslog infrastructure. This
includes libraries thightly coupled into the rsyslog infrastructure and
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

