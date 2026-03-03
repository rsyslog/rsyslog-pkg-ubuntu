# rsyslog-pkg-ubuntu scripts

Scripts for building and publishing Debian/Ubuntu packages for rsyslog and related projects (libestr, libfastjson, liblognorm, librelp, etc.) to the Adiscon PPA.

**Prerequisites:** `config.sh` is sourced by most scripts. Set `RSI_SCRIPTS` (path to rsyslog-infrastructure scripts) and `INFRAHOME` when running from cron or other automation.

---

## Daily / automated builds

| Script | Purpose |
|--------|--------|
| **auto_daily.sh** | Top-level daily build: for each project and each platform (focal, jammy, noble), copies tarball from `$INFRAHOME/repo/<project>/` and runs `auto_daily_project.sh`. **Args:** `[PROJECTS] [PPAREPO] [PPABRANCH] [CUSTOMBUILD]`. Example: `./auto_daily.sh rsyslog daily-stable v8-stable`. |
| **auto_daily_project.sh** | Build one project for one Ubuntu suite. **Must be run from the project dir** (e.g. `rsyslog/`). Extracts tarball, overlays `../<platform>/<branch>/debian`, runs debuild, optionally signs and uploads to PPA. **Args:** `PLATFORM UPLOAD_PPA BRANCH [CUSTOMBUILD]`. Library projects can have a `CURR_LIBSONAME` file (e.g. `4` for libfastjson4). |
| **full_rebuild.sh** | Removes all `LAST_*` version files so the next daily run will rebuild and re-upload every project/suite. Run from repo root. |
| **install_rsyslog_builddeps.sh** | Install build-deps needed for `debuild` on the build host (libprotobuf-c-dev, libsnappy-dev, protobuf-c-compiler, libyaml-dev). Run once: `sudo ./scripts/install_rsyslog_builddeps.sh`. |

---

## Manual release / upload

| Script | Purpose |
|--------|--------|
| **uploadppa.sh** | Interactive: choose extracted package dir, PPA branch, and Ubuntu dist; copy debian from `$szPlatform/$szBranch/debian`, build source package (debuild -S), optionally add changelog, then sign and dput to `ppa:adiscon/$UPLOAD_PPA`. Run from a project dir (e.g. `rsyslog/`) that contains exactly one `$PACKAGENAME*/` directory. |
| **prepare.sh** | Interactive: choose package dir, branch, and platform; copy debian in, run `dch -D $szPlatform -i` and debuild -S, then optionally copy debian back to `$szPlatform/$szBranch/debian`. Uses `KEY_ID` (may need to be set; config has `PACKAGE_SIGNING_KEY_ID`). Run from project parent. |
| **updaterelease.sh** | Interactive: choose rsyslog dir, run dch -i and debuild -S. Uses `KEY_ID`. Run from directory that contains `rsyslog*/` dirs. |

---

## Tarball and repack

| Script | Purpose |
|--------|--------|
| **repack.sh** | Download a tarball by URL (`$1`), extract it, and rename to `*.orig.tar.gz` (Debian convention). Run from project dir; only one `.tar.gz` allowed. |
| **putarchive.sh** | Interactive: select .dsc, platform, and arch; run `dput local` to push built packages to a local archive. Expects pbuilder result in `../pbuilder/$szPlatform..._result/`. |

---

## CI lokal (Ubuntu 24.04)

| Script | Purpose |
|--------|--------|
| **ci_local.sh** | Simuliert die GitHub-Actions-CI lokal: Source-Paket-Build plus optional Binary-Build in Docker. **Args:** `[--suite noble] [--source-only|--full]`. Run from repo root. Siehe `docs/CI-LOCAL.md`. |

---

## Build and install (pbuilder / local)

| Script | Purpose |
|--------|--------|
| **build.sh** | Interactive: select .dsc, platform, arch (or All); run `pbuilder-dist $szPlatform $szArchitect build $szDscFile` for each arch. Run from a dir that has `.dsc` files. |
| **install.sh** | Interactive: select .dsc, platform, arch; run `dput $szBranch` to upload built packages (no build). Run from dir with .dsc files. |
| **installpackage.sh** | Update pbuilder for precise and install a package inside (e.g. `libzmq-dev`). Precise-specific. |
| **reupload.sh** | Interactive: select .dsc, platform, arch; re-upload existing .changes via dput (no build). |
| **results.sh** | Not a script; contains the path `/var/cache/pbuilder/result` (pbuilder output directory). |

---

## Configuration

| Script | Purpose |
|--------|--------|
| **config.sh** | Defines: `PLATFORM`, `ARCHTECT`, `BRANCHES`, `PACKAGE_SIGNING_KEY_ID`, `PPA`, `DEBEMAIL`, `EMAIL`. Source this from other scripts; also used by rsyslog-infrastructure (e.g. `RSI_SCRIPTS/config.sh`). |

---

## Environment variables (used by scripts)

- **INFRAHOME** – Base path (e.g. `/home/rs_infra`). Set by cron_starter or manually.
- **RSI_SCRIPTS** – Path to rsyslog-infrastructure scripts; must point to a dir containing `config.sh` (often `$INFRAHOME/repo/rsyslog-infrastructure/scripts`).
- **PPA** – e.g. `ppa:adiscon`.
- **PACKAGE_SIGNING_KEY_ID** – GPG key for signing packages and uploads.
- **RS_NOTIFY_EMAIL** – Used by `auto_daily_project.sh` for failure notifications (mutt).
- **KEY_ID** – Used by `prepare.sh` and `updaterelease.sh`; may be unset (consider aligning with `PACKAGE_SIGNING_KEY_ID`).
