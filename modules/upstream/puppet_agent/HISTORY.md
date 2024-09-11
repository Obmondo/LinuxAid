## [v4.14.0] - 2023-04-28

### Summary

Add support for Puppet 8.

### Features

- (PA-5336) Update tests and tasks for puppet8 ([#650](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/650))

## [v4.13.0] - 2023-03-21

### Summary

Add support for Puppet 8 nightlies, additional platform support, new features for run task/plan and install task.

### Features

- Add support for absolute_source in puppet_agent::install task ([#484](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/484))
- (FM-8969) Add support for macOS 12 ARM ([#615](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/615))
- Support for Linux Mint 21 ([#616](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/616))
- (FM-8983) Add Fedora 36 ([#619](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/619))
- run task/plan: Allow noop and environment option ([#632](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/632/))
- (MODULES-11361) Puppet 8 compatibility work ([#636](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/636))

## [v4.12.1] - 2022-07-13

### Summary

Bug fix release.

### Bug Fixes

- Unnest module and class names in Ruby tasks ([#613](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/613))

## [v4.12.0] - 2022-07-13

### Summary

Add support for Ubuntu 22.04, Debian 11, Red Hat Enterprise Linux 9, and Fedora 34. Handle TLS 1.2 on older Windows systems.
### Features

- ([FM-8943](https://tickets.puppetlabs.com/browse/FM-8943)) Add Ubuntu 22.04 support. ([#610](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/610))
- Add support for Debian 11, Red Hat Enterprise Linux 9, and Fedora 34. ([#607](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/607))

### Bug Fixes

- ([MODULES-11334](https://tickets.puppetlabs.com/browse/MODULES-11334)) Handle TLS 1.2 on older Windows systems. ([#611](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/611))

## [v4.11.0] - 2022-05-13

### Summary

Add support for macOS 12. Allow module to function properly if there is a discrepancy between the AIO puppet-agent and Puppet versions.

### Features

- Add additional configuration options for puppet.conf ([#602](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/602))

### Bug Fixes

- ([MODULES-11315](https://tickets.puppetlabs.com/browse/MODULES-11315)) Allow module to function properly if there is a discrepancy between the AIO puppet-agent and Puppet versions. ([#604](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/604))
- ([MODULES-11262](https://tickets.puppetlabs.com/browse/MODULES-11262)) Fix issue with version check on acceptance upgrade tests. ([#599](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/599))

## [v4.10.0] - 2022-01-26

### Summary

Improve AlmaLinux and Rocky Linux support. Converted this module to be PDK-compliant. Other fixes and improvements

### Features

- ([MODULES-11168](https://tickets.puppetlabs.com/browse/MODULES-11168), [MODULES-11192](https://tickets.puppetlabs.com/browse/MODULES-11192)) Add AlmaLinux and Rocky to the puppet-agent module ([#582](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/582), [#583](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/583))
- ([MODULES-11244](https://tickets.puppetlabs.com/browse/MODULES-11244)) Convert puppet_agent module to PDK ([#588](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/588))
- Allow detection of non-AIO Ppuppet ([#581](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/581))
- Add additional configuration options for puppet.conf ([#584](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/584))

### Bug fixes

- ([MODULES-11214](https://tickets.puppetlabs.com/browse/MODULES-11214)) Fix wrong URL generated for macOS 11 ([#586](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/586))

### Acknowledgements

Thanks to [smortex](https://github.com/smortex) and [Heidistein](https://github.com/Heidistein) who have contributed to this release 🎉!

## [4.9.0] - 2021-09-09

### Summary
Add Debian 11 support. Add Rocky Linux support for the `install` task. Allow `present` and `latest` as `package_version`. Other fixes and improvements.

### Features

- ([MODULES-11085](https://tickets.puppetlabs.com/browse/MODULES-11085)) Add Fedora 34 support to module ([#564](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/564))
- Update GPG-KEY-puppet ([#579](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/579))
- Allow stdlib 8.0.0 ([#576](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/576))
- ([MODULES-11060](https://tickets.puppetlabs.com/browse/MODULES-11060)) Add Debian 11 to puppet_agent module ([#575](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/575))
- ([MODULES-11148](https://tickets.puppetlabs.com/browse/MODULES-11148)) Document Windows long paths support ([#573](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/573))
- Update readme for clarification on Windows agent updates ([#502](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/502))
- ([MODULES-11113](https://tickets.puppetlabs.com/browse/MODULES-11113)) Allow present and latest as package version ([#565](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/565))
- ([MODULES-11135](https://tickets.puppetlabs.com/browse/MODULES-11135)) Add Rocky as EL platform in task install_shell.sh ([#571](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/571))
- ([MODULES-11078](https://tickets.puppetlabs.com/browse/MODULES-11078)) Bump Bolt to 3.x ([#566](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/566))
- ([MODULES-11112](https://tickets.puppetlabs.com/browse/MODULES-11112)) Add parameter puppet_agent::proxy ([#567](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/567))


### Bug fixes

- ([MODULES-11123](https://tickets.puppetlabs.com/browse/MODULES-11123)) Avoid loading puppet facts in `install/windows.pp` ([#577](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/577))
- ([MODULES-11077](https://tickets.puppetlabs.com/browse/MODULES-11077)) Allow all settings to be managed ([#569](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/569))

### Acknowledgements

Thanks to [smortex](https://github.com/smortex), [murdok5](https://github.com/murdok5), [relearnshuffle](https://github.com/relearnshuffle), [Guillaume001](https://github.com/Guillaume001) and [chrekh](https://github.com/chrekh) who have contributed to this release 🎉!

## [4.8.0] - 2021-06-22

### Summary
Add Fedora 34 support to module. Add macOS 11 support to `install` task. Fix `facts_diff` task argument parsing on Windows.

### Features

- ([MODULES-11085](https://tickets.puppetlabs.com/browse/MODULES-11085)) Add Fedora 34 support to module ([#564](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/564))
- ([PE-31118](https://tickets.puppetlabs.com/browse/PE-31118)) Add macOS 11 support to `install` task ([#560](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/560))

### Bug fixes

- ([MODULES-11074](https://tickets.puppetlabs.com/browse/MODULES-11074)) Fix `facts_diff` task argument parsing on Windows ([#561](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/561))

## [4.7.0] - 2021-05-12

### Summary
Support running `puppet_agent::install` task in no-operation mode.

### Features

- ([MODULES-11066](https://tickets.puppetlabs.com/browse/MODULES-11066)) Support running `puppet_agent::install` task in no-operation mode ([#559](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/559))

## [4.6.1] - 2021-04-27

### Summary
Fix upgrades when files from /tmp directory cannot be executed

### Bug fixes

- ([MODULES-11057](https://tickets.puppetlabs.com/browse/MODULES-11057)) Do not use /tmp directory for executables ([#557](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/557))

## [4.6.0] - 2021-04-22

### Summary
Fix PE upgrades for SLES 11 and improve GPG key checks. Remove puppet5 task support. Add `exclude` flag to `puppet facts diff` and add task to remove local filebucket cache.

### Features

- ([MODULES-10987](https://tickets.puppetlabs.com/browse/MODULES-10987)) Add Fedora32 support to puppet_agent module ([#548](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/548))
- ([MODULES-11045](https://tickets.puppetlabs.com/browse/MODULES-11045)) add `exclude` parameter to `facts_diff` task ([#552](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/552))
- ([MODULES-11048](https://tickets.puppetlabs.com/browse/MODULES-11048)) task to remove local filebucket ([#550](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/550))

### Bug fixes

- ([MODULES-10996](https://tickets.puppetlabs.com/browse/MODULES-10996)) Fix SLES 11 PE upgrades and improve GPG key check ([#551](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/551))

### Removals

- ([MODULES-10989](https://tickets.puppetlabs.com/browse/MODULES-10989)) Remove puppet5 collection from puppet_agent::install task ([#549](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/549))

## [4.5.0] - 2021-03-23

### Summary
The module can now manage agent configuration. Various Windows fixes and additions, task updates.

### Features

- ([MODULES-10879](https://tickets.puppetlabs.com/browse/MODULES-10879)) Implement configuration management ([#525](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/525))
- ([MODULES-10909](https://tickets.puppetlabs.com/browse/MODULES-10909)) Retry task commands in case of network connectivity failures ([#536](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/536))
- ([MODULES-9798](https://tickets.puppetlabs.com/browse/MODULES-9798)) Add timeout parameter for current Puppet run ([#537](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/537))
- Ignore unneeded paths when packaging the module ([#540](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/540))
- ([MODULES-10925](https://tickets.puppetlabs.com/browse/MODULES-10925)) Add facts_diff task ([#542](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/542))

### Bug fixes

- Update puppet-20250406 GPG key ([#538](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/538))
- Fix upgrading Puppet on Windows ([#539](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/539))

### Acknowledgements

Thanks to [smortex](https://github.com/smortex) and [phil4business](https://github.com/phil4business) who have contributed to this release 🎉!

## [4.4.0] - 2021-01-20

### Summary
Add the new GPG signing key and default to puppet 7 for PE 2021.0.

### Features

- ([MODULES-10910](https://tickets.puppetlabs.com/browse/MODULES-10910)) Default to puppet 7 for PE 2021.0 ([#529](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/529))
- ([MODULES-10897](https://tickets.puppetlabs.com/browse/MODULES-10897)) Add new GPG signing key and remove the old one ([#532](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/532))

### Bug fixes

- Speed up unit tests by bumping apt dependency to 7.4.2 ([#531](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/531))

## [4.3.0] - 2020-12-14

### Summary
Task support for puppet7 collection. Use correct AIX packages when upgrading.

### Features

- ([MODULES-10873](https://tickets.puppetlabs.com/browse/MODULES-10873)) Add support for puppet7 collection ([#524](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/524))

### Bug fixes

- ([MODULES-10878](https://tickets.puppetlabs.com/browse/MODULES-10878)) Use correct packages when upgrading AIX ([#527](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/527))

## [4.2.0] - 2020-10-30

### Summary
Various Windows fixes and additions to facilitate upgrading to Puppet 7.

The fixes for ([MODULES-10850](https://tickets.puppetlabs.com/browse/MODULES-10850)) and ([MODULES-10851](https://tickets.puppetlabs.com/browse/MODULES-10851)) do not affect any released version of the module, but are still included in the changelog.

### Features

- ([MODULES-10799](https://tickets.puppetlabs.com/browse/MODULES-10799)) Ensure upgradability to Puppet 7 when remote filebuckets are enabled ([#511](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/511))

### Bug fixes

- ([MODULES-10813](https://tickets.puppetlabs.com/browse/MODULES-10813)) Mismatched versions stops install on Windows ([#512](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/512))
- ([MODULES-10818](https://tickets.puppetlabs.com/browse/MODULES-10818)) Ignore `msi_move_locked_files` on newer puppet versions ([#515](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/515))
- ([MODULES-10850](https://tickets.puppetlabs.com/browse/MODULES-10850)) Determine `PSScriptRoot` if it does not exist ([#519](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/519))
- ([MODULES-10851](https://tickets.puppetlabs.com/browse/MODULES-10851)) Fix Windows nightly prerequisites check ([#520](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/520))

## [4.1.0] - 2020-08-19

### Summary
Add support for Linux Mint 20, and add puppet agent run plan to run the agent against remote
targets.

### Features

- Support for Linux Mint 20, LDME 4 ([#500](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/500))
- ([MODULES-10739](https://tickets.puppetlabs.com/browse/MODULES-10739)) add task support for
  puppet7-nightly ([#501](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/501))
- ([MODULES-10768](https://tickets.puppetlabs.com/browse/MODULES-10768)) Add task and plan for
  running the Puppet agent ([#503](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/503))

### Bug fixes

- ([MODULES-10713](https://tickets.puppetlabs.com/browse/MODULES-10713)) Fix agent upgrade on Solaris 11 ([#499](https://github.com/puppetlabs/puppetlabs-puppet_agent/pulls/499))

## [4.0.0] - 2020-06-15

### Summary
Stop agent run after upgrade. Fix `absolute_source` on RPM platforms. Update `puppetlabs-facts` dependency. Do not allow install task to upgrade Windows agents if services are still running.

### Features
- ([MODULES-10673](https://tickets.puppetlabs.com/browse/MODULES-10673)) Update dependency for puppetlabs-facts ([#495](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/495))

### Bug fixes
- ([MODULES-10653](https://tickets.puppetlabs.com/browse/MODULES-10653)) Failed to upgrade agent using puppet task ([#494](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/494))
- ([MODULES-10655](https://tickets.puppetlabs.com/browse/MODULES-10655)) Fix up/downgrade of agent to specified version ([#488](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/488))
- ([MODULES-10666](https://tickets.puppetlabs.com/browse/MODULES-10666)) Stop agent run after an upgrade ([#496](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/496))

## [3.2.0] - 2020-05-13

### Summary
Install task can download Ubuntu 20.04. Fixed mcollective being included as a default service.

### Features
- Allow install task to download puppet-agent for Ubuntu 20.04 ([#491](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/491))

### Bug fixes
- Fix mcollective being included as a default service to manage in client version >= 6.0.0 ([#485](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/485))

## [3.1.0] - 2020-04-02

### Summary
Update `puppetlabs-inifile` dependency. Install task can download macOS 10.15.
Windows FIPS. Pidlock, puppet.list config and root check fixes for
`install_shell` task.

### Features
- Update inifile dependency to allow all 4.x versions ([#477](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/477))
- Allow install task to downlad macOS 10.15 ([#471](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/471))

### Bug fixes
- Fix windowsfips upgrades ([MODULES-10606](https://tickets.puppetlabs.com/browse/MODULES-10606))
- Remove pidlock if service states cannot be restored ([MODULES-10594](https://tickets.puppetlabs.com/browse/MODULES-10594))
- Exit early when puppet.list config file has been modified ([MODULES-10589](https://tickets.puppetlabs.com/browse/MODULES-10589))
- Check that user is root only if installation is required ([#475](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/475))

## [3.0.2] - 2020-02-14

### Summary
Remove config from `bolt_plugin.json`.

### Bug fixes
- Removed unsupported `config` field from the `bolt_plugin.json` file.([#469](https://github.com/puppetlabs/puppetlabs-puppet_agent/pull/469))

## [3.0.1] - 2020-01-28

### Summary
Fix `install_powershell` task for Powershell < 3.0.

### Bug fixes
- Fixed `install_powershell` task failure when using Powershell < 3.0 ([MODULES-10514](https://tickets.puppetlabs.com/browse/MODULES-10514))

## [3.0.0] - 2020-01-24

### Summary
Assume latest version of the puppet-agent package only when no version is specified and the puppet-agent package is not installed (`puppet_agent::install` task).

## [2.2.3] - 2019-12-10

### Summary
Support for Fedora 31, Windows FIPS. WaitForExit can be parameterized. Fix for downgrades using apt.

### Features
- Fedora 31 support ([MODULES-10238](https://tickets.puppetlabs.com/browse/MODULES-10238) 
- Windows FIPS support ([MODULES-10043](https://tickets.puppetlabs.com/browse/MODULES-10043))
- WaitForExit for PXP agent can now be parameterized ([MODULES-10052](https://tickets.puppetlabs.com/browse/MODULES-10052)

### Bug fixes
- Improve error message when install task could not download puppet-agent package ([MODULES-10067](https://tickets.puppetlabs.com/browse/MODULES-10067)
- Fixed lint warnings ([MODULES-10055](https://tickets.puppetlabs.com/browse/MODULES-10055)

## [2.2.2] - 2019-11-7

### Summary
Support for puppet nightly collection on Windows(puppet_agent::install task).

### Features
- Puppet Agent module downloads the wrong nightly builds for Windows ([MODULES-10038](https://tickets.puppetlabs.com/browse/MODULES-10038))

## [2.2.1] - 2019-10-21

### Summary
Support for Debian 10, Linux Mint, Amazon Linux 2. Stop puppet agent service after install. Puppet_agent task as a plugin.

### Features
- Debian 10 amd64 support
- Linux Mint Support
- Amazon Linux 2 support ([MODULES-9981](https://tickets.puppetlabs.com/browse/MODULES-9981))
- Update facts module used for testing install task ([MODULES-9698](https://tickets.puppetlabs.com/browse/MODULES-9698))
- Add option to stop the puppet agent service after install ([GH-1204](https://tickets.puppetlabs.com/browse/GH-1204))
- Added task to check commit messages
- Make the puppet_agent task available as a plugin

### Bug fixes
- Failed puppet agent upgrade prevents future upgrading because of locked .pid file ([MODULES-9497](https://tickets.puppetlabs.com/browse/MODULES-9497)
- Update bash implementation metadata to require facts implementation
- Add bolt team as codeowners 
- Cached Catalog on Windows not idempotent ([MODULES-9846](https://tickets.puppetlabs.com/browse/MODULES-9846))
- Fix failing tests due to rspec changes

## [2.2.0] - 2019-08-05

### Summary
Autodetect package_version for compiling master. Fedora 30 support. Upgrade to Beaker 4. Handle mcollective service restarts on agent upgrades.

### Features
- autodetect package_version based upon the compiling master ([MODULES-8923](https://tickets.puppetlabs.com/browse/MODULES-8923))
- Fedora 30 support
- Handle mcollective service restarts on agent upgrades ([MODULES-9173](https://tickets.puppetlabs.com/browse/MODULES-9173))
- Migrate puppet_agent module to Beaker 4 ([MODULES-9444](https://tickets.puppetlabs.com/browse/MODULES-9444))
- Support upgrade of RedHat Satellite puppet agent packages ([MODULES-7760](https://tickets.puppetlabs.com/browse/MODULES-7760))

### Bug fixes
- Missing puppetlabs-facts dependency for the install task([MODULES-8665](https://tickets.puppetlabs.com/browse/MODULES-8665))

## [2.1.2] - 2019-05-13

### Summary
Update for the URLs used to retrieve Puppet Agent. Fix for using the modules in a non PE Environment

### Bug fixes
- The Puppet Agent artifacts are now retrieved from *.puppet.com instead of *.puppetlabs.com ([RE-12326](https://tickets.puppetlabs.com/browse/RE-12326))
- set PC1 as the default Puppet Agent repository

## [2.1.1] - 2019-03-28

### Summary
Quick fix release for windows environment issue

### Bug fixes
- Update installation .ps1 script to force environment to production when executing "puppet config" ([MODULES-8821](https://tickets.puppetlabs.com/browse/MODULES-8821))

## [2.1.0] - 2019-03-26

### Summary
New parameters for managing package sources to allow for targeting mirrors. SLES and MacOS support for open-source installs. Better service management for windows installations

### Features
- Added SLES support for open-source installations ([MODULES-8598](https://tickets.puppetlabs.com/browse/MODULES-8598))
- Added MacOS support for open-source installations ([MODULES-8599](https://tickets.puppetlabs.com/browse/MODULES-8599))
- Error reporting for windows background upgrades ([MODULES-8554](https://tickets.puppetlabs.com/browse/MODULES-8554))
- New source parameters for managing alternate sources (like mirrors) ([MODULES-6604](https://tickets.puppetlabs.com/browse/MODULES-6604))

### Bug fixes
- Fix inherited permissions exec resource on windows ([MODULES-8406](https://tickets.puppetlabs.com/browse/MODULES-8406))
- Fix service management for puppet > 6 ([MODULES-8319](https://tickets.puppetlabs.com/browse/MODULES-8319))
- No longer passing environment for windows installations ([MODULES-4730](https://tickets.puppetlabs.com/browse/MODULES-4730))
- Fix rpm import of gpg keys for newer SLES ([MODULES-8583](https://tickets.puppetlabs.com/browse/MODULES-8583))
- Wait on any hanging pxp-agent processes in windows installations ([FM-7628](https://tickets.puppetlabs.com/browse/FM-7628))
- Update parameters to use 'server_list' when provided rather than the 'server' setting
- Update windows installations to always run service management outside of the initial puppet run (i.e. restart any services after the upgrade without using puppet)

## [2.0.1] - 2019-01-17

### Summary
New Installation tasks using [Bolt](https://github.com/puppetlabs/bolt), Updated module deps, Migration from
batch to powershell for windows upgrades

### Features
- Bolt task installations
- Updated module dependencies
- Powershell scripts for Windows upgrades

### Bug fixes
- Windows installations now recover service state on failed upgrades

## [1.7.0] - 2018-09-18

### Summary
Bugfix and compatibility update for Puppet 6

### Features
- Support for changes to Fedora package naming in Puppet 5 and 6
- Refactor OSX upgrades to be like Solaris and Windows, using an external script

## [1.6.2] - 2018-07-26

### Summary
Compatibility update for PE packaging changes

### Features
- Support for new pe_repo tarballs that use repo names matching open source.

## [1.6.1] - 2018-06-29

### Summary
Minor bugfix release

### Features
- Add Ubuntu 18.04 support
- Add skip_if_unavailable to yumrepo resource ([MODULES-4424](https://tickets.puppetlabs.com/browse/MODULES-4424))

### Bug fixes
- Do not manage PA version on PE infra nodes ([MODULES-5230](https://tickets.puppetlabs.com/browse/MODULES-5230))
- Fix update failure for FIPS ([MODULES-7329](https://tickets.puppetlabs.com/browse/MODULES-7329))

## [1.6.0] - 2018-03-21

### Summary
This is the last release that will support Puppet 3.x

### Features
- Make management of /etc/pki directory optional ([MODULES-6068](https://tickets.puppetlabs.com/browse/MODULES-6068))
- OSX 10.13 is now supported
- RHEL 7 AArch64 is now supported

### Bug fixes
- Fix version tag on Amazon Linux ([MODULES-5637](https://tickets.puppetlabs.com/browse/MODULES-5637))
- Stop all services prior to upgrading on Windows ([PE-23563](https://tickets.puppetlabs.com/browse/PE-23563))
- Output token privileges for current user on Windows
- Update testing matrix
- Pin resources for Puppet 3.x compatibility ([MODULES-6708](https://tickets.puppetlabs.com/browse/MODULES-6708), [MODULES-6717](https://tickets.puppetlabs.com/browse/MODULES-6717))
- Pin rspec-puppet to 2.6 due to bug in rspec-puppet ([MODULES-6717](https://tickets.puppetlabs.com/browse/MODULES-6717))

## [1.5.0] - 2017-11-29

### Summary
This is a feature and bug-fix release

### Features
- Add ability to manage the `stringify_facts` setting ([MODULES-5953](https://tickets.puppetlabs.com/browse/MODULES-5953))
- Upgrades to Puppet 5 are now supported on RPM-based platform ([MODULES-5633](https://tickets.puppetlabs.com/browse/MODULES-5633))
- Debian 9 is now supported

### Bug fixes
- Solaris 10 upgrades now work for Puppet Enterprise 2017.3 ([MODULES-5942](https://tickets.puppetlabs.com/browse/MODULES-5942)) and ([MODULES-3787](https://tickets.puppetlabs.com/browse/MODULES-3787))
- AIX upgrades now work for Puppet Enterprise 2017.3 ([MODULES-5979](https://tickets.puppetlabs.com/browse/MODULES-5979))
- Downgrading the agent on Windows no longer breaks the installation ([MODULES-5622](https://tickets.puppetlabs.com/browse/MODULES-5622))

## [1.4.1] - 2017-07-27

### Summary
This is a bug-fix release

### Bug fixes
- The system package provider is explicitly selected on Solaris 10 for installing puppet-agent ([MODULES-4547](https://tickets.puppetlabs.com/browse/MODULES-4547))
- `puppet lookup` and other operations with `strict_variables` enabled will now work with this module ([MODULES-5168](https://tickets.puppetlabs.com/browse/MODULES-5168))
- Use HTTP instead of HTTPS for RedHat repositories. This is consistent with Puppet's repo packages, and continues to use GPG signing for security.

## [1.4.0] - 2017-06-12

### Summary
This is a feature and bug-fix release

## Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Features
- AIX 7.2 agents can now be upgraded ([PA-1160](https://tickets.puppetlabs.com/browse/PA-1160))

### Bug fixes
- Fix a race condition when upgrading agents on certain platforms ([MODULES-4732](https://tickets.puppetlabs.com/browse/MODULES-4732))
- Avoid duplicate GPG imports on RPM-based systems ([MODULE-4478](https://tickets.puppetlabs.com/browse/MODULES-4478))
- Silence some redundant notices on Debian-based systems ([MODULES-4171](https://tickets.puppetlabs.com/browse/MODULES-4171))
- Avoid the new to fetch GPG keys from the internet ([MODULES-4521](https://tickets.puppetlabs.com/browse/MODULES-4521))

## [1.3.2] - 2017-02-09

### Summary
This is a bug-fix release

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Bug fixes
- Service management wasn't always applied when intended ([MODULES-3994](https://tickets.puppetlabs.com/browse/MODULES-3994))
- Allow setting MSI installation parameters on Windows ([MODULES-4214](https://tickets.puppetlabs.com/browse/MODULES-4214))
- Ensure all variables are populated to prevent failures when STRICT_VARIABLES='yes'
- Only update server.cfg if not already managed by PE
- Enable the puppet service on Windows if service param includes it ([MODULES-4243](https://tickets.puppetlabs.com/browse/MODULES-4243))
- Add custom fact puppet_agent_appdata, as common_appdata was only defined in PE ([MODULES-4241](https://tickets.puppetlabs.com/browse/MODULES-4241))
- Use getvar to fix facts to work with the strict_variables setting ([MODULES-3710](https://tickets.puppetlabs.com/browse/MODULES-3710))
- Optionally move puppetres.dll on Windows upgrade ([MODULES-4207](https://tickets.puppetlabs.com/browse/MODULES-4207))
- Allow disabling proxy settings for yum repo ([MODULES-4236](https://tickets.puppetlabs.com/browse/MODULES-4236))

## [1.3.1] - 2016-11-17

### Summary
This is a bug-fix release

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Bug fixes
- Fix upgrading a global Solaris zone would break upgrading other zones ([MODULES-4092](https://tickets.puppetlabs.com/browse/MODULES-4092))
- Fix line endings of `install_puppet.bat`
- Fix upgrading between releases of the same package version ([MODULES-4030](https://tickets.puppetlabs.com/browse/MODULES-4030))

## [1.3.0] - 2016-10-19

### Summary
The addition of several OS support features and a considerable amount of compatibility and bug fixes.

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Mac OS X Open Source package upgrades are not yet implemented.

### Features
- Add support for Ubuntu 16.04 and Fedora 23
- Allow MSI install path to be defined on Windows ([MODULES-3571](https://tickets.puppetlabs.com/browse/MODULES-3571))
- Allow agent upgrade on non-English versions for Windows ([MODULES-3636](https://tickets.puppetlabs.com/browse/MODULES-3636))
- Allow the use of a hosted repository for packages ([MODULES-3872](https://tickets.puppetlabs.com/browse/MODULES-3872))
- Remove POWER8 restriction for AIX ([MODULES-3912](https://tickets.puppetlabs.com/browse/MODULES-3912))

### Bug fixes
- Fix upgrade process on Windows using a PID file ([MODULES-3433](https://tickets.puppetlabs.com/browse/MODULES-3433))
- Fix metadata to indicate support for Puppet 3.7
- Fix upgrade process on Windows by stopping PXP service ([MODULES-3449](https://tickets.puppetlabs.com/browse/MODULES-3449))
- Add extra logging during upgrade process on Windows
- Disable SSL verification on Xenial ([PE-16317](https://tickets.puppetlabs.com/browse/PE-16317))
- Fix preserving the environment name when upgrading on Windows ([MODULES-3517](https://tickets.puppetlabs.com/browse/MODULES-3517))
- Puppet run will fail if `stringify_facts` is set to `true` ([MODULES-3591](https://tickets.puppetlabs.com/browse/MODULES-3591) [MODULES-3951](https://tickets.puppetlabs.com/browse/MODULES-3951))
- Fix infinite loop scenario on Windows during upgrade ([MODULES-3434](https://tickets.puppetlabs.com/browse/MODULES-3434))
- Fix the waiting process on Windows during an upgrade ([MODULES-3657](https://tickets.puppetlabs.com/browse/MODULES-3657))
- Fix duplicate resource error on AIX with PE ([MODULES-3893](https://tickets.puppetlabs.com/browse/MODULES-3893))
- Fix minor errors in `RakeFile` and `spec_helper_acceptance`
- Fix setting permissions on Windows package
- Update GPG Keys ([RE-7976](https://tickets.puppetlabs.com/browse/RE-7976))
- Fix puppet-agent suffix on Fedora ([PE-16317](https://tickets.puppetlabs.com/browse/PE-16317))
- Fix `unless` condition on SUSE and RedHat GPG key imports ([MODULES-3894](https://tickets.puppetlabs.com/browse/MODULES-3894))
- Avoid `Unknown variable` errors in Puppet 4 ([MODULES-3896](https://tickets.puppetlabs.com/browse/MODULES-3896))
- Fix logic for detecting Solaris 11 package name ([PE-17663](https://tickets.puppetlabs.com/browse/PE-17663))
- Fix spec test fixtures to use the Forge
- Add Windows examples to README
- Fix acceptance tests ignoring resource errors ([MODULES-3953](https://tickets.puppetlabs.com/browse/MODULES-3953))
- Add acceptance tests for `manage_repo` parameter ([MODULES-3872](https://tickets.puppetlabs.com/browse/MODULES-3872))
- Fix Windows package download URL ([MODULES-3970](https://tickets.puppetlabs.com/browse/MODULES-3970))

## [1.2.0] - 2016-05-04

### Summary
Supports upgrades from puppet-agent packages! Applies to both PE and FOSS, for example upgrades from
PE 2015.3.2 to 2015.3.3 and puppet-agent 1.3.0 to 1.4.0 are supported. Upgrading from older Puppet 3
versions is also no longer explicitly prevented. Adds support for Solaris 11.

### Known issues
Carried-over from prior releases:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- Upgrades on EL4-based systems are not supported.
- Upgrades on Fedora systems are not supported.

Newly identified issues:
- Mac OS X Open Source package upgrades are not yet implemented.
- AIX package names are based on PowerPC architecture version. PowerPC 8 is not yet supported.

### Features
- Upgrades between puppet-agent packages, such as 2015.2.x to 2015.3.x.
- Adds support for Solaris 11.
- The `pluginsync` setting was deprecated in `puppet-agent 1.4.0`. This module removes it when upgrading to
that version or later unless otherwise managed.
- Remove the lower-version requirement. All Puppet 3 versions potentially can be upgraded, although
testing is only performed starting with Puppet/PE 3.8. Earlier versions likely work back to 3.5, as long as
the manifest is compiled using 3.7+ with future parser enabled.

### Bug fixes
- Fixes the release identification for Amazon Linux distributions to use EL 6 packages.
- Fix Debian upgrades for PE.
- Support upgrades of 32-bit Windows packages for PE (via pe_repo).
- Fixed an issue that would cause compilation to fail with `Unknown function: 'pe_compiling_server_aio_build'`
in some environments.

## [1.1.0] - 2016-03-01

### Summary
The addition of several OS support features and a considerable amount of compatibility and bug fixes.

### Known issues
While this release adds considerable features and bug fixes the following areas are known issues and require more work:
- For Windows, trigger an agent run after upgrade to get Puppet to create the necessary directory structures.
- There is currently ongoing work to allow for upgrading from 2015.2.x to 2015.3.x.
- Solaris 11 support work is in progess, but currently still buggy.

### Features
- Adds support for SLES 10, Solaris 10, AIX.
- Add OSX 10.9 upgrades.
- Add no-internet Windows upgrade in PE.
- Added puppet_master_server fact.
- Adds `/opt/puppetlabs` to the managed directories.
- Additional test checks for /opt/puppetlabs.

### Bug fixes
- Use rspec expect syntax for catching errors.
- Base master_agent_version on pe_compiling_server_aio_build().
- Update in metadata to include support for SLES 10 and 11.
- Ensure pe-puppet/mcollective services stopped after removing the PUPpuppet and PUPmcollective packages.
- Small readme typo fix.
- Pass in Puppet agent PID as command line parameter to avoid recreating install_puppet.bat at every agent run.
- Allow using the internal mirror when resolving gems.
- Add Solaris 10 sparc to supported arch.
- No longer converts Windows file resource to RAL catalog.
- Create/use local_package_dir in params.pp.
- Fix behavior for non-PE.
- Fix specs for Windows changes.
- Remove check for null $service_names.
- Fix linter errors on Windows PR 66.
- Use common_appdata on Windows.
- Removes management of the puppet/mco services on Windows systems.
- Add start/wait to Windows upgrade.
- Pass in configured server to Windows MSI.
- Fixes SLES11 GPG key import issue.
- Fixed regex for SLES compatibility.
- Ensures local MSI package resource defined on Windows.

## [1.0.0] - 2015-07-28

### Summary

Fixed minor bugs and improved documentation. Now a Puppet Supported module.

### Features
- Improved documentation of upgrade process.

### Bug fixes
- For Windows PE upgrades, by default install the agent version corresponding to the PE master.
- Reset puppet.conf's classfile setting.

## [0.2.0] - 2015-07-21

### Summary

Added support for most systems with both Puppet 3.8 and Puppet-Agent packages released by Puppet Labs.

### Features
- Support for Debian 6/7, Ubuntu 12.04/14.04, SLES 12, and Windows 2003 through 2012R2.

### Bug fixes
- Fix puppet_agent module doesn't touch puppet.conf settings outside an INI section (PUP-4886)
- Made internal classes private, using stdlib's assert_private helper
- Migrate SSL cert directories individually to account for individual settings (PUP-4690)
- Migrated mcollective configuration should prefer the new plugin location (PUP-4658)
- Fixed updating mcollective configuration files with multiple libdir or plugin.yaml definitions (PUP-4746)

## [0.1.0] - 2015-06-02
### Added
- Initial release of puppetlabs-puppet_agent, supporting Redhat and Centos 5/6/7.
