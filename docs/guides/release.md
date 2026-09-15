# LinuxAid Release Guide

Creating a new release in LinuxAid is handled via the automated release script (`bin/release.sh`), which generates release notes from git history, updates the OpenVox environment version in Hiera, commits, tags, and safely publishes/mirrors to both GitHub and Gitea.

---

## 🚀 Running a Release

To create a new release, ensure you are on the `master` branch and run the release script with a semantic version tag:

```bash
bin/release.sh <new-tag>
```

Example:

```bash
bin/release.sh v1.9.0
```

---

## 🔍 Dry-Run Mode (Safe Simulation)

If you want to test and validate pre-flight checks, changelog generation, and remote states without making any changes, use the `--dry-run` (or `-n`) flag:

```bash
bin/release.sh v1.9.0 --dry-run
```

---

## 🛡️ Pre-Flight Checks & Safety Validations

Before making any changes or pushing to remotes, `bin/release.sh` performs robust automated checks:

1. **Tag Format & SemVer Validation**: Ensures the tag starts with `v` and follows semantic versioning (`vMAJOR.MINOR.PATCH`).
2. **Version Comparison**: Ensures the new tag is strictly greater than the previous release tag (preventing duplicates or regressions).
3. **Branch & Sync Validation**: Verifies you are on the `master` branch and that your local branch is fully up-to-date with `origin/master`.
4. **Remote Configuration & Access Verification**: Verifies `origin` points to GitHub and `gitea` points to the Gitea mirror, and tests write access using push dry-runs.
5. **Interactive Preview Dashboard**: Displays a summary of the release details and prompts for confirmation (`y`/`yes`) before proceeding.

---

## ⚠️ Split-Brain & Remote Synchronization Handling

If a previous release failed or was interrupted halfway (leaving GitHub and Gitea out of sync or missing a tag on one remote), the script automatically detects these **split-brain** or **remote sync mismatch** states and offers interactive recovery options:

* **Lagging Remotes**: Prompts to automatically synchronize `gitea/master` with `origin/master`.
* **Missing Remote Tags**: Detects if a tag exists on one remote but is missing on the other and prompts to push the missing tag to reconcile both platforms.
