# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.1.0](https://github.com/voxpupuli/puppet-kmod/tree/v4.1.0) (2024-12-10)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v4.0.1...v4.1.0)

**Implemented enhancements:**

- Add support for EL9 [\#119](https://github.com/voxpupuli/puppet-kmod/pull/119) ([ghoneycutt](https://github.com/ghoneycutt))

## [v4.0.1](https://github.com/voxpupuli/puppet-kmod/tree/v4.0.1) (2023-10-02)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v4.0.0...v4.0.1)

**Fixed bugs:**

- kmods fact produces null byte in parameters datastructure [\#98](https://github.com/voxpupuli/puppet-kmod/issues/98)

**Merged pull requests:**

- Strip null bytes in kmods fact [\#107](https://github.com/voxpupuli/puppet-kmod/pull/107) ([saz](https://github.com/saz))

## [v4.0.0](https://github.com/voxpupuli/puppet-kmod/tree/v4.0.0) (2023-08-07)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v3.2.0...v4.0.0)

**Breaking changes:**

- Drop legacy code for non-systemd systems [\#104](https://github.com/voxpupuli/puppet-kmod/pull/104) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Debian 9 [\#103](https://github.com/voxpupuli/puppet-kmod/pull/103) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 6 support [\#95](https://github.com/voxpupuli/puppet-kmod/pull/95) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add AlmaLinux/Rocky support [\#102](https://github.com/voxpupuli/puppet-kmod/pull/102) ([bastelfreak](https://github.com/bastelfreak))
- Add Puppet 8 support [\#99](https://github.com/voxpupuli/puppet-kmod/pull/99) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#97](https://github.com/voxpupuli/puppet-kmod/pull/97) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Replace egrep usage with grep -E [\#92](https://github.com/voxpupuli/puppet-kmod/pull/92) ([mika](https://github.com/mika))

## [v3.2.0](https://github.com/voxpupuli/puppet-kmod/tree/v3.2.0) (2022-05-04)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v3.1.1...v3.2.0)

**Implemented enhancements:**

- \(\#86\) Enforce permissions on created files [\#87](https://github.com/voxpupuli/puppet-kmod/pull/87) ([silug](https://github.com/silug))

**Fixed bugs:**

- kmod::alias documentation incorrectly refers to modulename [\#82](https://github.com/voxpupuli/puppet-kmod/issues/82)
- Ignore kmod fact read errors [\#81](https://github.com/voxpupuli/puppet-kmod/pull/81) ([jcpunk](https://github.com/jcpunk))

**Closed issues:**

- Need a way to enforce permissions on created files [\#86](https://github.com/voxpupuli/puppet-kmod/issues/86)
- README.md kmod::alias example is incorrect [\#84](https://github.com/voxpupuli/puppet-kmod/issues/84)
- Warning after upgrading to v3.1.0 [\#79](https://github.com/voxpupuli/puppet-kmod/issues/79)

**Merged pull requests:**

- Fix kmod::alias example [\#85](https://github.com/voxpupuli/puppet-kmod/pull/85) ([silug](https://github.com/silug))
- Update kmod::alias documentation [\#83](https://github.com/voxpupuli/puppet-kmod/pull/83) ([silug](https://github.com/silug))

## [v3.1.1](https://github.com/voxpupuli/puppet-kmod/tree/v3.1.1) (2022-02-07)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v3.1.0...v3.1.1)

**Merged pull requests:**

- Hide read error on params when you can't read them [\#78](https://github.com/voxpupuli/puppet-kmod/pull/78) ([jcpunk](https://github.com/jcpunk))

## [v3.1.0](https://github.com/voxpupuli/puppet-kmod/tree/v3.1.0) (2022-02-02)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Add kmod fact [\#44](https://github.com/voxpupuli/puppet-kmod/pull/44) ([jcpunk](https://github.com/jcpunk))

**Fixed bugs:**

- Fix file detection to gather kmod fact [\#75](https://github.com/voxpupuli/puppet-kmod/pull/75) ([kajinamit](https://github.com/kajinamit))

**Closed issues:**

- kmod fact consistently fails with 'expected argument to be a String, Symbol, or Hash' [\#74](https://github.com/voxpupuli/puppet-kmod/issues/74)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#71](https://github.com/voxpupuli/puppet-kmod/pull/71) ([smortex](https://github.com/smortex))
- pull fixtures from git and not forge [\#70](https://github.com/voxpupuli/puppet-kmod/pull/70) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-kmod/tree/v3.0.0) (2021-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-kmod/compare/2.5.0...v3.0.0)

**Breaking changes:**

- Drop Ubuntu 12/14 support; Add 18/20 support [\#68](https://github.com/voxpupuli/puppet-kmod/pull/68) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Debian 6-8 support; add Debian 10 [\#67](https://github.com/voxpupuli/puppet-kmod/pull/67) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL CentOS 5/6 support [\#66](https://github.com/voxpupuli/puppet-kmod/pull/66) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL puppet 4/5 support; add Puppet 7 [\#65](https://github.com/voxpupuli/puppet-kmod/pull/65) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow SUSE 15 [\#61](https://github.com/voxpupuli/puppet-kmod/pull/61) ([caherrera](https://github.com/caherrera))

## [2.5.0](https://github.com/voxpupuli/puppet-kmod/tree/2.5.0) (2020-03-09)

* Add support for EL8 [GH #59]

## 2020-01-07 - Release 2.4.0

* Remove augeasversion check [GH #53]
* Convert to PDK [GH #54]

## 2019-07-30 - Release 2.3.1

* Allow stdlib 6

## 2019-03-01 - Release 2.3.0

* Add hiera class parameters and update documentation [GH #47]
* kmod::load: load modules the systemd way if the system runs systemd [GH #48]
* Adapt tests for Puppet 6

## 2017-08-09 - Release 2.2.0

* Add ArchLinux support [GH #39, #40]
* Fix ensure=absent in alias [GH #42]

## 2015-08-27 - Release 2.1.0

Add minimal SuSE support

## 2015-08-21 - Release 2.0.11

Use docker for acceptance tests

## 2015-06-26 - Release 2.0.10

Fix strict_variables activation with rspec-puppet 2.2

## 2015-05-28 - Release 2.0.9

Add beaker_spec_helper to Gemfile

## 2015-05-26 - Release 2.0.8

Use random application order in nodeset

## 2015-05-26 - Release 2.0.7

add utopic & vivid nodesets

## 2015-05-25 - Release 2.0.6

Don't allow failure on Puppet 4

## 2015-05-13 - Release 2.0.5

Add puppet-lint-file_source_rights-check gem

## 2015-05-12 - Release 2.0.4

Don't pin beaker

## 2015-04-27 - Release 2.0.3

Add nodeset ubuntu-12.04-x86_64-openstack

## 2015-04-18 - Release 2.0.2

- Add beaker nodeset

## 2015-04-15 - Release 2.0.1

- Fix kmod::install's file class parameter's default

## 2015-04-03 - Release 2.0.0

- Add kmod::option and refactored everything to use kmod::setting
- removed obsolete generic.pp

## 2015-03-24 - Release 1.0.6

- Lint

## 2015-01-19 - Release 1.0.5

- Fix relative class inclusions

## 2015-01-07 - Release 1.0.4

- Fix unquoted strings in cases

## 2014-12-16 - Release 1.0.1

- Fix for future parser

## 2014-10-20 - Release 1.0.0

- Setup automatic Forge releases

## 2014-07-02 - Release 0.1.1

- Fix deprecation warnings, #22

## 2014-07-02 - Release 0.1.0

- Add unit tests
- Various improvements


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
