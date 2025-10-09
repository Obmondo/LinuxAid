# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v3.1.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v3.1.0) (2024-03-14)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Add puppet-strings documentation [\#129](https://github.com/voxpupuli/puppet-posix_acl/pull/129) ([bastelfreak](https://github.com/bastelfreak))
- README.md: Add badges /transfer notice/contributing notes [\#128](https://github.com/voxpupuli/puppet-posix_acl/pull/128) ([bastelfreak](https://github.com/bastelfreak))
- Add Ubuntu 20.04/22.04 & Debian 12 [\#127](https://github.com/voxpupuli/puppet-posix_acl/pull/127) ([tuxmea](https://github.com/tuxmea))

## [v3.0.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v3.0.0) (2023-06-26)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#117](https://github.com/voxpupuli/puppet-posix_acl/pull/117) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add EL9/Rocky/Alma support [\#121](https://github.com/voxpupuli/puppet-posix_acl/pull/121) ([bastelfreak](https://github.com/bastelfreak))
- Add puppet 8 support [\#120](https://github.com/voxpupuli/puppet-posix_acl/pull/120) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v2.0.0) (2022-01-26)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v1.1.0...v2.0.0)

**Breaking changes:**

- Drop EoL Debian 9 support [\#100](https://github.com/voxpupuli/puppet-posix_acl/pull/100) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 5.1.0 / Drop EoL Puppet 5 support [\#97](https://github.com/voxpupuli/puppet-posix_acl/pull/97) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add support for Debian 11, RedHat 8 \(and derivatives\) [\#95](https://github.com/voxpupuli/puppet-posix_acl/pull/95) ([smortex](https://github.com/smortex))
- Implement handling of missing files [\#93](https://github.com/voxpupuli/puppet-posix_acl/pull/93) ([raemer](https://github.com/raemer))
- Mark compatible with Puppet 7 [\#92](https://github.com/voxpupuli/puppet-posix_acl/pull/92) ([Thelvaen](https://github.com/Thelvaen))
- Changed to osfamily to make it work on oracle linux systems [\#89](https://github.com/voxpupuli/puppet-posix_acl/pull/89) ([housemasterkrause](https://github.com/housemasterkrause))

**Fixed bugs:**

- dont set ACLs if there are no ACLs to change [\#108](https://github.com/voxpupuli/puppet-posix_acl/pull/108) ([bastelfreak](https://github.com/bastelfreak))
- Properly handle frozen strings [\#107](https://github.com/voxpupuli/puppet-posix_acl/pull/107) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- FrozenStringLiteral breaks puppet module [\#104](https://github.com/voxpupuli/puppet-posix_acl/issues/104)
- Oracle Linux: Warning about multiple default providers [\#88](https://github.com/voxpupuli/puppet-posix_acl/issues/88)

**Merged pull requests:**

- Add acceptance test and documentation for file autorequire [\#113](https://github.com/voxpupuli/puppet-posix_acl/pull/113) ([bastelfreak](https://github.com/bastelfreak))
- Add test to verify purging ACLs works [\#111](https://github.com/voxpupuli/puppet-posix_acl/pull/111) ([bastelfreak](https://github.com/bastelfreak))
- Fix typo in documentation [\#105](https://github.com/voxpupuli/puppet-posix_acl/pull/105) ([bastelfreak](https://github.com/bastelfreak))
- Manage spec\_helper\_acceptance via modulesync / Enable basic acceptance test [\#102](https://github.com/voxpupuli/puppet-posix_acl/pull/102) ([bastelfreak](https://github.com/bastelfreak))
- Enable puppet lint for tests/docs [\#101](https://github.com/voxpupuli/puppet-posix_acl/pull/101) ([bastelfreak](https://github.com/bastelfreak))
- Remove old unsupported Beaker nodesets [\#90](https://github.com/voxpupuli/puppet-posix_acl/pull/90) ([ekohl](https://github.com/ekohl))

## [v1.1.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v1.1.0) (2021-06-07)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v1.0.1...v1.1.0)

**Implemented enhancements:**

- make posix\_acl run more efficiently [\#85](https://github.com/voxpupuli/puppet-posix_acl/pull/85) ([oniGino](https://github.com/oniGino))

## [v1.0.1](https://github.com/voxpupuli/puppet-posix_acl/tree/v1.0.1) (2020-01-30)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v1.0.0...v1.0.1)

**Fixed bugs:**

- fix comparing permissions when they have a mix of upper- and lower-ca… [\#74](https://github.com/voxpupuli/puppet-posix_acl/pull/74) ([unki](https://github.com/unki))

## [v1.0.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v1.0.0) (2019-10-29)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v0.1.1...v1.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#59](https://github.com/voxpupuli/puppet-posix_acl/pull/59) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- \[RFE\] Extend File type to eliminate need for redundant code [\#16](https://github.com/voxpupuli/puppet-posix_acl/issues/16)
- Directory +x / Files not +x [\#9](https://github.com/voxpupuli/puppet-posix_acl/issues/9)
- Add Gentoo support [\#66](https://github.com/voxpupuli/puppet-posix_acl/pull/66) ([paescuj](https://github.com/paescuj))
- X bit support [\#61](https://github.com/voxpupuli/puppet-posix_acl/pull/61) ([jadestorm](https://github.com/jadestorm))

**Fixed bugs:**

- File is executable when X option is set on directory [\#64](https://github.com/voxpupuli/puppet-posix_acl/issues/64)
- Fix for issue \#64 [\#65](https://github.com/voxpupuli/puppet-posix_acl/pull/65) ([jadestorm](https://github.com/jadestorm))

**Closed issues:**

- Version release [\#67](https://github.com/voxpupuli/puppet-posix_acl/issues/67)
- README not displaying in forge [\#55](https://github.com/voxpupuli/puppet-posix_acl/issues/55)
- Solaris support [\#32](https://github.com/voxpupuli/puppet-posix_acl/issues/32)

**Merged pull requests:**

- Expand the operating system support to include Debian 9 and 10 [\#62](https://github.com/voxpupuli/puppet-posix_acl/pull/62) ([gfa](https://github.com/gfa))
- Change filename to allow rendering on Puppet Forge. [\#60](https://github.com/voxpupuli/puppet-posix_acl/pull/60) ([cdchase](https://github.com/cdchase))

## [v0.1.1](https://github.com/voxpupuli/puppet-posix_acl/tree/v0.1.1) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#53](https://github.com/voxpupuli/puppet-posix_acl/pull/53) ([bastelfreak](https://github.com/bastelfreak))

## [v0.1.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v0.1.0) (2018-07-16)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.5...v0.1.0)

**Implemented enhancements:**

- Move to Vox Pupuli [\#29](https://github.com/voxpupuli/puppet-posix_acl/issues/29)

**Merged pull requests:**

- Remove docker nodesets [\#47](https://github.com/voxpupuli/puppet-posix_acl/pull/47) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#46](https://github.com/voxpupuli/puppet-posix_acl/pull/46) ([bastelfreak](https://github.com/bastelfreak))
- Rubocop: Fix Style/PredicateName [\#42](https://github.com/voxpupuli/puppet-posix_acl/pull/42) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop: Fix Style/GuardClause [\#41](https://github.com/voxpupuli/puppet-posix_acl/pull/41) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop: Fix Lint/UselessAssignment [\#40](https://github.com/voxpupuli/puppet-posix_acl/pull/40) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop auto fixes [\#39](https://github.com/voxpupuli/puppet-posix_acl/pull/39) ([alexjfisher](https://github.com/alexjfisher))
- Fix metadata and add LICENSE file [\#36](https://github.com/voxpupuli/puppet-posix_acl/pull/36) ([alexjfisher](https://github.com/alexjfisher))
- remove ruby 1.9.3 support [\#35](https://github.com/voxpupuli/puppet-posix_acl/pull/35) ([dobbymoodge](https://github.com/dobbymoodge))

## [0.0.5](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.5) (2017-12-12)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.4...0.0.5)

## [0.0.4](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.4) (2017-12-12)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.3...0.0.4)

**Fixed bugs:**

- module name conflict [\#26](https://github.com/voxpupuli/puppet-posix_acl/issues/26)

**Closed issues:**

- Race condition with non existing file and recursemode =\> deep [\#22](https://github.com/voxpupuli/puppet-posix_acl/issues/22)
- Publish to the forge [\#21](https://github.com/voxpupuli/puppet-posix_acl/issues/21)

**Merged pull requests:**

- Time to deprecate Ruby 1.8.7 support [\#31](https://github.com/voxpupuli/puppet-posix_acl/pull/31) ([dobbymoodge](https://github.com/dobbymoodge))
- Fixes ACL's with spaces [\#30](https://github.com/voxpupuli/puppet-posix_acl/pull/30) ([i1tech](https://github.com/i1tech))
- fix another Ruby error when the file doesn't exist yet [\#28](https://github.com/voxpupuli/puppet-posix_acl/pull/28) ([tequeter](https://github.com/tequeter))
- use inspect instead of join to stringify arrays [\#27](https://github.com/voxpupuli/puppet-posix_acl/pull/27) ([tequeter](https://github.com/tequeter))
- Do not downcase acl group/user names when checking for insync?. [\#25](https://github.com/voxpupuli/puppet-posix_acl/pull/25) ([tdevelioglu](https://github.com/tdevelioglu))
- Check if a path exists before calling getfacl [\#23](https://github.com/voxpupuli/puppet-posix_acl/pull/23) ([roidelapluie](https://github.com/roidelapluie))

## [0.0.3](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.3) (2016-01-13)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/650e19723054c74baa662d3f1589398550524b33...0.0.3)

**Closed issues:**

- Accept short acls. [\#4](https://github.com/voxpupuli/puppet-posix_acl/issues/4)

**Merged pull requests:**

- Switch from Modulefile to metadata.json [\#20](https://github.com/voxpupuli/puppet-posix_acl/pull/20) ([roidelapluie](https://github.com/roidelapluie))
- Fix defaults: behaviour [\#19](https://github.com/voxpupuli/puppet-posix_acl/pull/19) ([roidelapluie](https://github.com/roidelapluie))
- Add autorequire on parent ACL [\#18](https://github.com/voxpupuli/puppet-posix_acl/pull/18) ([roidelapluie](https://github.com/roidelapluie))
- Fix ruby 1.8.7 quirks [\#17](https://github.com/voxpupuli/puppet-posix_acl/pull/17) ([dobbymoodge](https://github.com/dobbymoodge))
- Better support for 'deep' recursive acls [\#15](https://github.com/voxpupuli/puppet-posix_acl/pull/15) ([roidelapluie](https://github.com/roidelapluie))
- Adds space around operators in ternary expressions [\#14](https://github.com/voxpupuli/puppet-posix_acl/pull/14) ([dobbymoodge](https://github.com/dobbymoodge))
- Add recursemode parameter to apply ACLs recursively [\#13](https://github.com/voxpupuli/puppet-posix_acl/pull/13) ([dobbymoodge](https://github.com/dobbymoodge))
- Add the Puppetlabs Skeleton for testing [\#11](https://github.com/voxpupuli/puppet-posix_acl/pull/11) ([roidelapluie](https://github.com/roidelapluie))
- Drop duplicate ACL's. [\#10](https://github.com/voxpupuli/puppet-posix_acl/pull/10) ([kevincox](https://github.com/kevincox))
- Update sync [\#7](https://github.com/voxpupuli/puppet-posix_acl/pull/7) ([mwoodson](https://github.com/mwoodson))
- Normalize ACL's. [\#5](https://github.com/voxpupuli/puppet-posix_acl/pull/5) ([kevincox](https://github.com/kevincox))
- Make posixacl the default for the redhat family [\#3](https://github.com/voxpupuli/puppet-posix_acl/pull/3) ([nhemingway](https://github.com/nhemingway))
- Add a acl::requirements class [\#2](https://github.com/voxpupuli/puppet-posix_acl/pull/2) ([duritong](https://github.com/duritong))
- Fix typo and make Modulefile validate by puppet module tool [\#1](https://github.com/voxpupuli/puppet-posix_acl/pull/1) ([carlossg](https://github.com/carlossg))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
