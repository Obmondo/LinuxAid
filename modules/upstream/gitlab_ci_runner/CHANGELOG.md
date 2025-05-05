# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v6.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v6.1.0) (2025-02-11)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v6.0.0...v6.1.0)

**Merged pull requests:**

- puppetlabs/apt: Allow 10.x [\#214](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/214) ([bastelfreak](https://github.com/bastelfreak))

## [v6.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v6.0.0) (2024-11-22)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v5.1.0...v6.0.0)

**Breaking changes:**

- Drop EoL CentOS 8 support [\#204](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/204) ([bastelfreak](https://github.com/bastelfreak))
- Upgrade Github CI and drop RHEL 7-based operating systems [\#193](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/193) ([yakatz](https://github.com/yakatz))
- Drop Debian 10 and Ubuntu 18.04 support [\#191](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/191) ([traylenator](https://github.com/traylenator))
- Use apt keyring on Debian [\#189](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/189) ([jonhattan](https://github.com/jonhattan))

**Implemented enhancements:**

- Enable gpgcheck for YUM  RPM based Distributions [\#205](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/205) ([traylenator](https://github.com/traylenator))
- Add Ubuntu 24.04 support [\#203](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/203) ([bastelfreak](https://github.com/bastelfreak))
- Avoid use of lsb facts [\#200](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/200) ([traylenator](https://github.com/traylenator))
- Add basic SuSE support [\#194](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/194) ([tuxmea](https://github.com/tuxmea))
- register\_to\_file: Support Sensitive `regtoken` [\#164](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/164) ([arusso](https://github.com/arusso))

**Merged pull requests:**

- Respect bolt\_supported from beaker\_helper [\#211](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/211) ([traylenator](https://github.com/traylenator))
- Rename spec files so they run [\#210](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/210) ([traylenator](https://github.com/traylenator))
- doc: clarify requirements for Docker [\#209](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/209) ([kjetilho](https://github.com/kjetilho))

## [v5.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v5.1.0) (2023-12-04)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v5.0.0...v5.1.0)

**Implemented enhancements:**

- Add shutdown\_timeout parameter [\#182](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/182) ([wardhus](https://github.com/wardhus))
- Add Puppet 8 support [\#173](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/173) ([bastelfreak](https://github.com/bastelfreak))

## [v5.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v5.0.0) (2023-10-17)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.4.0...v5.0.0)

**Breaking changes:**

- Replace deprecated ensure\_packages\(\) with stdlib::ensure\_packages\(\) [\#180](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/180) ([bastelfreak](https://github.com/bastelfreak))
- Drop Debian 9 \(EOL\) [\#170](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/170) ([smortex](https://github.com/smortex))
- Drop Puppet 6 support [\#168](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/168) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Replace legacy merge\(\) with native puppet code [\#179](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/179) ([bastelfreak](https://github.com/bastelfreak))
- Add EL9 support [\#175](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/175) ([bastelfreak](https://github.com/bastelfreak))
- Add AlmaLinux/Rocky support [\#174](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/174) ([bastelfreak](https://github.com/bastelfreak))
- Relax dependencies version requirements [\#171](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/171) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Fix broken apt::source declaration for Debian-based systems [\#142](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/142) ([logicminds](https://github.com/logicminds))

**Merged pull requests:**

- .fixtures.yml: Drop puppet 6 leftovers [\#178](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/178) ([bastelfreak](https://github.com/bastelfreak))
- Fix acceptance tests [\#165](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/165) ([smortex](https://github.com/smortex))
- Fix broken Apache-2 license [\#163](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/163) ([bastelfreak](https://github.com/bastelfreak))

## [v4.4.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.4.0) (2022-12-14)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.3.1...v4.4.0)

**Implemented enhancements:**

- Add Ubuntu 22.04 support [\#160](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/160) ([bastelfreak](https://github.com/bastelfreak))
- check for presence of specifed ca\_file [\#159](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/159) ([bastelfreak](https://github.com/bastelfreak))
- Add extra logging when registering/unregistering [\#157](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/157) ([bastelfreak](https://github.com/bastelfreak))
- Allow up-to-date dependencies [\#154](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/154) ([smortex](https://github.com/smortex))
- Add Debian 11 support [\#122](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/122) ([bastelfreak](https://github.com/bastelfreak))

## [v4.3.1](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.3.1) (2022-06-20)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.3.0...v4.3.1)

**Fixed bugs:**

- Ubuntu 18 Puppet 6: Install lsb-release during CI [\#151](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/151) ([bastelfreak](https://github.com/bastelfreak))
- Set ca\_file per runner [\#150](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/150) ([tuxmea](https://github.com/tuxmea))

**Merged pull requests:**

- Remove temp directories in docs [\#143](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/143) ([logicminds](https://github.com/logicminds))
- Fix puppet markup [\#140](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/140) ([smortex](https://github.com/smortex))

## [v4.3.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.3.0) (2022-01-20)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.2.0...v4.3.0)

**Implemented enhancements:**

- Implement support for config file/dir permission management. [\#95](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/95) ([UiP9AV6Y](https://github.com/UiP9AV6Y))

**Merged pull requests:**

- toml gem: apply upstream changes [\#139](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/139) ([bastelfreak](https://github.com/bastelfreak))

## [v4.2.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.2.0) (2021-12-06)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.1.0...v4.2.0)

**Closed issues:**

- Certificate verify failed on update to v4.0.0 [\#124](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/124)

**Merged pull requests:**

- Add `ca_file` parameter for use during registration [\#135](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/135) ([alexjfisher](https://github.com/alexjfisher))

## [v4.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.1.0) (2021-11-04)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Make session\_server section configurable [\#132](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/132) ([baurmatt](https://github.com/baurmatt))

**Merged pull requests:**

- Add puppet-lint-param-docs [\#121](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/121) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.0.0) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v3.0.0...v4.0.0)

Version 4.0.0 is a new major release of this module.  It has many improvements but also significant breaking changes that you should read about and test before deploying into a production environment.  Specifically Puppet 6 is required, your code will probably need updating and existing runners will reregister.

The [README ](https://github.com/voxpupuli/puppet-gitlab_ci_runner/blob/383db3524e7cd3eac13755da251ef1871290f941/README.md#upgrading-from-version-3)has further details.

Huge thanks to all our contributors and especially to [Matthias Baur](https://github.com/baurmatt) for his excellent contributions to this release.

**Breaking changes:**

- Drop RHEL/CentOS 6 and Amazon Linux Support [\#118](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/118)
- Deprecate support for Debian 8 and Ubuntu 16.04 \(and add support for Ubuntu 20.04\) [\#114](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/114) ([alexjfisher](https://github.com/alexjfisher))
- Add support for registration by leveraging a "Deferred" function [\#107](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/107) ([baurmatt](https://github.com/baurmatt))
- Move to concat for config.toml [\#75](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/75) ([baurmatt](https://github.com/baurmatt))

**Implemented enhancements:**

- Support Puppet 7 [\#116](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/116) ([alexjfisher](https://github.com/alexjfisher))
- Add runner registration proxy support [\#109](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/109) ([alexjfisher](https://github.com/alexjfisher))
- Allow `hkp://` style URLs for `repo_keyserver` URL [\#102](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/102) ([hp197](https://github.com/hp197))

**Fixed bugs:**

- Fix runner unregistering [\#111](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/111) ([alexjfisher](https://github.com/alexjfisher))
- Fix unregistering runner with `ensure => absent` [\#110](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/110) ([alexjfisher](https://github.com/alexjfisher))

**Closed issues:**

- Get acceptance tests setup and running [\#20](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/20)

**Merged pull requests:**

- Allow up-to-date dependencies [\#117](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/117) ([smortex](https://github.com/smortex))
- Update README with upgrade information [\#115](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/115) ([alexjfisher](https://github.com/alexjfisher))
- Update module dependencies [\#112](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/112) ([alexjfisher](https://github.com/alexjfisher))
- Fix typos in README.md [\#94](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/94) ([nikitasg](https://github.com/nikitasg))

## [v3.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v3.0.0) (2020-09-15)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v2.1.0...v3.0.0)

**Breaking changes:**

- Make manage\_docker optional and include the docker module if used [\#80](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/80) ([baurmatt](https://github.com/baurmatt))

**Implemented enhancements:**

- Allow management of check\_interval config setting [\#91](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/91) ([tuxmea](https://github.com/tuxmea))
- Add support for CentOS 8, Debian 10 [\#87](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/87) ([dhoppe](https://github.com/dhoppe))

**Merged pull requests:**

- Fix CI problems [\#89](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/89) ([carljohnstone](https://github.com/carljohnstone))
- Switch from Ubuntu Trusty to Ubuntu Focal [\#88](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/88) ([carljohnstone](https://github.com/carljohnstone))
- Use voxpupuli-acceptance [\#83](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/83) ([ekohl](https://github.com/ekohl))

## [v2.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v2.1.0) (2020-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- Use new gitlab gpg keys for package management [\#84](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/84) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- Release new version [\#58](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/58)

## [v2.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v2.0.0) (2020-02-06)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v1.0.0...v2.0.0)

**Breaking changes:**

- Completely refactor gitlab\_ci\_runner::runner [\#74](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/74) ([baurmatt](https://github.com/baurmatt))
- drop Ubuntu support [\#60](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/60) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 2.7.0 and drop puppet 4 [\#39](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/39) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Module should manage build\_dir and cache\_dir [\#33](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/33)
- Add bolt task to register/unregister a runner [\#73](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/73) ([baurmatt](https://github.com/baurmatt))
- Add Amazon Linux support \(RedHat OS Family\) [\#70](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/70) ([bFekete](https://github.com/bFekete))
- Add listen\_address parameter [\#65](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/65) ([baurmatt](https://github.com/baurmatt))
- Add custom repo [\#48](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/48) ([lupintrd](https://github.com/lupintrd))
- Add support for current releases [\#41](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/41) ([dhoppe](https://github.com/dhoppe))
- Fix xz dependency on RedHat systems [\#40](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/40) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Multiple tags in tag-list are ignored only last is respected [\#37](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/37)
- The package `xz-utils` is `xz` on CentOS [\#25](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/25)
- Fix bugs which got introduced by to runner.pp refactoring [\#76](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/76) ([baurmatt](https://github.com/baurmatt))
- Fix runner name in unregister command [\#57](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/57) ([dcasella](https://github.com/dcasella))
-  Use '=' to avoid errors while joining cmd options+values [\#31](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/31) ([ajcollett](https://github.com/ajcollett))

**Closed issues:**

- registration\_token containing undescore gets modified [\#61](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/61)
- /etc/gitlab-runner/config.toml must exist [\#35](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/35)
- Metrics server and Session listen address' [\#26](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/26)

**Merged pull requests:**

- Extract resources out of init.pp [\#72](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/72) ([baurmatt](https://github.com/baurmatt))
- Allow puppetlabs/stdlib 6.x [\#71](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/71) ([dhoppe](https://github.com/dhoppe))
- Switch to puppet-strings for documentation [\#64](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/64) ([baurmatt](https://github.com/baurmatt))
- Use grep with --fixed-strings to avoid issues with some characters in the runner's names [\#63](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/63) ([Farfaday](https://github.com/Farfaday))
- Extend documentation in README with example tags [\#59](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/59) ([jacksgt](https://github.com/jacksgt))
- add limitations about the runner configurations [\#56](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/56) ([thde](https://github.com/thde))
- ensure config exists [\#53](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/53) ([thde](https://github.com/thde))
- Added suport for configuring sentry\_dsn [\#44](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/44) ([schewara](https://github.com/schewara))
- Allow ensure =\> "present" for runners [\#36](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/36) ([evhan](https://github.com/evhan))
- allow build\_dir and cache\_dir to be managed [\#34](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/34) ([slmagus](https://github.com/slmagus))

## [v1.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v1.0.0) (2018-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/a499e3dab7578847be6bba12baba63168b077bfa...v1.0.0)

This is the first release of `puppet/gitlab_ci_runner`.  The functionality in this module was previously part of [puppet/gitlab](https://github.com/voxpupuli/puppet-gitlab)

**Fixed bugs:**

- Fix \(un-\)registering runner with similar names [\#22](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/22) ([elkangaroo](https://github.com/elkangaroo))

**Closed issues:**

- Import cirunner code from voxpupuli/puppet-gitlab module [\#12](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/12)
- remove `apt` from dependencies  [\#4](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/4)
- Update license in metadata.json and add LiCENSE file [\#3](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/3)
- Update ruby version in Dockerfile [\#2](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/2)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#23](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/23) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#19](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/19) ([bastelfreak](https://github.com/bastelfreak))
- initial import of puppet code [\#13](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/13) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- remove apt from metadata.json dependencies [\#10](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/10) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- Update ruby version in dockerfile [\#8](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/8) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- fix module name in metadata.json [\#6](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/6) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- update licensing information [\#5](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/5) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- modulesync setup [\#1](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/1) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
