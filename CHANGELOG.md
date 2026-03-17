# Changelog

All releases and the changes included in them (pulled from git commits added since last release) will be detailed in this file.

## LinuxAid Release Version v1.5.5

### Bug Fixes
- 22bb13b7 fix(security): correct exporter config — timeout, field name, CA

### Configuration Changes
- d4c105d0 chore(fix): changed the response key name, based on latest changes in api

### Other Changes
- ce05f82f Refactor Hiera namespaces to standardize system lookups
- c236ae6b refactor: move profile::certs to profile::system::certs namespace
- ffbe858a Update enableit modules dependencies and metadata
- d3f7bb54 Change disabled_services data values from Hash to Array in hiera file to fix CI
- 3ffa7e9c Remove Redmine module

## LinuxAid Release Version v1.5.4

### Bug Fixes
- 9361696f fix: nil safety for linuxaid_tag in ENC and add ENC documentation
- 53fb30a7 fix: handle linuxaid-tag for branch and tags

### Other Changes
- 349fb9f8 ci: update docstring ci to v0.1.0
- 0d4cc16e refactor: replace common::services::systemd with systemd::unit_file
- c9babc2f Fix typo in openvmtools class name
- 5a819ebf update security exporter to use Vuls server config

## LinuxAid Release Version v1.5.3

### Bug Fixes
- 9747c6f1 fix: remove cron_jobs param since it's not being referenced anywhere
- 39622c49 fix: skip rsyslog if facter is unset
- 2e7974dc fix(haproxy): gate HAProxy 3.x to Ubuntu 24.04+ only
- edb97336 fix: replace dummy cert creation with snake oil

## LinuxAid Release Version v1.5.2

### Features
- 52de8329 feat(pgsql): add support for scram-sha-256 in pg_hba type
- 5b82a076 feat: add memory, processors, and network_primary_ip facts to e2e agents
- 9747bc3a feat: enable full_host_management globally, monitor per-agent, and simplify catalog-diff
- b13b1fed feat: improve e2e catalog-diff with JSON output formatting

### Bug Fixes
- bc855963 fix: add early return to all exporter classes when disabled
- 44cb6a4b fix: skip dellhw exporter class when disabled to avoid missing service reference
- dbca9b35 fix: use correct timer unit names for dnf service masking on RedHat
- ba9f032d fix: use facts-based init_style in all prometheus exporters
- d58927ba fix: treat octocatalog-diff exit code 2 as success in CI
- ede10753 fix: add grub parameter types for type safety
- cd981e21 fix: add missing e2e facts for ubuntu2404 motd template
- 846c3399 fix: resolve puppet catalog compilation errors
- 165d4e85 fix: update common::system class list and remove duplicate services block
- 8ebe709c fix: move tmux and bash files from convenience/ to system/utility/
- 1e7ebc87 fix: e2e agent grub parameters use hash format with ensure/value keys
- d19907e7 fix: e2e catalog-diff - rename certnames to .e2etesting and add missing facts
- e2ed82cd fix: added the certname key at the ENC level, so we dont have to read from the fact
- a35a0aec fix: removed the extra test certname
- ec809ab1 fix: handle linuxaid tag nil check in puppet enc
- 6e4e6d5b fix: profile::system is not anymore, the underlying class is handled in the common module
- 2c8ebbff fix(lint): resolve autoloader_layout errors and introduce profile::collector namespace
- 21b35d6d fix: we dont need to notify, cause update and run-openvox are cron, which does not need to be notified again and again
- 389a1d9b fix: lets all the subclass noop value set to undef as a default, and let it overwritten by the resource/upstream class calling it
- 3fff899e fix: moved profile openvox to profile system openvox
- e02f81a9 fix: changed the hiera key in the release script, so it udpates the hiera with the new tag
- 9c9522fe fix: removed groups from 3rd layer in common module
- e2a46a74 fix: removed the services, and migrated to upstream systemd module and removed deprecated initstyle
- 41b91c95 fix: moved the mysql code from db class to db::mysql
- 5a1208a0 fix: removed the obsolete elk role, since we already have elasticsearch db role, and moved the logging role for journald remote under monitor group
- d455d37d fix: moved to monitor from monitoring in common class
- 3f72352b fix: removed virtualization class and moved the openvmtools into software and the required changes as per the structure
- 8a9a6c92 fix: moved the common::systemd::timer to functions::systemd_timer

### Configuration Changes
- 959dc786 chore: added puppet-puppetlabs-yumrepo_core module v3.0.1
- 15db223c chore: remove unused empty upstream modules
- d1676e70 chore(fix): moved from user_security to user_management
- 17248f24 chore(doc): puppet string doc fixes
- c1071251 chore(lint): fix
- 507ec046 chore(fix): changed the class name as per new structure for openvox and obmondo_admin
- eaec0a3b chore: removed **extras** layer in common and moved it into software chore: moved the security into system layer in common
- 69988a48 chore: removed the common::devices, since its obsolete
- f4960f61 chore: removed unused mkdir_pp function
- 51b343db chore(doc): Update changelog

