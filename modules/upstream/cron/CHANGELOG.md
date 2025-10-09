# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.0.0](https://github.com/voxpupuli/puppet-cron/tree/v5.0.0) (2024-12-10)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v4.2.0...v5.0.0)

**Breaking changes:**

- Drop support for EL7 as it is end of life [\#151](https://github.com/voxpupuli/puppet-cron/pull/151) ([ghoneycutt](https://github.com/ghoneycutt))
- Support for sensitive environment variables [\#111](https://github.com/voxpupuli/puppet-cron/pull/111) ([teluq-pbrideau](https://github.com/teluq-pbrideau))

**Implemented enhancements:**

- Add EL9 support [\#141](https://github.com/voxpupuli/puppet-cron/pull/141) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- remove superfluous empty line from job template [\#144](https://github.com/voxpupuli/puppet-cron/pull/144) ([vchepkov](https://github.com/vchepkov))
- cleanup remnants of RHEL5 [\#143](https://github.com/voxpupuli/puppet-cron/pull/143) ([vchepkov](https://github.com/vchepkov))

## [v4.2.0](https://github.com/voxpupuli/puppet-cron/tree/v4.2.0) (2024-07-10)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v4.1.0...v4.2.0)

**Implemented enhancements:**

- Add support for FreeBSD 14 [\#136](https://github.com/voxpupuli/puppet-cron/pull/136) ([smortex](https://github.com/smortex))
- Add parameters for file/directory modes [\#134](https://github.com/voxpupuli/puppet-cron/pull/134) ([ludovicus3](https://github.com/ludovicus3))

**Merged pull requests:**

- refactor: define job::multiple template as epp instead of erb [\#139](https://github.com/voxpupuli/puppet-cron/pull/139) ([bastelfreak](https://github.com/bastelfreak))
- refactor: define job template as epp instead of erb [\#138](https://github.com/voxpupuli/puppet-cron/pull/138) ([bastelfreak](https://github.com/bastelfreak))
- Remove legacy top-scope syntax [\#125](https://github.com/voxpupuli/puppet-cron/pull/125) ([smortex](https://github.com/smortex))

## [v4.1.0](https://github.com/voxpupuli/puppet-cron/tree/v4.1.0) (2023-08-08)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- cron::job: make file group configureable [\#121](https://github.com/voxpupuli/puppet-cron/pull/121) ([bastelfreak](https://github.com/bastelfreak))
- Replace Cron::Mode type with Stdlib::Filemode [\#120](https://github.com/voxpupuli/puppet-cron/pull/120) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-cron/tree/v4.0.0) (2023-07-31)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#114](https://github.com/voxpupuli/puppet-cron/pull/114) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Puppet 8 support [\#116](https://github.com/voxpupuli/puppet-cron/pull/116) ([bastelfreak](https://github.com/bastelfreak))
- Add more acceptance tests [\#107](https://github.com/voxpupuli/puppet-cron/pull/107) ([bastelfreak](https://github.com/bastelfreak))
- add basic acceptance tests [\#106](https://github.com/voxpupuli/puppet-cron/pull/106) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Add AlmaLinux/Rocky support [\#118](https://github.com/voxpupuli/puppet-cron/pull/118) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#117](https://github.com/voxpupuli/puppet-cron/pull/117) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-cron/tree/v3.0.0) (2021-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- Drop support for RedHat/CentOS/Scientific 6, Debian 8, FreeBSD 11 \(EOL\) [\#98](https://github.com/voxpupuli/puppet-cron/pull/98) ([smortex](https://github.com/smortex))
- metadata: update Puppet requirement to \>= 6.1.0 \< 8.0.0; drop puppet 5 support [\#92](https://github.com/voxpupuli/puppet-cron/pull/92) ([kenyon](https://github.com/kenyon))

**Implemented enhancements:**

- Add support for latest RedHat, CentOS, Scientific, Debian, SLES and FreeBSD [\#99](https://github.com/voxpupuli/puppet-cron/pull/99) ([smortex](https://github.com/smortex))
- fix file group: use 0 instead of 'root' [\#87](https://github.com/voxpupuli/puppet-cron/pull/87) ([igalic](https://github.com/igalic))
- add merge option [\#74](https://github.com/voxpupuli/puppet-cron/pull/74) ([ghost](https://github.com/ghost))
- Allow management of /etc/crontab and adding custom run-parts [\#35](https://github.com/voxpupuli/puppet-cron/pull/35) ([treydock](https://github.com/treydock))

**Fixed bugs:**

- Adjust cron.allow / cron.deny permissions [\#80](https://github.com/voxpupuli/puppet-cron/pull/80) ([noqqe](https://github.com/noqqe))

**Closed issues:**

- Test and enable for Puppet 7 [\#91](https://github.com/voxpupuli/puppet-cron/issues/91)
- Fails on FreeBSD because gid 0 is wheel, not root [\#86](https://github.com/voxpupuli/puppet-cron/issues/86)
- Can't get weekday options to work as an array of days [\#84](https://github.com/voxpupuli/puppet-cron/issues/84)
- Implement CIS Benchmark requirements [\#65](https://github.com/voxpupuli/puppet-cron/issues/65)
- Special to support @startup [\#51](https://github.com/voxpupuli/puppet-cron/issues/51)

**Merged pull requests:**

- Make the mode a parameter [\#95](https://github.com/voxpupuli/puppet-cron/pull/95) ([daisukixci](https://github.com/daisukixci))
- Allow values lower than 3 for skip hours [\#94](https://github.com/voxpupuli/puppet-cron/pull/94) ([scorillo](https://github.com/scorillo))
- Add puppet-strings docs [\#88](https://github.com/voxpupuli/puppet-cron/pull/88) ([baurmatt](https://github.com/baurmatt))
- Resolve puppet-lint notices [\#85](https://github.com/voxpupuli/puppet-cron/pull/85) ([jcpunk](https://github.com/jcpunk))
- modulesync 3.0.0 & puppet-lint updates [\#83](https://github.com/voxpupuli/puppet-cron/pull/83) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.0](https://github.com/voxpupuli/puppet-cron/tree/v2.0.0) (2020-01-13)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.3.1...v2.0.0)

**Breaking changes:**

- drop Ubuntu support [\#76](https://github.com/voxpupuli/puppet-cron/pull/76) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 2.7.0 and drop puppet 4 [\#70](https://github.com/voxpupuli/puppet-cron/pull/70) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Changes the defaults of the cronjob-files from 644 to 600 [\#75](https://github.com/voxpupuli/puppet-cron/pull/75) ([ralfbosz](https://github.com/ralfbosz))
- allow dots in cron::user data type [\#71](https://github.com/voxpupuli/puppet-cron/pull/71) ([rwaffen](https://github.com/rwaffen))

**Fixed bugs:**

- If you attempt to use anything below \*/3 the regex fails [\#66](https://github.com/voxpupuli/puppet-cron/pull/66) ([elmobp](https://github.com/elmobp))
- Fix `job::cron` `special` parameter [\#64](https://github.com/voxpupuli/puppet-cron/pull/64) ([alexjfisher](https://github.com/alexjfisher))

## [v1.3.1](https://github.com/voxpupuli/puppet-cron/tree/v1.3.1) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.3.0...v1.3.1)

**Closed issues:**

- Special parameter is now set incorrectly with two @ [\#59](https://github.com/voxpupuli/puppet-cron/issues/59)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#62](https://github.com/voxpupuli/puppet-cron/pull/62) ([bastelfreak](https://github.com/bastelfreak))

## [v1.3.0](https://github.com/voxpupuli/puppet-cron/tree/v1.3.0) (2018-07-16)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.2.0...v1.3.0)

**Implemented enhancements:**

- Update data types to allow comma-delimited lists [\#50](https://github.com/voxpupuli/puppet-cron/pull/50) ([jcbollinger](https://github.com/jcbollinger))

**Fixed bugs:**

- Comma character in hour/minute parameters [\#49](https://github.com/voxpupuli/puppet-cron/issues/49)

## [v1.2.0](https://github.com/voxpupuli/puppet-cron/tree/v1.2.0) (2018-06-25)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.1.1...v1.2.0)

**Fixed bugs:**

- Code in init.pp doesn't match defined types [\#31](https://github.com/voxpupuli/puppet-cron/issues/31)

**Closed issues:**

- Make first release under voxpupuli's 'puppet' namespace [\#36](https://github.com/voxpupuli/puppet-cron/issues/36)
- Add defined types for parameter validation. [\#30](https://github.com/voxpupuli/puppet-cron/issues/30)

**Merged pull requests:**

- Remove docker nodesets [\#47](https://github.com/voxpupuli/puppet-cron/pull/47) ([bastelfreak](https://github.com/bastelfreak))
- bump puppet version dependency to \>= 4.10.0 \< 6.0.0 [\#46](https://github.com/voxpupuli/puppet-cron/pull/46) ([bastelfreak](https://github.com/bastelfreak))
- Add types for parameter validation. [\#29](https://github.com/voxpupuli/puppet-cron/pull/29) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v1.1.1](https://github.com/voxpupuli/puppet-cron/tree/v1.1.1) (2018-01-19)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- Release 1.1.1 [\#43](https://github.com/voxpupuli/puppet-cron/pull/43) ([alexjfisher](https://github.com/alexjfisher))
- Fix README.md links [\#42](https://github.com/voxpupuli/puppet-cron/pull/42) ([alexjfisher](https://github.com/alexjfisher))

## [v1.1.0](https://github.com/voxpupuli/puppet-cron/tree/v1.1.0) (2018-01-19)

[Full Changelog](https://github.com/voxpupuli/puppet-cron/compare/v1.0.0...v1.1.0)

**Fixed bugs:**

- Fix hiera lookup regression [\#40](https://github.com/voxpupuli/puppet-cron/pull/40) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- Voxpupuli migration [\#37](https://github.com/voxpupuli/puppet-cron/pull/37) ([alexjfisher](https://github.com/alexjfisher))

## v1.0.0 (2017-10-14)

  * BREAKING: Require Puppet version >=4.9.1
  * Added type-hinting to all manifest parameters
  * Added management of /etc/cron.allow and /etc/cron.deny
  * Replaced hiera\_hash() with lookup() calls
  * Replaced params.pp with in-module data (Hiera 5)
  * Replaced create\_resources with iterators
  * Replaced anchor pattern with contain
  * Made the cron::job command attribute optional

## v0.2.1 (2017-07-30)

  * Added support for special time options
  * Rspec fixes

## v0.2.0 (2016-11-22)

  * BREAKING: Added cron service managment
    The cron service is now managed by this module and by default the service will be started
  * Rspec fixes

## v0.1.8 (2016-06-26)

  * Added support for Scientific Linux

## v0.1.7 (2016-06-12)

  * Properly support Gentoo
  * Documentation fixes
  * Rspec fixes

## v0.1.6 (2016-04-10)

  * Added description parameters

## v0.1.5 (2016-03-06)

  * Fix release on forge

## v0.1.4 (2016-03-06)

  * Added possibility to add jobs from hiera
  * Added Debian as supported operating system
  * Allow declaration of cron class without managing the cron package
  * Properly detect RHEL 5 based cron packages
  * Fix puppet-lint warnings
  * Add more tests

## v0.1.3 (2015-09-20)

  * Support for multiple cron jobs in a single file added (cron::job::multiple)
  * Make manifest code more readable
  * Change header in template to fit standard 80 char wide terminals
  * Extend README.md

## v0.1.2 (2015-08-13)

  * Update to new style of Puppet modules (metadata.json)

## v0.1.1 (2015-07-12)

  * Make module Puppet 4 compatible
  * Fix Travis CI integration

## v0.1.0 (2013-08-27)

  * Add support for the `ensure` parameter

## v0.0.3 (2013-07-04)

  * Make job files owned by root
  * Fix warnings for Puppet 3.2.2

## v0.0.2 (2013-05-11)

  * Make mode of job file configurable

## v0.0.1 (2013-03-02)

  * Initial PuppetForge release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
