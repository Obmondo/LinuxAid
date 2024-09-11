# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.1.0](https://github.com/voxpupuli/puppet-rhsm/tree/v5.1.0) (2022-07-25)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v5.0.0...v5.1.0)

**Implemented enhancements:**

- When purging unmanaged repos, this file needs to be known to puppet. [\#125](https://github.com/voxpupuli/puppet-rhsm/pull/125) ([jcpunk](https://github.com/jcpunk))
- Add package\_profile\_on\_trans [\#123](https://github.com/voxpupuli/puppet-rhsm/pull/123) ([marcelfischer](https://github.com/marcelfischer))

**Fixed bugs:**

- Ensure dnf/yum plugin config has read. [\#124](https://github.com/voxpupuli/puppet-rhsm/pull/124) ([jcpunk](https://github.com/jcpunk))

## [v5.0.0](https://github.com/voxpupuli/puppet-rhsm/tree/v5.0.0) (2022-04-28)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v4.1.0...v5.0.0)

**Breaking changes:**

- modulesync 5.2.0 / Drop EoL Puppet 5 support [\#118](https://github.com/voxpupuli/puppet-rhsm/pull/118) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add way to configure the dnf/yum plugin [\#121](https://github.com/voxpupuli/puppet-rhsm/pull/121) ([jcpunk](https://github.com/jcpunk))
- add no\_proxy to rhsm.conf, defaults to undef [\#117](https://github.com/voxpupuli/puppet-rhsm/pull/117) ([darktim](https://github.com/darktim))

## [v4.1.0](https://github.com/voxpupuli/puppet-rhsm/tree/v4.1.0) (2021-09-27)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Enable Puppet 7 support [\#115](https://github.com/voxpupuli/puppet-rhsm/pull/115) ([bastelfreak](https://github.com/bastelfreak))
- add proxy\_scheme \(defaults to 'http'\) [\#112](https://github.com/voxpupuli/puppet-rhsm/pull/112) ([jorgemorgado](https://github.com/jorgemorgado))
- Add process\_timeout parameter [\#105](https://github.com/voxpupuli/puppet-rhsm/pull/105) ([treydock](https://github.com/treydock))
- Add server info to facts [\#103](https://github.com/voxpupuli/puppet-rhsm/pull/103) ([yakatz](https://github.com/yakatz))
- Add Sensitive to RHSM exec and update metadata [\#96](https://github.com/voxpupuli/puppet-rhsm/pull/96) ([rcalixte](https://github.com/rcalixte))

**Fixed bugs:**

- fix: use sensitive\(\) for rspec-puppet 2.8 [\#113](https://github.com/voxpupuli/puppet-rhsm/pull/113) ([raphink](https://github.com/raphink))

**Closed issues:**

- Yumrepo target parameter does not work [\#68](https://github.com/voxpupuli/puppet-rhsm/issues/68)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#114](https://github.com/voxpupuli/puppet-rhsm/pull/114) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/voxpupuli/puppet-rhsm/tree/v4.0.0) (2020-01-15)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v3.2.0...v4.0.0)

**Breaking changes:**

- Eliminates subscription-manager exec on every Puppet run [\#95](https://github.com/voxpupuli/puppet-rhsm/pull/95) ([speer](https://github.com/speer))
- modulesync 2.5.1 and drop Puppet 4 [\#84](https://github.com/voxpupuli/puppet-rhsm/pull/84) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Features request: SCL repos [\#66](https://github.com/voxpupuli/puppet-rhsm/issues/66)
- Add types and providers from crayfishx/puppet-rhsm [\#88](https://github.com/voxpupuli/puppet-rhsm/pull/88) ([kallies](https://github.com/kallies))
- Add defaults and make server\_timeout and inotify configurable [\#86](https://github.com/voxpupuli/puppet-rhsm/pull/86) ([kallies](https://github.com/kallies))
- Move RHSM-subscribe dependency inside repo type [\#83](https://github.com/voxpupuli/puppet-rhsm/pull/83) ([speer](https://github.com/speer))

**Closed issues:**

- Don't enforce latest package to be installed as default value [\#92](https://github.com/voxpupuli/puppet-rhsm/issues/92)
- Read facts from /etc/yum.repos.d/redhat.repo instead of subscription-manager [\#90](https://github.com/voxpupuli/puppet-rhsm/issues/90)
- Use types and providers for subscriptions and repositories [\#87](https://github.com/voxpupuli/puppet-rhsm/issues/87)
- Update rhsm.conf template [\#85](https://github.com/voxpupuli/puppet-rhsm/issues/85)

**Merged pull requests:**

- travis: dont upgrade bundler [\#99](https://github.com/voxpupuli/puppet-rhsm/pull/99) ([bastelfreak](https://github.com/bastelfreak))
- Allow `puppetlabs/stdlib` 6.x [\#93](https://github.com/voxpupuli/puppet-rhsm/pull/93) ([alexjfisher](https://github.com/alexjfisher))

## [v3.2.0](https://github.com/voxpupuli/puppet-rhsm/tree/v3.2.0) (2018-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v3.1.0...v3.2.0)

**Implemented enhancements:**

- Add a Array\[String\] argument of repo IDs to be enabled [\#78](https://github.com/voxpupuli/puppet-rhsm/pull/78) ([pdemonaco](https://github.com/pdemonaco))

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#79](https://github.com/voxpupuli/puppet-rhsm/pull/79) ([bastelfreak](https://github.com/bastelfreak))

## [v3.1.0](https://github.com/voxpupuli/puppet-rhsm/tree/v3.1.0) (2018-09-06)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Add rhsm\_subscription\_type fact [\#65](https://github.com/voxpupuli/puppet-rhsm/pull/65) ([kallies](https://github.com/kallies))

**Closed issues:**

- Add fact for subscription management type [\#64](https://github.com/voxpupuli/puppet-rhsm/issues/64)
- Puppet agent run fails if the system is not already registered with RHSM [\#62](https://github.com/voxpupuli/puppet-rhsm/issues/62)

**Merged pull requests:**

- allow puppetlabs/stdlib 5.x [\#75](https://github.com/voxpupuli/puppet-rhsm/pull/75) ([bastelfreak](https://github.com/bastelfreak))
- Remove docker nodesets [\#71](https://github.com/voxpupuli/puppet-rhsm/pull/71) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#70](https://github.com/voxpupuli/puppet-rhsm/pull/70) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-rhsm/tree/v3.0.0) (2017-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v2.1.1...v3.0.0)

**Breaking changes:**

- Add params for adding custom certificates [\#57](https://github.com/voxpupuli/puppet-rhsm/pull/57) ([kallies](https://github.com/kallies))

**Fixed bugs:**

- Fix yumrepo 'enabled' property [\#59](https://github.com/voxpupuli/puppet-rhsm/pull/59) ([cohdjn](https://github.com/cohdjn))

**Closed issues:**

- repo\_optional always caused puppet run to make change [\#58](https://github.com/voxpupuli/puppet-rhsm/issues/58)
- Each entry in /etc/rhsm/rhsm.conf should be a configurable param [\#11](https://github.com/voxpupuli/puppet-rhsm/issues/11)
- help with process in using this module [\#6](https://github.com/voxpupuli/puppet-rhsm/issues/6)

## [v2.1.1](https://github.com/voxpupuli/puppet-rhsm/tree/v2.1.1) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v2.1.0...v2.1.1)

**Fixed bugs:**

- Add missing parameter manage\_repos [\#55](https://github.com/voxpupuli/puppet-rhsm/pull/55) ([kallies](https://github.com/kallies))

## [v2.1.0](https://github.com/voxpupuli/puppet-rhsm/tree/v2.1.0) (2017-10-09)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- Update rhsm.conf template \(5.15.1\) and add configurable params [\#50](https://github.com/voxpupuli/puppet-rhsm/pull/50) ([kallies](https://github.com/kallies))
- Change documentation syntax to YARD/Puppet Strings [\#48](https://github.com/voxpupuli/puppet-rhsm/pull/48) ([kallies](https://github.com/kallies))

**Fixed bugs:**

- `yum repolist` in fact rhsm\_repos leads to deadlock [\#52](https://github.com/voxpupuli/puppet-rhsm/issues/52)
- Change servername to subscription.rhsm.redhat.com [\#49](https://github.com/voxpupuli/puppet-rhsm/pull/49) ([kallies](https://github.com/kallies))

**Merged pull requests:**

- release 2.1.0 [\#54](https://github.com/voxpupuli/puppet-rhsm/pull/54) ([bastelfreak](https://github.com/bastelfreak))
- Use subscription-manager instead of yum for listing enabled repos [\#53](https://github.com/voxpupuli/puppet-rhsm/pull/53) ([kallies](https://github.com/kallies))

## [v2.0.0](https://github.com/voxpupuli/puppet-rhsm/tree/v2.0.0) (2017-07-06)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v1.1.0...v2.0.0)

**Fixed bugs:**

- Add confine rule on Fact [\#46](https://github.com/voxpupuli/puppet-rhsm/pull/46) ([tux-o-matic](https://github.com/tux-o-matic))
- Add 'Expired' in grep to trigger subscription [\#45](https://github.com/voxpupuli/puppet-rhsm/pull/45) ([tux-o-matic](https://github.com/tux-o-matic))

**Closed issues:**

- RHNSM-register fails [\#38](https://github.com/voxpupuli/puppet-rhsm/issues/38)

**Merged pull requests:**

- Release 2.0.0 [\#47](https://github.com/voxpupuli/puppet-rhsm/pull/47) ([bastelfreak](https://github.com/bastelfreak))
- The yumrepo parameter `enabled` had a typo. [\#43](https://github.com/voxpupuli/puppet-rhsm/pull/43) ([rnelson0](https://github.com/rnelson0))
- Add LICENSE file [\#41](https://github.com/voxpupuli/puppet-rhsm/pull/41) ([alexjfisher](https://github.com/alexjfisher))
- Read from both stdout and stderr for Exec onlyif [\#39](https://github.com/voxpupuli/puppet-rhsm/pull/39) ([tux-o-matic](https://github.com/tux-o-matic))

## [v1.1.0](https://github.com/voxpupuli/puppet-rhsm/tree/v1.1.0) (2017-02-11)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v1.0.0...v1.1.0)

**Merged pull requests:**

- Added more path for Exec resources [\#32](https://github.com/voxpupuli/puppet-rhsm/pull/32) ([tux-o-matic](https://github.com/tux-o-matic))

## [v1.0.0](https://github.com/voxpupuli/puppet-rhsm/tree/v1.0.0) (2016-12-25)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/v0.3.0...v1.0.0)

**Closed issues:**

- Fact 'rhsm\_repos' shouldn't depend on a web API call [\#18](https://github.com/voxpupuli/puppet-rhsm/issues/18)
- Should RHSM be compatible with CentOS? [\#16](https://github.com/voxpupuli/puppet-rhsm/issues/16)
- Expand README to include examples of using proxy [\#12](https://github.com/voxpupuli/puppet-rhsm/issues/12)

**Merged pull requests:**

- release 1.0.0 [\#31](https://github.com/voxpupuli/puppet-rhsm/pull/31) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.16.6 [\#30](https://github.com/voxpupuli/puppet-rhsm/pull/30) ([bastelfreak](https://github.com/bastelfreak))
- Set min version\_requirement for Puppet + bump dep [\#29](https://github.com/voxpupuli/puppet-rhsm/pull/29) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Added '/usr/bin' to path for Exec [\#26](https://github.com/voxpupuli/puppet-rhsm/pull/26) ([tux-o-matic](https://github.com/tux-o-matic))
- Add org and activationkey paramters [\#25](https://github.com/voxpupuli/puppet-rhsm/pull/25) ([treydock](https://github.com/treydock))
- Separated Registration and Subscription tasks [\#21](https://github.com/voxpupuli/puppet-rhsm/pull/21) ([tux-o-matic](https://github.com/tux-o-matic))
- Remove CentOS from target OS list and added RHEL 5.7 [\#20](https://github.com/voxpupuli/puppet-rhsm/pull/20) ([tux-o-matic](https://github.com/tux-o-matic))
- Moved Fact to correct path and using YUM rather than subscription-manager [\#19](https://github.com/voxpupuli/puppet-rhsm/pull/19) ([tux-o-matic](https://github.com/tux-o-matic))
- Separated Extras/Optional repo settings from the registration with 'a… [\#17](https://github.com/voxpupuli/puppet-rhsm/pull/17) ([tux-o-matic](https://github.com/tux-o-matic))
- Added documentation for HTTP proxy settings [\#13](https://github.com/voxpupuli/puppet-rhsm/pull/13) ([tux-o-matic](https://github.com/tux-o-matic))
- Use built-in Yumrepo resource type instead of Exec [\#10](https://github.com/voxpupuli/puppet-rhsm/pull/10) ([tux-o-matic](https://github.com/tux-o-matic))

## [v0.3.0](https://github.com/voxpupuli/puppet-rhsm/tree/v0.3.0) (2016-07-21)

[Full Changelog](https://github.com/voxpupuli/puppet-rhsm/compare/7e3ef5c4d227a7cecd376df925207cbc1ca732c3...v0.3.0)

**Merged pull requests:**

- release 0.3.0 [\#9](https://github.com/voxpupuli/puppet-rhsm/pull/9) ([bastelfreak](https://github.com/bastelfreak))
- Added support for unauthenticated proxy and pool attach [\#5](https://github.com/voxpupuli/puppet-rhsm/pull/5) ([tux-o-matic](https://github.com/tux-o-matic))
- General Improvements-revised [\#4](https://github.com/voxpupuli/puppet-rhsm/pull/4) ([VeriskPuppet](https://github.com/VeriskPuppet))
- Changed the addition repos to be based on ${::operatingsystemmajrelease} [\#1](https://github.com/voxpupuli/puppet-rhsm/pull/1) ([jercra](https://github.com/jercra))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
