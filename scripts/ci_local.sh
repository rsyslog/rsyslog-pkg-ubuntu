#!/bin/bash
# Run CI pipeline locally (Ubuntu 24.04).
# Mimics .github/workflows/ci.yml: source package build + optional binary build with tests.
#
# Usage:
#   ./scripts/ci_local.sh [--suite noble] [--source-only|--full]
#
# Options:
#   --suite SUITE   focal, jammy, or noble (default: noble)
#   --source-only   Only build source package (fast, for patch/rule checks)
#   --full          Source package + binary build + tests in Docker (like CI)
#
# Prerequisites (Ubuntu 24.04):
#   sudo apt-get install -y dpkg-dev wget curl jq
#   For --full: Docker, and:
#   sudo apt-get install -y docker.io  # or docker-ce
#   # Add yourself to docker group or use sudo
#
# Run from repository root.
set -e

SUITE="${SUITE:-noble}"
MODE="source-only"

while [ $# -gt 0 ]; do
  case "$1" in
    --suite)
      if [ -z "${2:-}" ]; then
        echo "Error: --suite requires a value (focal, jammy, noble)" >&2
        exit 1
      fi
      SUITE="$2"
      shift 2
      ;;
    --source-only)
      MODE="source-only"
      shift
      ;;
    --full)
      MODE="full"
      shift
      ;;
    -h|--help)
      head -20 "$0" | tail -18
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Map suite to container image (same as CI)
case "$SUITE" in
  focal)  IMAGE="ubuntu:20.04" ;;
  jammy)  IMAGE="ubuntu:22.04" ;;
  noble)  IMAGE="ubuntu:24.04" ;;
  *)
    echo "Unsupported suite: $SUITE (use focal, jammy, noble)" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DEBIAN_DIR="rsyslog/${SUITE}/v8-stable/debian"
if [ ! -d "$DEBIAN_DIR" ]; then
  echo "Error: $DEBIAN_DIR not found. Run from repository root." >&2
  exit 1
fi

# Check required tools (Ubuntu: sudo apt-get install -y dpkg-dev wget curl jq)
for cmd in dpkg-parsechangelog wget curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found. Install with:" >&2
    echo "  sudo apt-get install -y dpkg-dev wget curl jq" >&2
    exit 1
  fi
done

BUILD_DIR="${BUILD_DIR:-/tmp/rsyslog-ci-local-$$}"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "=== CI Local: suite=$SUITE mode=$MODE ==="

# Get latest rsyslog version (same as CI)
echo "Fetching latest rsyslog version..."
TAG=$(curl -sL "https://api.github.com/repos/rsyslog/rsyslog/releases/latest" | jq -r .tag_name)
if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
  TAG=$(curl -sL "https://api.github.com/repos/rsyslog/rsyslog/tags?per_page=5" | jq -r '.[0].name')
fi
if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
  echo "Could not get latest tag" >&2
  exit 1
fi
VERSION="${TAG#v}"
echo "Using upstream version: $VERSION (tag: $TAG)"

# Download tarball
echo "Downloading tarball..."
wget -q "https://github.com/rsyslog/rsyslog/archive/refs/tags/${TAG}.tar.gz" \
  -O "rsyslog_${VERSION}.orig.tar.gz"

# Prepare source tree
echo "Preparing source tree..."
tar xf "rsyslog_${VERSION}.orig.tar.gz"
if [ ! -d "rsyslog-${VERSION}" ]; then
  mv rsyslog-* "rsyslog-${VERSION}"
fi
rm -rf "rsyslog-${VERSION}/debian"
cp -r "$REPO_ROOT/$DEBIAN_DIR" "rsyslog-${VERSION}/"
# Ensure LF line endings in debian/ (CRLF breaks make in Docker)
# Exclude binary files (.tar.gz) - sed would corrupt them
find "rsyslog-${VERSION}/debian" -type f ! -name '*.tar.gz' -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
# debian config files must not be executable (debhelper treats exec as script)
# Exception: rsyslog.install uses dh-exec (shebang) and MUST stay executable
chmod -x "rsyslog-${VERSION}/debian/clean" "rsyslog-${VERSION}/debian/not-installed" 2>/dev/null || true
find "rsyslog-${VERSION}/debian" -type f \( \
  -name '*.dirs' -o -name '*.install.*' -o \
  -name '*.config' -o -name '*.conf.template' -o -name '*.apparmor' -o \
  -name '*.docs' -o -name '*.examples' -o \
  -name '*.logrotate' -o -name '*.triggers' -o -name '*.maintscript' -o -name '*.logcheck.ignore.*' \
  \) -exec chmod -x {} \; 2>/dev/null || true
find "rsyslog-${VERSION}/debian" -type f -name '*.install' ! -name 'rsyslog.install' -exec chmod -x {} \; 2>/dev/null || true

# Update changelog version
CHANGELOG_VER=$(dpkg-parsechangelog -l "rsyslog-${VERSION}/debian/changelog" -S Version)
CHANGELOG_UPSTREAM="${CHANGELOG_VER%%-*}"
if [ "$CHANGELOG_UPSTREAM" != "$VERSION" ]; then
  echo "Updating changelog: $CHANGELOG_UPSTREAM -> $VERSION"
  sed -i "1s/${CHANGELOG_UPSTREAM}/${VERSION}/" "rsyslog-${VERSION}/debian/changelog"
fi

# Build source package
echo "Building source package (dpkg-source -b)..."
cd "rsyslog-${VERSION}"
dpkg-source -b .
cd ..
echo "Source package built:"
ls -la rsyslog_*.dsc rsyslog_*.debian.tar.* rsyslog_*.orig.tar.gz 2>/dev/null || true

if [ "$MODE" = "source-only" ]; then
  echo "=== Done (--source-only). Use --full for binary build + tests. ==="
  exit 0
fi

# Full mode: binary build in Docker (like CI)
# Remove extracted source tree so dpkg-source -x can extract cleanly
rm -rf rsyslog-*/
echo "=== Building binary packages in $IMAGE container ==="
DSC=$(ls rsyslog_*.dsc | head -1)

docker run --rm -v "$(pwd):/work" -w /work "$IMAGE" bash -c '
  set -e
  apt-get update -qq
  apt-get install -y -qq software-properties-common > /dev/null
  add-apt-repository -y universe > /dev/null 2>&1
  add-apt-repository --yes --update ppa:adiscon/v8-stable > /dev/null 2>&1
  apt-get update -qq
  apt-get install -y -qq dpkg-dev devscripts build-essential fakeroot equivs flex > /dev/null
  dpkg-source -x *.dsc
  SRCDIR=$(ls -d rsyslog-*/ 2>/dev/null | head -1)
  cd "$SRCDIR"
  mk-build-deps -i -r -t "apt-get -y --no-install-recommends"
  debuild -b -us -uc
'

echo "=== Done. Binary packages: ==="
find . -maxdepth 2 -name "*.deb" -type f -exec ls -la {} \;
echo "Build artifacts left in: $BUILD_DIR"
