#!/bin/bash
# Install build dependencies required to run debuild for rsyslog on this host.
# Run once on the build machine (e.g. before daily builds):
#   sudo ./scripts/install_rsyslog_builddeps.sh
# Or: sudo apt-get install -y libprotobuf-c-dev libsnappy-dev protobuf-c-compiler libyaml-dev

set -e
apt-get update
apt-get install -y \
  libprotobuf-c-dev \
  libsnappy-dev \
  protobuf-c-compiler \
  libyaml-dev
echo "rsyslog build dependencies installed."
