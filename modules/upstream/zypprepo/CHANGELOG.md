# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.0.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v5.0.0) (2023-08-21)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v4.0.1...v5.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#73](https://github.com/voxpupuli/puppet-zypprepo/pull/73) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- allow puppetlabs/concat 9.x [\#79](https://github.com/voxpupuli/puppet-zypprepo/pull/79) ([jhoblitt](https://github.com/jhoblitt))
- Add Puppet 8 support [\#76](https://github.com/voxpupuli/puppet-zypprepo/pull/76) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#75](https://github.com/voxpupuli/puppet-zypprepo/pull/75) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Prevent warning about already initialized constant [\#72](https://github.com/voxpupuli/puppet-zypprepo/pull/72) ([tuxmea](https://github.com/tuxmea))

**Closed issues:**

- Warning about "already initialized constant" [\#71](https://github.com/voxpupuli/puppet-zypprepo/issues/71)

## [v4.0.1](https://github.com/voxpupuli/puppet-zypprepo/tree/v4.0.1) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v4.0.0...v4.0.1)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#65](https://github.com/voxpupuli/puppet-zypprepo/pull/65) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v4.0.0) (2021-04-09)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v3.1.0...v4.0.0)

**Breaking changes:**

- Drop EoL Puppet 5 support / Add Puppet 7 support [\#62](https://github.com/voxpupuli/puppet-zypprepo/pull/62) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- puppetlabs/concat and puppetlabs/stdlib: Allow version 7 [\#61](https://github.com/voxpupuli/puppet-zypprepo/pull/61) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Fix the value declaration of type [\#60](https://github.com/voxpupuli/puppet-zypprepo/pull/60) ([dadav](https://github.com/dadav))

**Closed issues:**

- Repo doesnt actually gets enabled [\#59](https://github.com/voxpupuli/puppet-zypprepo/issues/59)
- Unable to manage path property [\#57](https://github.com/voxpupuli/puppet-zypprepo/issues/57)
- PDK and add tests [\#53](https://github.com/voxpupuli/puppet-zypprepo/issues/53)
- Errors when another zypper is running [\#12](https://github.com/voxpupuli/puppet-zypprepo/issues/12)

**Merged pull requests:**

- Allow changing of path property [\#58](https://github.com/voxpupuli/puppet-zypprepo/pull/58) ([tuxmea](https://github.com/tuxmea))
- Add unit tests for zypprepo type/provider [\#55](https://github.com/voxpupuli/puppet-zypprepo/pull/55) ([tuxmea](https://github.com/tuxmea))

## [v3.1.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v3.1.0) (2020-12-12)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Migrate zypprepo from type only to type and provider [\#52](https://github.com/voxpupuli/puppet-zypprepo/pull/52) ([tuxmea](https://github.com/tuxmea))
- Add repo\_gpgcheck and pkg\_gpgcheck options [\#48](https://github.com/voxpupuli/puppet-zypprepo/pull/48) ([mx-psi](https://github.com/mx-psi))

**Closed issues:**

- Option to remove all repositories that are not managed by puppet [\#9](https://github.com/voxpupuli/puppet-zypprepo/issues/9)
- Ability to remove repo [\#5](https://github.com/voxpupuli/puppet-zypprepo/issues/5)

## [v3.0.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v3.0.0) (2020-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v2.2.2...v3.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#40](https://github.com/voxpupuli/puppet-zypprepo/pull/40) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add versionlock support [\#44](https://github.com/voxpupuli/puppet-zypprepo/pull/44) ([msurato](https://github.com/msurato))

**Merged pull requests:**

- Add support for SLES 15 [\#46](https://github.com/voxpupuli/puppet-zypprepo/pull/46) ([msurato](https://github.com/msurato))

## [v2.2.2](https://github.com/voxpupuli/puppet-zypprepo/tree/v2.2.2) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v2.2.1...v2.2.2)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#36](https://github.com/voxpupuli/puppet-zypprepo/pull/36) ([bastelfreak](https://github.com/bastelfreak))
- Remove docker nodesets [\#32](https://github.com/voxpupuli/puppet-zypprepo/pull/32) ([bastelfreak](https://github.com/bastelfreak))

## [v2.2.1](https://github.com/voxpupuli/puppet-zypprepo/tree/v2.2.1) (2018-03-30)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v2.2.0...v2.2.1)

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#29](https://github.com/voxpupuli/puppet-zypprepo/pull/29) ([bastelfreak](https://github.com/bastelfreak))

## [v2.2.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v2.2.0) (2017-11-02)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v2.1.0...v2.2.0)

**Implemented enhancements:**

- NONE is a valid value for Zypp repositories [\#24](https://github.com/voxpupuli/puppet-zypprepo/pull/24) ([laserguy2020](https://github.com/laserguy2020))

**Closed issues:**

- Remove PaxHeaders from distributed package [\#11](https://github.com/voxpupuli/puppet-zypprepo/issues/11)

## [v2.1.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v2.1.0) (2017-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v2.0.0...v2.1.0)

**Closed issues:**

- deprecation warning [\#21](https://github.com/voxpupuli/puppet-zypprepo/issues/21)
- Request to migrate zypprepo to VoxPupuli [\#15](https://github.com/voxpupuli/puppet-zypprepo/issues/15)
- Versions [\#8](https://github.com/voxpupuli/puppet-zypprepo/issues/8)

**Merged pull requests:**

- Add LICENSE file and badge [\#19](https://github.com/voxpupuli/puppet-zypprepo/pull/19) ([alexjfisher](https://github.com/alexjfisher))
- Remove Modulefile [\#18](https://github.com/voxpupuli/puppet-zypprepo/pull/18) ([alexjfisher](https://github.com/alexjfisher))

## [v2.0.0](https://github.com/voxpupuli/puppet-zypprepo/tree/v2.0.0) (2017-05-13)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/v1.0.2...v2.0.0)

**Merged pull requests:**

- Remove newtype warning in Puppet 4.8 [\#13](https://github.com/voxpupuli/puppet-zypprepo/pull/13) ([egoexpress](https://github.com/egoexpress))
- update metadata.json [\#7](https://github.com/voxpupuli/puppet-zypprepo/pull/7) ([mmoll](https://github.com/mmoll))

## [v1.0.2](https://github.com/voxpupuli/puppet-zypprepo/tree/v1.0.2) (2015-01-21)

[Full Changelog](https://github.com/voxpupuli/puppet-zypprepo/compare/79c943bba65ffc7e45208923becd90d14a653013...v1.0.2)

**Closed issues:**

- Update metadata.json [\#6](https://github.com/voxpupuli/puppet-zypprepo/issues/6)
- It Doesn't Run [\#3](https://github.com/voxpupuli/puppet-zypprepo/issues/3)

**Merged pull requests:**

- Update to README [\#2](https://github.com/voxpupuli/puppet-zypprepo/pull/2) ([benkevan](https://github.com/benkevan))
- Zypper supports Yum Repos, added Support for them. [\#1](https://github.com/voxpupuli/puppet-zypprepo/pull/1) ([scottjab](https://github.com/scottjab))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
