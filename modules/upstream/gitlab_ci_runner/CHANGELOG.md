# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

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
