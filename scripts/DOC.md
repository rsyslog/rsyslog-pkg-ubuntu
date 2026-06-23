# rsyslog-pkg-ubuntu scripts

Scripts for building and publishing Debian/Ubuntu packages for rsyslog and related projects (libestr, libfastjson, liblognorm, librelp, etc.) to the Adiscon PPA.

**Prerequisites:** `config.sh` is sourced by most scripts. Set `RSI_SCRIPTS` (path to rsyslog-infrastructure scripts) and `INFRAHOME` when running from cron or other automation.

---

## Daily / automated builds

| Script | Purpose |
|--------|--------|
| **auto_daily.sh** | Top-level daily build: for each project and each platform (focal, jammy, noble), copies tarball from `$INFRAHOME/repo/<project>/` and runs `auto_daily_project.sh`. **Args:** `[PROJECTS] [PPAREPO] [PPABRANCH] [CUSTOMBUILD]`. Example: `./auto_daily.sh rsyslog daily-stable v8-stable`. |
| **auto_daily_project.sh** | Build one project for one Ubuntu suite. **Must be run from the project dir** (e.g. `rsyslog/`). Extracts tarball, overlays `../<platform>/<branch>/debian`, runs debuild, optionally signs and uploads to PPA. **Args:** `PLATFORM UPLOAD_PPA BRANCH [CUSTOMBUILD] [debuild-mode]`. Optional 5th arg `sd` selects `debuild -sd` (packaging-only; orig must already be on PPA). Default is `-sa`. Library projects can have a `CURR_LIBSONAME` file (e.g. `4` for libfastjson4). |
| **full_rebuild.sh** | Removes all `LAST_*` version files so the next daily run will rebuild and re-upload every project/suite. Run from repo root. |
| **install_rsyslog_builddeps.sh** | Install build-deps needed for `debuild` on the build host (libprotobuf-c-dev, libsnappy-dev, protobuf-c-compiler, libyaml-dev). Run once: `sudo ./scripts/install_rsyslog_builddeps.sh`. |

---

## Manual release / upload

| Script | Purpose |
|--------|--------|
| **uploadppa.sh** | Interactive: choose extracted package dir, PPA branch, and Ubuntu dist; copy debian from `$szPlatform/$szBranch/debian`, build source package (`debuild -S -sa` or `-sd`), optionally add changelog, then sign and dput to `ppa:adiscon/$UPLOAD_PPA`. Supports vendor upstream versions (e.g. `2.1.0+adiscon1`). Run from a project dir that contains exactly one `$PACKAGENAME*/` directory. |
| **prepare.sh** | Interactive: choose package dir, branch, and platform; copy debian in, run `dch -D $szPlatform -i` and debuild -S, then optionally copy debian back to `$szPlatform/$szBranch/debian`. Uses `KEY_ID` (may need to be set; config has `PACKAGE_SIGNING_KEY_ID`). Run from project parent. |
| **updaterelease.sh** | Interactive: choose rsyslog dir, run dch -i and debuild -S. Uses `KEY_ID`. Run from directory that contains `rsyslog*/` dirs. |

---

## Tarball and repack

| Script | Purpose |
|--------|--------|
| **repack.sh** | Download a tarball by URL (`$1`), extract it, and rename to `*.orig.tar.gz` (Debian convention). Optional vendor suffix (`$2`, e.g. `+adiscon1`) when the plain upstream version conflicts with Ubuntu primary archive. Run from project dir; only one `.tar.gz` allowed. |
| **ubuntu_orig_conflict.sh** | Check whether Ubuntu primary archive has a different `package_X.Y.Z.orig.tar.gz`. **Args:** `package version [local-orig-file]`. Exit 0 if vendor suffix recommended. Used by `auto_daily_project.sh`. |
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

---

## Primary archive orig conflicts

Launchpad rejects uploads when `package_X.Y.Z.orig.tar.gz` already exists in the Ubuntu primary archive with **different content** than your tarball (common when GitHub release tarballs differ from Debian repacks).

**Normal release** (no conflict):

```bash
./repack.sh <github-release-url>
./uploadppa.sh    # debuild -sa on first upload (SUBVERSION 1)
```

**Ubuntu primary conflict** (e.g. liblognorm 2.1.0):

```bash
./repack.sh https://github.com/rsyslog/liblognorm/releases/download/v2.1.0/liblognorm-2.1.0.tar.gz +adiscon1
./uploadppa.sh    # SUBVERSION 1 + -sa per suite (noble, focal, jammy); SUBVERSION 2+ + -sd only after PPA accepted -sa
```

**SUBVERSION** is a per-suite counter (`noble1`, `noble2`, …). It resets to **1** when the upstream version changes (e.g. new `+adiscon1` suffix). Old `noble3` from rejected `2.1.0` uploads does not apply to `2.1.0+adiscon1`.

| Situation | Action |
|-----------|--------|
| New upstream, not in Ubuntu primary | `repack.sh <url>` + `uploadppa.sh` + `-sa` |
| GitHub tarball differs from Ubuntu for same `X.Y.Z` | `repack.sh <url> +adiscon1` + `uploadppa.sh` + `-sa` |
| Packaging-only fix, vendor version already in PPA | same tree + `uploadppa.sh` + `-sd` |

The `+adiscon1` suffix changes the **source package version** (e.g. `2.1.0+adiscon1-0adiscon1noble1`), not binary package names (`liblognorm5`, `liblognorm-dev`). Existing installations upgrade normally via `apt upgrade`.

`auto_daily_project.sh` applies `+adiscon1` automatically when `ubuntu_orig_conflict.sh` detects a mismatch. It defaults to `debuild -sa` (CUSTOMBUILD is part of the upstream version, so each build needs its own orig). Pass a 5th argument `sd` only for packaging-only re-uploads when the orig is already on the PPA.
