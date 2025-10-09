# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v9.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v9.0.0) (2025-10-07)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v8.0.0...v9.0.0)

**Breaking changes:**

- Drop puppet, update openvox minimum version to 8.19 [\#254](https://github.com/voxpupuli/puppet-logrotate/pull/254) ([TheMeier](https://github.com/TheMeier))

**Implemented enhancements:**

- Update default value "su\_group" to be in line with modern Ubuntu versions [\#218](https://github.com/voxpupuli/puppet-logrotate/issues/218)
- Add Debian 13 support [\#261](https://github.com/voxpupuli/puppet-logrotate/pull/261) ([bastelfreak](https://github.com/bastelfreak))
- Add EL10 support [\#260](https://github.com/voxpupuli/puppet-logrotate/pull/260) ([bastelfreak](https://github.com/bastelfreak))
- puppet/systemd: Allow 9.x [\#258](https://github.com/voxpupuli/puppet-logrotate/pull/258) ([bastelfreak](https://github.com/bastelfreak))
- Allow disabling logrotate-hourly when using systemd [\#249](https://github.com/voxpupuli/puppet-logrotate/pull/249) ([antaflos](https://github.com/antaflos))
- metadata.json: Add OpenVox [\#247](https://github.com/voxpupuli/puppet-logrotate/pull/247) ([jstraw](https://github.com/jstraw))

**Closed issues:**

- Should support disabling hourly logrotation with systemd timer/service [\#248](https://github.com/voxpupuli/puppet-logrotate/issues/248)
- `su` param missing from docs [\#177](https://github.com/voxpupuli/puppet-logrotate/issues/177)

**Merged pull requests:**

- Clarify why flock is used when hourly rotation is enabled [\#250](https://github.com/voxpupuli/puppet-logrotate/pull/250) ([JonasVerhofste](https://github.com/JonasVerhofste))
- README.md: Add Hiera example [\#213](https://github.com/voxpupuli/puppet-logrotate/pull/213) ([d1nuc0m](https://github.com/d1nuc0m))
- Update README.md to add missing `su` option [\#202](https://github.com/voxpupuli/puppet-logrotate/pull/202) ([eddyszucs](https://github.com/eddyszucs))

## [v8.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v8.0.0) (2025-01-17)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v7.1.0...v8.0.0)

**Breaking changes:**

- Drop EoL CentOS 8 support [\#243](https://github.com/voxpupuli/puppet-logrotate/pull/243) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL EL7 support [\#242](https://github.com/voxpupuli/puppet-logrotate/pull/242) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Ubuntu 18.04 support [\#241](https://github.com/voxpupuli/puppet-logrotate/pull/241) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Ubuntu 20.04, 22.04, 24.04 support [\#240](https://github.com/voxpupuli/puppet-logrotate/pull/240) ([alexskr](https://github.com/alexskr))

**Merged pull requests:**

- puppet/systemd: allow 8.x [\#239](https://github.com/voxpupuli/puppet-logrotate/pull/239) ([jay7x](https://github.com/jay7x))

## [v7.1.0](https://github.com/voxpupuli/puppet-logrotate/tree/v7.1.0) (2024-07-23)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v7.0.2...v7.1.0)

**Implemented enhancements:**

- Add Debian 11 & 12 support [\#234](https://github.com/voxpupuli/puppet-logrotate/pull/234) ([bastelfreak](https://github.com/bastelfreak))
- Add AlmaLinux/Rocky 8 & 9 support [\#233](https://github.com/voxpupuli/puppet-logrotate/pull/233) ([bastelfreak](https://github.com/bastelfreak))
- OracleLinux: Add 8 & 9 support [\#230](https://github.com/voxpupuli/puppet-logrotate/pull/230) ([bastelfreak](https://github.com/bastelfreak))
- update puppet-systemd upper bound to 8.0.0 [\#226](https://github.com/voxpupuli/puppet-logrotate/pull/226) ([TheMeier](https://github.com/TheMeier))
- Remove legacy top-scope syntax [\#215](https://github.com/voxpupuli/puppet-logrotate/pull/215) ([smortex](https://github.com/smortex))

## [v7.0.2](https://github.com/voxpupuli/puppet-logrotate/tree/v7.0.2) (2024-02-28)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v7.0.1...v7.0.2)

**Fixed bugs:**

- Support hourly logrotate directory on EL9 again. [\#221](https://github.com/voxpupuli/puppet-logrotate/pull/221) ([traylenator](https://github.com/traylenator))
- Remove the managed hourly directory if the class is disabled [\#192](https://github.com/voxpupuli/puppet-logrotate/pull/192) ([flynet70](https://github.com/flynet70))

## [v7.0.1](https://github.com/voxpupuli/puppet-logrotate/tree/v7.0.1) (2023-12-05)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v7.0.0...v7.0.1)

**Fixed bugs:**

- Use default systemd timer for EL9 logrotate [\#216](https://github.com/voxpupuli/puppet-logrotate/pull/216) ([treydock](https://github.com/treydock))

## [v7.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v7.0.0) (2023-08-02)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v6.1.0...v7.0.0)

**Breaking changes:**

- Drop Eol Debian 9 Support [\#206](https://github.com/voxpupuli/puppet-logrotate/pull/206) ([traylenator](https://github.com/traylenator))

**Implemented enhancements:**

- Add Puppet 8 support [\#209](https://github.com/voxpupuli/puppet-logrotate/pull/209) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#208](https://github.com/voxpupuli/puppet-logrotate/pull/208) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- convert stdlib merge to + operator [\#207](https://github.com/voxpupuli/puppet-logrotate/pull/207) ([robertc99](https://github.com/robertc99))

## [v6.1.0](https://github.com/voxpupuli/puppet-logrotate/tree/v6.1.0) (2022-07-20)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v6.0.0...v6.1.0)

**Implemented enhancements:**

- Update defaults to match RHEL8/9 [\#195](https://github.com/voxpupuli/puppet-logrotate/pull/195) ([jcpunk](https://github.com/jcpunk))

**Fixed bugs:**

- Fix FreeBSD onwer/group [\#188](https://github.com/voxpupuli/puppet-logrotate/pull/188) ([kapouik](https://github.com/kapouik))

**Merged pull requests:**

- Drop old unused beaker nodesets [\#198](https://github.com/voxpupuli/puppet-logrotate/pull/198) ([ekohl](https://github.com/ekohl))

## [v6.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v6.0.0) (2021-09-28)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v5.0.0...v6.0.0)

**Breaking changes:**

- Drop EoL Puppet 5. Ubuntu 16 and Debian 8 support [\#185](https://github.com/voxpupuli/puppet-logrotate/pull/185) ([bastelfreak](https://github.com/bastelfreak))
- Drop EOL EL6 support [\#179](https://github.com/voxpupuli/puppet-logrotate/pull/179) ([ekohl](https://github.com/ekohl))
- Fix cron management [\#174](https://github.com/voxpupuli/puppet-logrotate/pull/174) ([crazymind1337](https://github.com/crazymind1337))

**Implemented enhancements:**

- Enable Puppet 7 support [\#184](https://github.com/voxpupuli/puppet-logrotate/pull/184) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- version 4 doesn't obey manage\_cron\_daily parameter [\#161](https://github.com/voxpupuli/puppet-logrotate/issues/161)
- how to disable file { $logrotate::cron\_hourly\_file:  in hourly.pp  [\#103](https://github.com/voxpupuli/puppet-logrotate/issues/103)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#182](https://github.com/voxpupuli/puppet-logrotate/pull/182) ([smortex](https://github.com/smortex))
- Resolve puppet-lint notices [\#175](https://github.com/voxpupuli/puppet-logrotate/pull/175) ([jcpunk](https://github.com/jcpunk))
- modulesync 3.0.0 & puppet-lint updates [\#173](https://github.com/voxpupuli/puppet-logrotate/pull/173) ([bastelfreak](https://github.com/bastelfreak))
- Use voxpupuli-acceptance [\#172](https://github.com/voxpupuli/puppet-logrotate/pull/172) ([ekohl](https://github.com/ekohl))

## [v5.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v5.0.0) (2020-04-04)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v4.0.0...v5.0.0)

**Breaking changes:**

- drop Ubuntu 14.04 support [\#163](https://github.com/voxpupuli/puppet-logrotate/pull/163) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add `custom_cfg` parameter to `logrotate::rule` allowing custom lines to be appended to rule files [\#66](https://github.com/voxpupuli/puppet-logrotate/pull/66) ([triforce](https://github.com/triforce))

**Fixed bugs:**

- Use /usr/sbin/logrotate as $logrotate\_bin default value with Gentoo [\#169](https://github.com/voxpupuli/puppet-logrotate/pull/169) ([usp-npe](https://github.com/usp-npe))

**Closed issues:**

- Wrong logrotate bin path with Gentoo [\#167](https://github.com/voxpupuli/puppet-logrotate/issues/167)

**Merged pull requests:**

- Remove duplicate CONTRIBUTING.md file [\#164](https://github.com/voxpupuli/puppet-logrotate/pull/164) ([dhoppe](https://github.com/dhoppe))
- Clean up acceptance spec helper [\#162](https://github.com/voxpupuli/puppet-logrotate/pull/162) ([ekohl](https://github.com/ekohl))

## [v4.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v4.0.0) (2019-09-19)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.4.0...v4.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#147](https://github.com/voxpupuli/puppet-logrotate/pull/147) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- "su" and "su\_owner" parameters are not accepted in "conf" [\#40](https://github.com/voxpupuli/puppet-logrotate/issues/40)
- Use modern facts and $facts hash for osfamily [\#151](https://github.com/voxpupuli/puppet-logrotate/pull/151) ([simmerz](https://github.com/simmerz))
- Introduce new top level parameter manage\_cron\_hourly which defaults … [\#137](https://github.com/voxpupuli/puppet-logrotate/pull/137) ([cliff-wakefield](https://github.com/cliff-wakefield))

**Closed issues:**

- Unable to disable cron for hourly rotations [\#136](https://github.com/voxpupuli/puppet-logrotate/issues/136)

**Merged pull requests:**

- Allow puppetlabs-stdlib 6 [\#156](https://github.com/voxpupuli/puppet-logrotate/pull/156) ([jaredledvina](https://github.com/jaredledvina))
- Remove deprecated and unused is\_hash function [\#155](https://github.com/voxpupuli/puppet-logrotate/pull/155) ([baurmatt](https://github.com/baurmatt))
- Remove occurences of su\_owner [\#148](https://github.com/voxpupuli/puppet-logrotate/pull/148) ([adriankirchner](https://github.com/adriankirchner))
- Document possible use of Array for paths [\#145](https://github.com/voxpupuli/puppet-logrotate/pull/145) ([dleske](https://github.com/dleske))

## [v3.4.0](https://github.com/voxpupuli/puppet-logrotate/tree/v3.4.0) (2018-10-06)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.3.0...v3.4.0)

**Breaking changes:**

- Remove unused parameter: logrotate::cron\_hourly\_file [\#140](https://github.com/voxpupuli/puppet-logrotate/pull/140) ([ruriky](https://github.com/ruriky))

**Implemented enhancements:**

- add support for Debian 8/9 and Ubuntu 18.04 [\#134](https://github.com/voxpupuli/puppet-logrotate/pull/134) ([rj667](https://github.com/rj667))
- Rebase\(2\) of Pull Request \#80 [\#128](https://github.com/voxpupuli/puppet-logrotate/pull/128) ([Heidistein](https://github.com/Heidistein))
- Enforce minimal string length on logrotate arguments. [\#127](https://github.com/voxpupuli/puppet-logrotate/pull/127) ([Heidistein](https://github.com/Heidistein))
- Allow cron to always mail its output. [\#124](https://github.com/voxpupuli/puppet-logrotate/pull/124) ([Heidistein](https://github.com/Heidistein))

**Fixed bugs:**

- Fix params for Ubuntu to ensure su is set [\#138](https://github.com/voxpupuli/puppet-logrotate/pull/138) ([acurus-puppetmaster](https://github.com/acurus-puppetmaster))

**Closed issues:**

- Rerelease 3.3.0 as 3.3.1 [\#121](https://github.com/voxpupuli/puppet-logrotate/issues/121)
- Missing tag and Puppet Forge release for 3.3.0 [\#120](https://github.com/voxpupuli/puppet-logrotate/issues/120)
- check debian support [\#114](https://github.com/voxpupuli/puppet-logrotate/issues/114)

**Merged pull requests:**

- modulesync 2.0.0 [\#142](https://github.com/voxpupuli/puppet-logrotate/pull/142) ([dhollinger](https://github.com/dhollinger))
- Release 3.4.0 and allow puppet 6.x [\#141](https://github.com/voxpupuli/puppet-logrotate/pull/141) ([dhollinger](https://github.com/dhollinger))
- enable acceptance tests centos 6/7 ubuntu 14/16 [\#135](https://github.com/voxpupuli/puppet-logrotate/pull/135) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#132](https://github.com/voxpupuli/puppet-logrotate/pull/132) ([bastelfreak](https://github.com/bastelfreak))

## [v3.3.0](https://github.com/voxpupuli/puppet-logrotate/tree/v3.3.0) (2018-06-25)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.2.1...v3.3.0)

**Implemented enhancements:**

- Allow change of file mode for generated files [\#70](https://github.com/voxpupuli/puppet-logrotate/issues/70)
- Fix freebsd default rules [\#111](https://github.com/voxpupuli/puppet-logrotate/pull/111) ([kapouik](https://github.com/kapouik))
- Fix Issue 70 add file mode parameters [\#109](https://github.com/voxpupuli/puppet-logrotate/pull/109) ([TJM](https://github.com/TJM))
- Use logrotate::cron rather than file resource for hourly cron [\#105](https://github.com/voxpupuli/puppet-logrotate/pull/105) ([pavloos](https://github.com/pavloos))
- Manage logrotate startup arguments [\#102](https://github.com/voxpupuli/puppet-logrotate/pull/102) ([ruriky](https://github.com/ruriky))

**Closed issues:**

- duplicate resource or dependency cycle when attempting to set default options [\#116](https://github.com/voxpupuli/puppet-logrotate/issues/116)

**Merged pull requests:**

- \(docs\) Update readme with warning note and bigger example of defaults [\#117](https://github.com/voxpupuli/puppet-logrotate/pull/117) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Remove docker nodesets [\#115](https://github.com/voxpupuli/puppet-logrotate/pull/115) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#113](https://github.com/voxpupuli/puppet-logrotate/pull/113) ([bastelfreak](https://github.com/bastelfreak))

## [v3.2.1](https://github.com/voxpupuli/puppet-logrotate/tree/v3.2.1) (2018-03-28)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.2.0...v3.2.1)

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#107](https://github.com/voxpupuli/puppet-logrotate/pull/107) ([bastelfreak](https://github.com/bastelfreak))

## [v3.2.0](https://github.com/voxpupuli/puppet-logrotate/tree/v3.2.0) (2018-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.1.0...v3.2.0)

**Implemented enhancements:**

- Deprecation warnings from newer stdlib [\#54](https://github.com/voxpupuli/puppet-logrotate/issues/54)
- Add option to not manage logrotate package [\#44](https://github.com/voxpupuli/puppet-logrotate/issues/44)
- Add manage\_package parameter [\#97](https://github.com/voxpupuli/puppet-logrotate/pull/97) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Make the creation of default \[bw\]tmp-rulesets configurable [\#65](https://github.com/voxpupuli/puppet-logrotate/pull/65) ([mcgege](https://github.com/mcgege))
- Add purge\_configdir to purge old configs [\#23](https://github.com/voxpupuli/puppet-logrotate/pull/23) ([patricktoelle](https://github.com/patricktoelle))

**Fixed bugs:**

- 'su root syslog' line missing in default logrotate.conf file for Ubuntu produced by this module [\#93](https://github.com/voxpupuli/puppet-logrotate/issues/93)
- Pattern matcher in Logrotate::UserOrGroup is too strict. Doesn't allow names with domain. [\#88](https://github.com/voxpupuli/puppet-logrotate/issues/88)
- Enum on package ensure is too restrictive [\#84](https://github.com/voxpupuli/puppet-logrotate/issues/84)
- logrotate::conf\[/etc/logrotate.conf\] [\#49](https://github.com/voxpupuli/puppet-logrotate/issues/49)
- copy and copytruncate marked in rules.pp as optional [\#31](https://github.com/voxpupuli/puppet-logrotate/issues/31)
- copytruncate =\> true affects logrotate::defaults wtmp and btmp rules [\#22](https://github.com/voxpupuli/puppet-logrotate/issues/22)
- Remove UserOrGroup type, use String [\#98](https://github.com/voxpupuli/puppet-logrotate/pull/98) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Allow logrotate version to be specified [\#96](https://github.com/voxpupuli/puppet-logrotate/pull/96) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Fix missing su line in default logrotate.conf on Ubuntu [\#92](https://github.com/voxpupuli/puppet-logrotate/pull/92) ([szponek](https://github.com/szponek))
- Add missing $maxsize option to Logrotate::Conf [\#90](https://github.com/voxpupuli/puppet-logrotate/pull/90) ([achermes](https://github.com/achermes))

**Closed issues:**

- parameter 'path' references an unresolved type 'Stdlib::UnixPath' [\#95](https://github.com/voxpupuli/puppet-logrotate/issues/95)
- logrotate::rule adds blank su to wtmp and btmp [\#41](https://github.com/voxpupuli/puppet-logrotate/issues/41)
- Add tests for all OSes for defaults.pp [\#3](https://github.com/voxpupuli/puppet-logrotate/issues/3)

**Merged pull requests:**

- Remove obsolete su parameter in documentation [\#91](https://github.com/voxpupuli/puppet-logrotate/pull/91) ([stefanandres](https://github.com/stefanandres))

## [v3.1.0](https://github.com/voxpupuli/puppet-logrotate/tree/v3.1.0) (2017-11-13)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.0.1...v3.1.0)

**Implemented enhancements:**

- Allow dateyesterday at the global level [\#83](https://github.com/voxpupuli/puppet-logrotate/pull/83) ([cliff-wakefield](https://github.com/cliff-wakefield))

**Fixed bugs:**

- Fix "Puppet Unknown variable: 'default\_su\_group'" [\#82](https://github.com/voxpupuli/puppet-logrotate/pull/82) ([mookie-](https://github.com/mookie-))

**Closed issues:**

- Config is not a string but a hash [\#77](https://github.com/voxpupuli/puppet-logrotate/issues/77)
- Support Ubuntu 16.04 [\#59](https://github.com/voxpupuli/puppet-logrotate/issues/59)
- Does this module attempt to apply the defaults for the GNU distribution? [\#48](https://github.com/voxpupuli/puppet-logrotate/issues/48)

## [v3.0.1](https://github.com/voxpupuli/puppet-logrotate/tree/v3.0.1) (2017-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v3.0.0...v3.0.1)

**Fixed bugs:**

- wrong datatype for $config, s/String/Hash [\#78](https://github.com/voxpupuli/puppet-logrotate/pull/78) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v3.0.0) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v2.0.0...v3.0.0)

**Closed issues:**

- Remove old CHANGELOG or merge with CHANGELOG.md [\#69](https://github.com/voxpupuli/puppet-logrotate/issues/69)

**Merged pull requests:**

- Fix changelog [\#73](https://github.com/voxpupuli/puppet-logrotate/pull/73) ([alexjfisher](https://github.com/alexjfisher))
- Added support for dateyesterday within logrotate::rule [\#71](https://github.com/voxpupuli/puppet-logrotate/pull/71) ([cliff-wakefield](https://github.com/cliff-wakefield))
- BREAKING: Introduce Puppet 4 datatypes and drop Puppet 3 support [\#68](https://github.com/voxpupuli/puppet-logrotate/pull/68) ([mmerfort](https://github.com/mmerfort))

## [v2.0.0](https://github.com/voxpupuli/puppet-logrotate/tree/v2.0.0) (2017-05-25)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v1.4.0...v2.0.0)

**Closed issues:**

- Logrotate rule ERB template should not take variables from the scope object [\#37](https://github.com/voxpupuli/puppet-logrotate/issues/37)
- Ubuntu Xenial 16.04 compaibility [\#34](https://github.com/voxpupuli/puppet-logrotate/issues/34)
- string 'undef' now treated as undef [\#26](https://github.com/voxpupuli/puppet-logrotate/issues/26)
- Allow adjustment of OS-specific defaults [\#9](https://github.com/voxpupuli/puppet-logrotate/issues/9)

**Merged pull requests:**

- Fix typo [\#58](https://github.com/voxpupuli/puppet-logrotate/pull/58) ([gabe-sky](https://github.com/gabe-sky))
- Adding support for maxsize also in main config [\#57](https://github.com/voxpupuli/puppet-logrotate/pull/57) ([seefood](https://github.com/seefood))
- Fix rubocop checks [\#53](https://github.com/voxpupuli/puppet-logrotate/pull/53) ([coreone](https://github.com/coreone))
- Fixes \#34 - Ubuntu Xenial and up support [\#43](https://github.com/voxpupuli/puppet-logrotate/pull/43) ([edestecd](https://github.com/edestecd))
- Fixes \#37 - Logrotate rule ERB template should not take variables from the scope object [\#38](https://github.com/voxpupuli/puppet-logrotate/pull/38) ([imriz](https://github.com/imriz))
- Fix puppet-lint issues and bad style [\#32](https://github.com/voxpupuli/puppet-logrotate/pull/32) ([baurmatt](https://github.com/baurmatt))
- Add gentoo support [\#27](https://github.com/voxpupuli/puppet-logrotate/pull/27) ([baurmatt](https://github.com/baurmatt))

## [v1.4.0](https://github.com/voxpupuli/puppet-logrotate/tree/v1.4.0) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v1.3.0...v1.4.0)

**Closed issues:**

- Optional config settings are no longer optional?!? [\#29](https://github.com/voxpupuli/puppet-logrotate/issues/29)
- wtmp and btmp are different when using the future parser [\#13](https://github.com/voxpupuli/puppet-logrotate/issues/13)

**Merged pull requests:**

- Changed default string "undef" to "UNDEFINED" to work around this bug… [\#28](https://github.com/voxpupuli/puppet-logrotate/pull/28) ([durist](https://github.com/durist))
- Fix typo in README.md [\#25](https://github.com/voxpupuli/puppet-logrotate/pull/25) ([siebrand](https://github.com/siebrand))
- Added ability to override default btmp and/or wtmp [\#21](https://github.com/voxpupuli/puppet-logrotate/pull/21) ([ncsutmf](https://github.com/ncsutmf))
- remove special whitespace character [\#20](https://github.com/voxpupuli/puppet-logrotate/pull/20) ([jfroche](https://github.com/jfroche))
- Update Gemfile for Rake/Ruby version dependencies [\#19](https://github.com/voxpupuli/puppet-logrotate/pull/19) ([ncsutmf](https://github.com/ncsutmf))
- add official puppet 4 support [\#17](https://github.com/voxpupuli/puppet-logrotate/pull/17) ([mmckinst](https://github.com/mmckinst))

## [v1.3.0](https://github.com/voxpupuli/puppet-logrotate/tree/v1.3.0) (2015-11-05)

[Full Changelog](https://github.com/voxpupuli/puppet-logrotate/compare/v1.2.8...v1.3.0)

**Closed issues:**

- The logrotate package should be 'present' by default, or at least tunable [\#11](https://github.com/voxpupuli/puppet-logrotate/issues/11)

**Merged pull requests:**

- Set default package ensure value to 'installed' [\#12](https://github.com/voxpupuli/puppet-logrotate/pull/12) ([natemccurdy](https://github.com/natemccurdy))
- Add support for maxsize directive [\#10](https://github.com/voxpupuli/puppet-logrotate/pull/10) ([zeromind](https://github.com/zeromind))

## v1.2.8 (2015-09-14)

- Fix hidden unicode character (#8)
- Allow config to be passed in as an hash (#6)
- Fix dependency issue (#7)
- refactor main class (mostly to facilitate #7)
- update test environment to use puppet 4
- switch stdlib fixture to https source

## v1.2.7 (2015-05-06)

- Metadata-only release (just bumped version)

## v1.2.6 (2015-05-06)

- Fix test failures on future parser

## v1.2.5 (2015-05-06)

- Switch some validation code to use validate_re

## v1.2.4 (2015-05-06)

- Add puppet-lint exclusions

## v1.2.3 (2015-05-06)

- More work on testing
- fix warning when running puppet module list caused by "-" instead of "/" in dependencies in metadata

## v1.2.3 (2015-05-06)

- removed (pushed without CHANGELOG update

## v1.2.1 (2015-05-06)

- Update tests, Rakefile, etc.

## v1.2.0 (2015-03-25)

- First release to puppetforge


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