### Other Changes
- a10de4fd docs: add OpenVAS (Greenbone) setup and usage guide
- 1d35b34c Split e2e catalog-diff CI jobs by role for visual grouping
- 45d5683d Add eyaml support to e2e catalog-diff
- 9e137f7e Add e2e catalog-diff CI with Docker container jobs
- 0e7be4be Add Docker-based octocatalog-diff setup for CI catalog diffing
- d19c7195 Fix: use splunkfwd user for SplunkForwarder service management because /opt/splunkforwarder is owned by splunkfwd
- 65e5cecd rotate slurmd logs only hourly base and maxsize to 1G
- 4c3669a7 remove comment from monitor/types/*
- 1a9c0873 Replace . with _ in environment
- 48ded0fe Refactor common class: move mail, jumphost, and service management
- 17d035fd Fixed the class names
- e14124a7 common::convenience was changed to common::system::utilities
- 4a00ee8c common::cron is now common::system::cron
- 39ee8f3d refactor: remove profile::system inheritance and reorganize defaults
- 59283a08 refactor: reorganize manifest namespacing to reflect module groupings
- 7ae19336 breaking changes: moved all the hiera key as per current structure and changed the structure as well in the common module
- 2f135345 breaking fix: moved the selinux into system::security
- a8722307 breaking: moved the whole common module structure into layered structure based on UX we decided internally by Obmondo
- c590084e moved the profile mysql to profile::db::mysql
- 7c18fd3c Rotate slurm hours every hour and when it reaches 1GB
- beadce6c Set Puppet ENC environment from linuxaid_tag

## LinuxAid Release Version v1.5.1

No changes in this release.
## LinuxAid Release Version v1.5.1

### Features
- b9195d47 feat: add acme support for haproxy 3
- bd16f65f feat: add haproxy 3

### Bug Fixes
- 1e32716a fix: auto-enable native ACME for 3.x on Noble and add ACME CA/timer flow with other fixes
- 04cd9c2b fix: address lint issues for puppet strings docs
- 463d539f fix: handle immediate scheduling of certificate renewals
- 32a26417 fix: handle rejected domains in the Native acme monitoring loop
- af20c7ac fix: address the formatting lint issues
- 09f48dec fix: handle configuration conflict and the unintended certbot execution
- 5f141b7e fix: write the automated renewed certificates from memory to disk via cron script
- 6e7ddfa8 fix: handle certificate issuing for multiple group of domains
- 4fa62a38 fix: handle unknown service name error for haproxy challenge response
- e8782a71 fix: remove dependency on extra variables for version and use the existing one
- b70f4fe7 fix: handle setting config version when a git directory for a repo exists
- b1b6f21f fix extra_options parameter while passing undef
- c4f72e72 fix: remove unwanted 'main' component from kubernetes apt repo

### Other Changes
- c9981f7e Fixed the logrotate rule
- 8e4bc737 Rotate slurmd logs

## LinuxAid Release Version v1.4.9

### Bug Fixes
- 4922c379b fix: ensures creation of log directory before installing netbird for openwrt systems
- 5c1b97a0d fix: handle non existence of extra opts in haproxy configs

### Configuration Changes
- 60df9a13b chore: update netbird client version and checksum to v0.65.1
- a3878e616 chore: set the hostname via env var when installing netbird

### Other Changes
- 858e5a73b Revert "Merge pull request 'Add --volumes to Docker system prune cron job to clean unused volumes' (#1456) from volumes into master"

## LinuxAid Release Version v1.4.9

### Bug Fixes
- 4922c379b fix: ensures creation of log directory before installing netbird for openwrt systems
- 5c1b97a0d fix: handle non existence of extra opts in haproxy configs

### Configuration Changes
- 60df9a13b chore: update netbird client version and checksum to v0.65.1
- a3878e616 chore: set the hostname via env var when installing netbird

### Other Changes
- 858e5a73b Revert "Merge pull request 'Add --volumes to Docker system prune cron job to clean unused volumes' (#1456) from volumes into master"

## LinuxAid Release Version v1.4.8

### Bug Fixes
- fc74c59d fix: apache vhost can have any string, but the underlying domains needs to be fqdn, since its useful incase the entry is common in tags hiera

## LinuxAid Release Version v1.4.7

### Bug Fixes
- be75e8f7 fix: underlying profile input data type were too broad, so limited those to fqdn input only and added domain monitoring for phpfpm role

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

