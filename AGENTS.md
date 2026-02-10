# Agent-oriented guide: rsyslog-pkg-ubuntu

For AI agents and maintainers working on this repo. Script-level docs: **scripts/DOC.md**.

---

## Repository layout

- **`scripts/`** – Build, upload, and helper scripts; **DOC.md** (per-script docs), **config.sh** (PPA, key, platforms).
- **`rsyslog/`**, **`libestr/`**, **`libfastjson/`**, **`liblognorm/`**, **`librelp/`**, etc. – One directory per packaged project.
- **Per-project packaging:**  
  `/<project>/<ubuntu_suite>/<branch>/debian/`  
  Examples:
  - `rsyslog/noble/v8-stable/debian/` – control, rules, changelog, install files, patches.
  - `rsyslog/jammy/v8-stable/debian/`
  - `rsyslog/focal/v8-stable/debian/`
- **Supported Ubuntu suites** (for daily builds): **focal**, **jammy**, **noble** (see `scripts/auto_daily.sh`).
- **Branches:** e.g. **v8-stable**, **v8-stable-testing**, **daily-stable** (in `scripts/config.sh` BRANCHES).

---

## Key paths

| What | Where |
|------|--------|
| Debian packaging for rsyslog on Noble | `rsyslog/noble/v8-stable/debian/` |
| Build dependencies (control) | `rsyslog/<suite>/v8-stable/debian/control` (Build-Depends stanza) |
| Build rules | `rsyslog/<suite>/v8-stable/debian/rules` |
| Script config (PPA, key, platforms) | `scripts/config.sh` |
| Install build deps on host | `sudo scripts/install_rsyslog_builddeps.sh` |

---

## Adding or changing build dependencies

1. **Edit `debian/control`** in **each** suite you care about:
   - `rsyslog/noble/v8-stable/debian/control`
   - `rsyslog/jammy/v8-stable/debian/control`
   - `rsyslog/focal/v8-stable/debian/control`
2. Add packages to the **Build-Depends** list (comma-separated, continuation lines indented).
3. **Install the same packages on the build host** so `dpkg-checkbuilddeps` passes. Either:
   - Run `sudo scripts/install_rsyslog_builddeps.sh` and add the new package to that script, or
   - Run `sudo apt-get install -y <new-package>` on the machine that runs `auto_daily.sh` / `debuild`.

---

## Daily build flow (high level)

1. **Tarballs** are produced elsewhere (e.g. rsyslog-infrastructure `daily_tarball_rsyslog.sh`) and placed under `$INFRAHOME/repo/rsyslog/` (or the relevant project).
2. **`scripts/auto_daily.sh rsyslog daily-stable v8-stable`** (or similar) runs from this repo:
   - For each **platform** (focal, jammy, noble): copies tarball into `rsyslog/`, then runs **`scripts/auto_daily_project.sh`**.
3. **`auto_daily_project.sh`** (run from project dir, e.g. `rsyslog/`):
   - Extracts tarball, overlays `../<platform>/v8-stable/debian`, runs **debuild -S**, optionally signs and uploads to **ppa:adiscon** (e.g. daily-stable).

**Build host must have all Build-Depends installed** (see above); otherwise `dpkg-checkbuilddeps` fails.

---

## Environment variables (for automation/cron)

- **INFRAHOME** – Root path (e.g. `/home/rs_infra`).
- **RSI_SCRIPTS** – Path to rsyslog-infrastructure scripts (contains `config.sh`). Required by `auto_daily.sh` and `auto_daily_project.sh`.
- **PACKAGE_SIGNING_KEY_ID** – Set in `scripts/config.sh`; used for signing and upload when present.
- **RS_NOTIFY_EMAIL** – Used by `auto_daily_project.sh` for failure emails (mutt).

---

## Common tasks for agents

- **Add a new Build-Depends:** Edit `rsyslog/<suite>/v8-stable/debian/control` for each suite; add the package to `scripts/install_rsyslog_builddeps.sh` if it should be installed on the build host.
- **Change packaging (rules, install files, etc.):** Edit under `rsyslog/<suite>/v8-stable/debian/`; keep focal/jammy/noble in sync when intended.
- **Understand a script:** Use **scripts/DOC.md** for purpose, arguments, and where to run it.
