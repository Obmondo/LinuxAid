# Changelog

All releases and the changes included in them (pulled from git commits added since last release) will be detailed in this file.

## LinuxAid Release Version v1.4.6

### Bug Fixes
- b5b66dad fix: allow metrics which matches the certname, this is required to allow nodes like blackbox exporter nodes to send the metrics to the upstream prom server, since the exported resource have a diff certname and it wont match the node certname, which is correct
- cf6744ea fix: include node name when setting up netbird
- 75c18660 fix: added a strict check on target give for blackbox that it needs to be a https url and handle resource naming
- 62b9fafa fix: created domain and url label for blackbox exporter, so we match exactly on the threshold record label, since it had only domain, we could have added url in the threshold record, but domains sound fine to read and understand and url is easy to showcase the actual url, since some url has some endpoints too
- ea5930b1 fix: let monitor::domains handle https url as well
- c18b95a3 fix: added back the httpurl type check for monitoring, since user can give url with some endpoints as well to monitor
- 8366faaa fix: domains is now just fqdn and fqdn:port
- 042b2959 fix(blackbox_exporter) allow TLS inspection to expose expired certificate metrics
- cac281e8 fix: install kmod-tun via package resource
- 2fe09956 fix(gitea-backup): add pre-run cleanup and simplify rotation logic

### Configuration Changes
- bfc5e3b0 chore: add doc for installing linuxaid on turris routers with netbird integration
- 32aee323 chore: address the yaml lint failures
- d3d0e9a6 chore: update openvox version to 8.24.2

### Other Changes
- d400a51e Add --volumes to Docker system prune cron job

## LinuxAid Release Version v1.4.5

### Bug Fixes
- 067471edf fix: handle turrisos multi-arch for netbird install
- 51301212b fix: handle regex match existence for raidcontrollers

### Configuration Changes
- 007109564 chore: move armv7l arch hiera config to turrisos with proper segregation and update netbird version
- c3df9279a chore: update the gitea workflow to accept harbor creds from org secrets

## LinuxAid Release Version v1.4.4

### Bug Fixes
- 9b815b584 fix: read db buffer pool and log file size from variables

### Configuration Changes
- 00fd9494a chore: basic auth is still used for tags endpoint, have asked the team to fix this
- 1f130300a chore(fix); removed the unwanted logic to figure out the func to talk to api and fallback to good old method and removed the basic auth as well, since its not used anymore
- ac5a6d43b chore: added puppet-subversion module 867e10c4611e5712d64e632cc9b8aedaf1499e39

## LinuxAid Release Version v1.4.3

### Configuration Changes
- dfc1d11b chore: update linuxaid-cli release version v1.2.0 with checksum

## LinuxAid Release Version v1.4.2

### Bug Fixes
- 73671d9a fix the bug for calling the facts for init_system and fix os family selector for linuxaid-cli package version

### Other Changes
- 0ff54dee ci: update linuxaid-ci image to v0.0.2, fix ci issues

## LinuxAid Release Version v1.4.1

### Features
- 2412fac1 feat: add support for installing linuxaid-cli from package and archive
- 70f8a629 feat: enable SSH key fingerprint logging for ISO 27001/NIS2 compliance

### Bug Fixes
- dc23a292 fix puppet string error in role::computing::slurm
- 7c28e256 fix: update realmd module to release e3bc94118397333121e0a7fc5c99b20a0fad1429
- f66032c2 fix linuxaid ci issues

### Configuration Changes
- 11d6b870 chore: update linuxaid-cli release version with checksum
- 9da5c7b8 chore: updated puppet-slurm module @8b1988aeeba726afe8fe1af67849b1a88b91a81e
- dd500581 chore: updated puppet-realmd module @b7ff74a47f9bff2fa29dc7fb2838b1f4a57f6f11

### Other Changes
- 420aa073 Updated linux aid comparison metrics acc to suggestions
- 61fc57f7 add puppet docstring ci
- 07706470 Enable slurm metrics
- 03ee3f6a add encrypt_params tag in puppet docstring
- c0ddff6a linuxaid-ci: fix NoMethodError in puppet classes
- df5fb03e add groups in puppet classes
- 8dd798e8 Adjust value to match apt::source class parameter

## LinuxAid Release Version v1.4.0

### Features
- 967474a9 feat: removed the bad exit in the release script and added a doc as well
- 00e708e0 feat: added a release script to and moved openvox env to common hiera

### Bug Fixes
- 102e2fff fix: goreleaser should read release note from a custom file

### Configuration Changes
- 8872737e chore: updated puppet-realmd module @30c2464d77c3b27ca127eb398c76179c9149876b
- c7c9182d chore: use Obmondo puppet-bind fork due to unmerged upstream security fix

### Other Changes
- 872ca37c Set gitea backup to 5 am
- dd07bd26 Prometheus 3.8.1-1 natively supports agent mode via --agent. Replaced deprecated --enable-feature=agent flag accordingly.
- d935a355 commit hash is not getting updated with script
- dff022df Added the monitor class for slurm for alerts
- 72f63ea7 Fixed the flag
- 000cc8e3 Updated the slurm exporter based on the new upstream exporter

