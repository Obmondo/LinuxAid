# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v7.1.0](https://github.com/voxpupuli/puppet-yum/tree/v7.1.0) (2023-06-26)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v7.0.0...v7.1.0)

**Implemented enhancements:**

- Add yum::copr resource to handle COPR repositories. [\#215](https://github.com/voxpupuli/puppet-yum/pull/215) ([olifre](https://github.com/olifre))

## [v7.0.0](https://github.com/voxpupuli/puppet-yum/tree/v7.0.0) (2023-06-16)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v6.2.0...v7.0.0)

**Breaking changes:**

- puppetlabs/stdlib: Require 9.x [\#315](https://github.com/voxpupuli/puppet-yum/pull/315) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 6 support [\#304](https://github.com/voxpupuli/puppet-yum/pull/304) ([bastelfreak](https://github.com/bastelfreak))
- add Fedora 38, drop Fedora 35 [\#303](https://github.com/voxpupuli/puppet-yum/pull/303) ([vchepkov](https://github.com/vchepkov))

**Implemented enhancements:**

- Add Puppet 8 support [\#314](https://github.com/voxpupuli/puppet-yum/pull/314) ([bastelfreak](https://github.com/bastelfreak))
- New yum::groups parameter to manage groups [\#311](https://github.com/voxpupuli/puppet-yum/pull/311) ([traylenator](https://github.com/traylenator))
- allow puppetlabs/concat 8.x [\#302](https://github.com/voxpupuli/puppet-yum/pull/302) ([vchepkov](https://github.com/vchepkov))
- Add RHEL 9 to supported OS [\#300](https://github.com/voxpupuli/puppet-yum/pull/300) ([tuxmea](https://github.com/tuxmea))

**Fixed bugs:**

- Almalinux 9.2 shows these repos as `-debuginfo` [\#312](https://github.com/voxpupuli/puppet-yum/pull/312) ([jcpunk](https://github.com/jcpunk))
- Fix purge of unwanted kernels on DNF based machines [\#309](https://github.com/voxpupuli/puppet-yum/pull/309) ([traylenator](https://github.com/traylenator))
- Use dnf or yum augeas path for main configuration [\#307](https://github.com/voxpupuli/puppet-yum/pull/307) ([traylenator](https://github.com/traylenator))
- add missing RPM-GPG-KEY-EPEL-9 [\#299](https://github.com/voxpupuli/puppet-yum/pull/299) ([vchepkov](https://github.com/vchepkov))

**Merged pull requests:**

- Fix acceptance tests for Fedora 36 [\#308](https://github.com/voxpupuli/puppet-yum/pull/308) ([traylenator](https://github.com/traylenator))

## [v6.2.0](https://github.com/voxpupuli/puppet-yum/tree/v6.2.0) (2023-02-08)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v6.1.0...v6.2.0)

**Implemented enhancements:**

- add Fedora 37 support [\#284](https://github.com/voxpupuli/puppet-yum/pull/284) ([vchepkov](https://github.com/vchepkov))
- Deploying multiple gpgkey in one repo [\#278](https://github.com/voxpupuli/puppet-yum/pull/278) ([teluq-pbrideau](https://github.com/teluq-pbrideau))

**Fixed bugs:**

- Revert \#258 that added purge\_unmanaged\_repos [\#285](https://github.com/voxpupuli/puppet-yum/issues/285)
- Revert \#258, which added purge\_unmanaged\_repos [\#287](https://github.com/voxpupuli/puppet-yum/pull/287) ([kenyon](https://github.com/kenyon))

**Merged pull requests:**

- README: fix typos [\#288](https://github.com/voxpupuli/puppet-yum/pull/288) ([kenyon](https://github.com/kenyon))
- README: remove yumrepo.target in example [\#286](https://github.com/voxpupuli/puppet-yum/pull/286) ([kenyon](https://github.com/kenyon))

## [v6.1.0](https://github.com/voxpupuli/puppet-yum/tree/v6.1.0) (2022-11-08)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v6.0.0...v6.1.0)

**Implemented enhancements:**

- add AlmaLinux 9 support [\#281](https://github.com/voxpupuli/puppet-yum/pull/281) ([jhoblitt](https://github.com/jhoblitt))
- Add sensitive support for configs [\#275](https://github.com/voxpupuli/puppet-yum/pull/275) ([teluq-pbrideau](https://github.com/teluq-pbrideau))

**Fixed bugs:**

- fix puppet-lint errors [\#282](https://github.com/voxpupuli/puppet-yum/pull/282) ([jhoblitt](https://github.com/jhoblitt))

## [v6.0.0](https://github.com/voxpupuli/puppet-yum/tree/v6.0.0) (2022-08-04)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.6.1...v6.0.0)

**Breaking changes:**

- manage $repodir only if $purge\_unmanaged\_repos is enabled [\#271](https://github.com/voxpupuli/puppet-yum/pull/271) ([vchepkov](https://github.com/vchepkov))

**Implemented enhancements:**

- add Fedora support [\#270](https://github.com/voxpupuli/puppet-yum/pull/270) ([vchepkov](https://github.com/vchepkov))

## [v5.6.1](https://github.com/voxpupuli/puppet-yum/tree/v5.6.1) (2022-07-06)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.6.0...v5.6.1)

**Fixed bugs:**

- bugfix: typo in appstream repo [\#267](https://github.com/voxpupuli/puppet-yum/pull/267) ([jcpunk](https://github.com/jcpunk))
- Remove obsolete repos from CentOS 9 [\#266](https://github.com/voxpupuli/puppet-yum/pull/266) ([jcpunk](https://github.com/jcpunk))

## [v5.6.0](https://github.com/voxpupuli/puppet-yum/tree/v5.6.0) (2022-07-04)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.5.0...v5.6.0)

**Implemented enhancements:**

- Add RPMFusion repos [\#261](https://github.com/voxpupuli/puppet-yum/pull/261) ([jcpunk](https://github.com/jcpunk))
- Add CentOS Stream9 repos [\#259](https://github.com/voxpupuli/puppet-yum/pull/259) ([jcpunk](https://github.com/jcpunk))
- Permit easily purging unmanaged repos [\#258](https://github.com/voxpupuli/puppet-yum/pull/258) ([jcpunk](https://github.com/jcpunk))

**Fixed bugs:**

- Ensure any/all GPG keys are installed before attempting to install yum-utils [\#263](https://github.com/voxpupuli/puppet-yum/pull/263) ([bschonec](https://github.com/bschonec))

**Merged pull requests:**

- Simplify EPEL definitions for EL8/9 [\#260](https://github.com/voxpupuli/puppet-yum/pull/260) ([jcpunk](https://github.com/jcpunk))

## [v5.5.0](https://github.com/voxpupuli/puppet-yum/tree/v5.5.0) (2022-06-20)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.4.0...v5.5.0)

**Implemented enhancements:**

- Add `require_verify` option to install.pp [\#244](https://github.com/voxpupuli/puppet-yum/pull/244) ([jcpunk](https://github.com/jcpunk))

**Fixed bugs:**

- Avoid assumption that package\_provider is set [\#255](https://github.com/voxpupuli/puppet-yum/pull/255) ([traylenator](https://github.com/traylenator))

**Merged pull requests:**

- Finish out dnf path for versionlock. [\#253](https://github.com/voxpupuli/puppet-yum/pull/253) ([jcpunk](https://github.com/jcpunk))

## [v5.4.0](https://github.com/voxpupuli/puppet-yum/tree/v5.4.0) (2022-04-25)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.3.1...v5.4.0)

**Implemented enhancements:**

- sync with upstream AlmaLinux repository set [\#249](https://github.com/voxpupuli/puppet-yum/pull/249) ([vchepkov](https://github.com/vchepkov))
- Allow arch aarch64 in yum::versionlock [\#239](https://github.com/voxpupuli/puppet-yum/pull/239) ([traylenator](https://github.com/traylenator))

**Fixed bugs:**

- failovermethod parameter doesn't exist in dnf [\#250](https://github.com/voxpupuli/puppet-yum/pull/250) ([vchepkov](https://github.com/vchepkov))
- RHEL8: Fix epel-modular repo names [\#247](https://github.com/voxpupuli/puppet-yum/pull/247) ([ccolic](https://github.com/ccolic))
- fix centos8 HA yumrepo target [\#241](https://github.com/voxpupuli/puppet-yum/pull/241) ([vchepkov](https://github.com/vchepkov))

**Closed issues:**

- Use of  puppetlabs-yumrepo\_core [\#248](https://github.com/voxpupuli/puppet-yum/issues/248)
- RHEL8, epel-modular is installed with the wrong repo-name [\#246](https://github.com/voxpupuli/puppet-yum/issues/246)

**Merged pull requests:**

- rubocop: autofix [\#251](https://github.com/voxpupuli/puppet-yum/pull/251) ([bastelfreak](https://github.com/bastelfreak))

## [v5.3.1](https://github.com/voxpupuli/puppet-yum/tree/v5.3.1) (2022-02-15)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.3.0...v5.3.1)

**Fixed bugs:**

- yamllint failure on VirtuozzoLinux/7.yaml - duplication of key gpgkey [\#236](https://github.com/voxpupuli/puppet-yum/pull/236) ([bastelfreak](https://github.com/bastelfreak))
- CentOS 8 has been archived [\#234](https://github.com/voxpupuli/puppet-yum/pull/234) ([vchepkov](https://github.com/vchepkov))

**Merged pull requests:**

- Fix examples in manifests/versionlock.pp [\#233](https://github.com/voxpupuli/puppet-yum/pull/233) ([yakatz](https://github.com/yakatz))
- cleanup .fixtures.yml [\#230](https://github.com/voxpupuli/puppet-yum/pull/230) ([bastelfreak](https://github.com/bastelfreak))

## [v5.3.0](https://github.com/voxpupuli/puppet-yum/tree/v5.3.0) (2021-10-26)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.2.0...v5.3.0)

**Implemented enhancements:**

-  add CentOS 8 default repos [\#225](https://github.com/voxpupuli/puppet-yum/pull/225) ([oniGino](https://github.com/oniGino))

## [v5.2.0](https://github.com/voxpupuli/puppet-yum/tree/v5.2.0) (2021-09-29)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.1.0...v5.2.0)

**Implemented enhancements:**

- synchronize Rocky repositories with upstream definitions [\#217](https://github.com/voxpupuli/puppet-yum/pull/217) ([vchepkov](https://github.com/vchepkov))
- New type yum::post\_transaction\_action [\#216](https://github.com/voxpupuli/puppet-yum/pull/216) ([traylenator](https://github.com/traylenator))

**Closed issues:**

- Centos 6 support broken [\#198](https://github.com/voxpupuli/puppet-yum/issues/198)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#221](https://github.com/voxpupuli/puppet-yum/pull/221) ([smortex](https://github.com/smortex))
- Render post\_transaction\_action examples correctly [\#218](https://github.com/voxpupuli/puppet-yum/pull/218) ([traylenator](https://github.com/traylenator))

## [v5.1.0](https://github.com/voxpupuli/puppet-yum/tree/v5.1.0) (2021-06-10)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v5.0.0...v5.1.0)

**Implemented enhancements:**

- Add support for AlmaLinux 8 [\#203](https://github.com/voxpupuli/puppet-yum/pull/203) ([tparkercbn](https://github.com/tparkercbn))

## [v5.0.0](https://github.com/voxpupuli/puppet-yum/tree/v5.0.0) (2021-06-09)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v4.3.0...v5.0.0)

**Breaking changes:**

- Drop EoL Fedora support [\#211](https://github.com/voxpupuli/puppet-yum/pull/211) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Puppet 5; Add Puppet 7 support [\#208](https://github.com/voxpupuli/puppet-yum/pull/208) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL CentOS 6 support [\#207](https://github.com/voxpupuli/puppet-yum/pull/207) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add support for rocky linux [\#212](https://github.com/voxpupuli/puppet-yum/pull/212) ([TheMeier](https://github.com/TheMeier))

**Fixed bugs:**

- fix package name for yum plugin versionlock on RHEL/CentOS 8 [\#205](https://github.com/voxpupuli/puppet-yum/pull/205) ([TheMeier](https://github.com/TheMeier))

**Closed issues:**

- gpgkey cannot specify more than one of content, source [\#204](https://github.com/voxpupuli/puppet-yum/issues/204)
- yum::plugin::versionlock fails on CentOS/RHEL 8 [\#197](https://github.com/voxpupuli/puppet-yum/issues/197)
- No Repos getting added [\#168](https://github.com/voxpupuli/puppet-yum/issues/168)
- module doesn't manage proxy setting [\#157](https://github.com/voxpupuli/puppet-yum/issues/157)

**Merged pull requests:**

- puppetlabs/concat: allow 7.x [\#210](https://github.com/voxpupuli/puppet-yum/pull/210) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: allow 7.x [\#209](https://github.com/voxpupuli/puppet-yum/pull/209) ([bastelfreak](https://github.com/bastelfreak))
- Resolve puppet-lint [\#192](https://github.com/voxpupuli/puppet-yum/pull/192) ([jcpunk](https://github.com/jcpunk))
- modulesync 3.0.0 & puppet-lint updates [\#188](https://github.com/voxpupuli/puppet-yum/pull/188) ([bastelfreak](https://github.com/bastelfreak))

## [v4.3.0](https://github.com/voxpupuli/puppet-yum/tree/v4.3.0) (2020-07-20)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v4.2.0...v4.3.0)

**Implemented enhancements:**

- Improve extraction of available updates [\#181](https://github.com/voxpupuli/puppet-yum/pull/181) ([smortex](https://github.com/smortex))
- Use simpler code for tests for expected failures [\#173](https://github.com/voxpupuli/puppet-yum/pull/173) ([traylenator](https://github.com/traylenator))

**Fixed bugs:**

- De-duplicate start of string match character [\#179](https://github.com/voxpupuli/puppet-yum/pull/179) ([traylenator](https://github.com/traylenator))
- versionlock must specify at least .\* for arch. [\#177](https://github.com/voxpupuli/puppet-yum/pull/177) ([traylenator](https://github.com/traylenator))

**Closed issues:**

- yum\_package\_updates fact misinterprets output [\#180](https://github.com/voxpupuli/puppet-yum/issues/180)

**Merged pull requests:**

- prepare release 4.3.0 [\#186](https://github.com/voxpupuli/puppet-yum/pull/186) ([vchepkov](https://github.com/vchepkov))
- Add dnf tag to metadata [\#175](https://github.com/voxpupuli/puppet-yum/pull/175) ([traylenator](https://github.com/traylenator))

## [v4.2.0](https://github.com/voxpupuli/puppet-yum/tree/v4.2.0) (2020-05-22)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v4.1.1...v4.2.0)

**Implemented enhancements:**

- Enable and add CentOS 8 accept tests [\#172](https://github.com/voxpupuli/puppet-yum/pull/172) ([traylenator](https://github.com/traylenator))
- Support paramatized yum::versionlock [\#169](https://github.com/voxpupuli/puppet-yum/pull/169) ([traylenator](https://github.com/traylenator))
- Add gpg key for EPEL8 [\#166](https://github.com/voxpupuli/puppet-yum/pull/166) ([thomasmeeus](https://github.com/thomasmeeus))
- Add support for yum facts \(similar to the apt ones\) [\#141](https://github.com/voxpupuli/puppet-yum/pull/141) ([smortex](https://github.com/smortex))

**Closed issues:**

- Rhel/Centos 8 versionlock doesn't work [\#150](https://github.com/voxpupuli/puppet-yum/issues/150)

**Merged pull requests:**

- Remove nested code blocks from string docs [\#171](https://github.com/voxpupuli/puppet-yum/pull/171) ([traylenator](https://github.com/traylenator))
- Correct bolt URL [\#170](https://github.com/voxpupuli/puppet-yum/pull/170) ([traylenator](https://github.com/traylenator))
- Fix several markdown lint issues [\#167](https://github.com/voxpupuli/puppet-yum/pull/167) ([dhoppe](https://github.com/dhoppe))
- Use voxpupuli-acceptance [\#163](https://github.com/voxpupuli/puppet-yum/pull/163) ([ekohl](https://github.com/ekohl))
- Fix yaml indentation inconsistency [\#161](https://github.com/voxpupuli/puppet-yum/pull/161) ([b3n4kh](https://github.com/b3n4kh))

## [v4.1.1](https://github.com/voxpupuli/puppet-yum/tree/v4.1.1) (2020-03-09)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v4.1.0...v4.1.1)

**Fixed bugs:**

- Fedora/CentOS8: Ensure yum-utils/dnf-utils are present [\#159](https://github.com/voxpupuli/puppet-yum/pull/159) ([KeithWard](https://github.com/KeithWard))

**Closed issues:**

- CentOS/RHEL 8 Uses DNF but utils package is provided by yum-utils. [\#158](https://github.com/voxpupuli/puppet-yum/issues/158)

**Merged pull requests:**

- Support ensuring all yum group packages are installed [\#140](https://github.com/voxpupuli/puppet-yum/pull/140) ([treydock](https://github.com/treydock))

## [v4.1.0](https://github.com/voxpupuli/puppet-yum/tree/v4.1.0) (2020-01-20)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- add 'VirtuozzoLinux' support [\#147](https://github.com/voxpupuli/puppet-yum/pull/147) ([kBite](https://github.com/kBite))
- Support for DNF-based distros, and Fedora defaults [\#143](https://github.com/voxpupuli/puppet-yum/pull/143) ([optiz0r](https://github.com/optiz0r))
- Updated utils package for RHEL 8 [\#137](https://github.com/voxpupuli/puppet-yum/pull/137) ([rcalixte](https://github.com/rcalixte))

**Fixed bugs:**

- `require` \(not `contain`\) yum::plugin::versionlock [\#154](https://github.com/voxpupuli/puppet-yum/pull/154) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- instantiate yumrepo & yum::config directly [\#148](https://github.com/voxpupuli/puppet-yum/pull/148) ([igalic](https://github.com/igalic))
- Clean up acceptance spec helper [\#146](https://github.com/voxpupuli/puppet-yum/pull/146) ([ekohl](https://github.com/ekohl))
- use $facts when accessing os fact [\#144](https://github.com/voxpupuli/puppet-yum/pull/144) ([igalic](https://github.com/igalic))
- add requirement expression in metadata of task [\#138](https://github.com/voxpupuli/puppet-yum/pull/138) ([Dan33l](https://github.com/Dan33l))
- Update concat dependency to allow puppetlabs/concat 6.x [\#136](https://github.com/voxpupuli/puppet-yum/pull/136) ([treydock](https://github.com/treydock))
- Allow `puppetlabs/stdlib` 6.x [\#135](https://github.com/voxpupuli/puppet-yum/pull/135) ([alexjfisher](https://github.com/alexjfisher))

## [v4.0.0](https://github.com/voxpupuli/puppet-yum/tree/v4.0.0) (2019-05-07)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v3.1.1...v4.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#133](https://github.com/voxpupuli/puppet-yum/pull/133) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add optional parameters to groupinstall [\#86](https://github.com/voxpupuli/puppet-yum/pull/86) ([jfroche](https://github.com/jfroche))

**Fixed bugs:**

- Correctly calculate rpmname for all gpg versions [\#126](https://github.com/voxpupuli/puppet-yum/pull/126) ([towo](https://github.com/towo))
- Puppet 6 issue and knockout\_prefix problem [\#121](https://github.com/voxpupuli/puppet-yum/pull/121) ([avidspartan1](https://github.com/avidspartan1))

**Closed issues:**

- gpgkey applied on every run due to output change [\#125](https://github.com/voxpupuli/puppet-yum/issues/125)
- In Puppet 6, remove\_undef\_values doesn't work as expected [\#120](https://github.com/voxpupuli/puppet-yum/issues/120)
- --knock-out-prefix "--" knocks out valid content of yum::gpgkeys  [\#111](https://github.com/voxpupuli/puppet-yum/issues/111)
- removal of mirrorlist is set by 'absent' not by using a knockout. [\#63](https://github.com/voxpupuli/puppet-yum/issues/63)

**Merged pull requests:**

- replace deprecated has\_key\(\) with `in` [\#129](https://github.com/voxpupuli/puppet-yum/pull/129) ([bastelfreak](https://github.com/bastelfreak))

## [v3.1.1](https://github.com/voxpupuli/puppet-yum/tree/v3.1.1) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v3.1.0...v3.1.1)

**Closed issues:**

- Import GPG keys of unmanaged repos [\#114](https://github.com/voxpupuli/puppet-yum/issues/114)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#124](https://github.com/voxpupuli/puppet-yum/pull/124) ([bastelfreak](https://github.com/bastelfreak))
- Allow puppetlabs/stdlib 5.x and puppetlabs/concat 5.x [\#113](https://github.com/voxpupuli/puppet-yum/pull/113) ([bastelfreak](https://github.com/bastelfreak))

## [v3.1.0](https://github.com/voxpupuli/puppet-yum/tree/v3.1.0) (2018-07-24)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- \(\#107\) YUM update puppet task support [\#108](https://github.com/voxpupuli/puppet-yum/pull/108) ([catay](https://github.com/catay))

**Closed issues:**

- feature yum update puppet task support [\#107](https://github.com/voxpupuli/puppet-yum/issues/107)

## [v3.0.0](https://github.com/voxpupuli/puppet-yum/tree/v3.0.0) (2018-07-09)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.2.1...v3.0.0)

**Breaking changes:**

- Remove fastestmirror\_enabled and report\_instanceid parameters [\#103](https://github.com/voxpupuli/puppet-yum/pull/103) ([Zordrak](https://github.com/Zordrak))

**Implemented enhancements:**

- EPEL GPG Key [\#95](https://github.com/voxpupuli/puppet-yum/issues/95)
- Clean yum metadata after versionlock file update [\#102](https://github.com/voxpupuli/puppet-yum/pull/102) ([traylenator](https://github.com/traylenator))
- Fixes \#95 Add EPEL GPG Key and logic to handle yum::gpgkeys [\#96](https://github.com/voxpupuli/puppet-yum/pull/96) ([TJM](https://github.com/TJM))

**Fixed bugs:**

- Don't litter /root/ with GPG-related files. [\#56](https://github.com/voxpupuli/puppet-yum/pull/56) ([djl](https://github.com/djl))

**Closed issues:**

- Amazon Linux manage\_os\_default\_repos does not compile due to unsupported parameters [\#100](https://github.com/voxpupuli/puppet-yum/issues/100)
- how does the module get the name of the package? [\#50](https://github.com/voxpupuli/puppet-yum/issues/50)

**Merged pull requests:**

- drop EOL OSs; fix puppet version range [\#101](https://github.com/voxpupuli/puppet-yum/pull/101) ([bastelfreak](https://github.com/bastelfreak))
- Rely on beaker-hostgenerator for docker nodesets [\#98](https://github.com/voxpupuli/puppet-yum/pull/98) ([ekohl](https://github.com/ekohl))

## [v2.2.1](https://github.com/voxpupuli/puppet-yum/tree/v2.2.1) (2018-03-28)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.2.0...v2.2.1)

**Fixed bugs:**

- Hiera 5 warning on puppet 5.3.2 [\#77](https://github.com/voxpupuli/puppet-yum/issues/77)

**Closed issues:**

- Unable to exclude multiple packages in yum.conf [\#80](https://github.com/voxpupuli/puppet-yum/issues/80)

**Merged pull requests:**

- update required Puppet version in the documentation [\#88](https://github.com/voxpupuli/puppet-yum/pull/88) ([joekohlsdorf](https://github.com/joekohlsdorf))
- migrate Hiera 4 to Hiera 5 [\#87](https://github.com/voxpupuli/puppet-yum/pull/87) ([joekohlsdorf](https://github.com/joekohlsdorf))

## [v2.2.0](https://github.com/voxpupuli/puppet-yum/tree/v2.2.0) (2018-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.1.0...v2.2.0)

**Fixed bugs:**

- Fix EPEL repo IDs [\#81](https://github.com/voxpupuli/puppet-yum/pull/81) ([lamawithonel](https://github.com/lamawithonel))

**Closed issues:**

- Add RHEL repos and tests. [\#76](https://github.com/voxpupuli/puppet-yum/issues/76)
- Add support for AmazonLinux 2017 [\#72](https://github.com/voxpupuli/puppet-yum/issues/72)
- EPEL managed\_repo broken [\#53](https://github.com/voxpupuli/puppet-yum/issues/53)

**Merged pull requests:**

- bump lowest puppet version 4.6.1-\>4.10.9 [\#85](https://github.com/voxpupuli/puppet-yum/pull/85) ([bastelfreak](https://github.com/bastelfreak))
- Fix documentation instructions for mirrorlist [\#83](https://github.com/voxpupuli/puppet-yum/pull/83) ([jorhett](https://github.com/jorhett))
- Run beaker tests on all supported & available docker sets [\#79](https://github.com/voxpupuli/puppet-yum/pull/79) ([ekohl](https://github.com/ekohl))
- Add RHEL repos and update README. [\#75](https://github.com/voxpupuli/puppet-yum/pull/75) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v2.1.0](https://github.com/voxpupuli/puppet-yum/tree/v2.1.0) (2017-11-02)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.2...v2.1.0)

**Implemented enhancements:**

- Add AmazonLinux 2017 compatibility. [\#71](https://github.com/voxpupuli/puppet-yum/pull/71) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v2.0.2](https://github.com/voxpupuli/puppet-yum/tree/v2.0.2) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.1...v2.0.2)

**Closed issues:**

- concat dependency update [\#57](https://github.com/voxpupuli/puppet-yum/issues/57)
- Yumrepo provider fork? [\#32](https://github.com/voxpupuli/puppet-yum/issues/32)

**Merged pull requests:**

- Release 2.0.2 [\#70](https://github.com/voxpupuli/puppet-yum/pull/70) ([bastelfreak](https://github.com/bastelfreak))
- Update README.md [\#69](https://github.com/voxpupuli/puppet-yum/pull/69) ([arjenz](https://github.com/arjenz))
- Emtpy hiera files throw puppet 4 warnings [\#67](https://github.com/voxpupuli/puppet-yum/pull/67) ([benohara](https://github.com/benohara))

## [v2.0.1](https://github.com/voxpupuli/puppet-yum/tree/v2.0.1) (2017-09-01)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v2.0.0...v2.0.1)

**Implemented enhancements:**

- Update concat dependency [\#58](https://github.com/voxpupuli/puppet-yum/pull/58) ([cdenneen](https://github.com/cdenneen))

**Fixed bugs:**

- Drop empty yaml file [\#55](https://github.com/voxpupuli/puppet-yum/pull/55) ([traylenator](https://github.com/traylenator))

**Closed issues:**

- Update to puppetlabs/concat 3 or 4 [\#66](https://github.com/voxpupuli/puppet-yum/issues/66)
- yum::versionlock with ensure =\> absent doesn't purge entries [\#61](https://github.com/voxpupuli/puppet-yum/issues/61)
- versionlock.list updated after package {} install [\#43](https://github.com/voxpupuli/puppet-yum/issues/43)

**Merged pull requests:**

- Contain the versionlock subclass to help with ordering around package resources [\#65](https://github.com/voxpupuli/puppet-yum/pull/65) ([bovy89](https://github.com/bovy89))
- Support `ensure => absent` with yum::versionlock [\#62](https://github.com/voxpupuli/puppet-yum/pull/62) ([bovy89](https://github.com/bovy89))

## [v2.0.0](https://github.com/voxpupuli/puppet-yum/tree/v2.0.0) (2017-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v1.0.0...v2.0.0)

**Breaking changes:**

- BREAKING: Config create resources pattern [\#37](https://github.com/voxpupuli/puppet-yum/pull/37) ([lamawithonel](https://github.com/lamawithonel))

**Implemented enhancements:**

- Add module data for EPEL [\#44](https://github.com/voxpupuli/puppet-yum/pull/44) ([lamawithonel](https://github.com/lamawithonel))
- Manage yumrepos via data [\#40](https://github.com/voxpupuli/puppet-yum/pull/40) ([lamawithonel](https://github.com/lamawithonel))
- Update README.md [\#39](https://github.com/voxpupuli/puppet-yum/pull/39) ([jskarpe](https://github.com/jskarpe))
- Be more strict about versionlock strings [\#38](https://github.com/voxpupuli/puppet-yum/pull/38) ([lamawithonel](https://github.com/lamawithonel))

**Fixed bugs:**

- Versionlock release string may contain dots [\#49](https://github.com/voxpupuli/puppet-yum/pull/49) ([traylenator](https://github.com/traylenator))
- Fix typo. [\#45](https://github.com/voxpupuli/puppet-yum/pull/45) ([johntconklin](https://github.com/johntconklin))
- Remove `section` parameter from `yum::config` [\#33](https://github.com/voxpupuli/puppet-yum/pull/33) ([lamawithonel](https://github.com/lamawithonel))

**Closed issues:**

- Class\[Yum\]: has no parameter named 'config\_options' [\#48](https://github.com/voxpupuli/puppet-yum/issues/48)
- Augeas errors arise when applying yum settings on Cent OS 6 clients [\#47](https://github.com/voxpupuli/puppet-yum/issues/47)
- Remove individual configs from init.pp, use create\_resources pattern instead [\#36](https://github.com/voxpupuli/puppet-yum/issues/36)
- Fix versionlock regex [\#35](https://github.com/voxpupuli/puppet-yum/issues/35)
-  yum::config fails with comma separated values [\#21](https://github.com/voxpupuli/puppet-yum/issues/21)

## [v1.0.0](https://github.com/voxpupuli/puppet-yum/tree/v1.0.0) (2017-01-14)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.10.0...v1.0.0)

**Implemented enhancements:**

- Update for Puppet 4, remove support for Puppet 3 [\#25](https://github.com/voxpupuli/puppet-yum/pull/25) ([lamawithonel](https://github.com/lamawithonel))

**Merged pull requests:**

- Comma separated values for assumeyes [\#29](https://github.com/voxpupuli/puppet-yum/pull/29) ([matonb](https://github.com/matonb))

## [v0.10.0](https://github.com/voxpupuli/puppet-yum/tree/v0.10.0) (2017-01-11)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.15...v0.10.0)

**Implemented enhancements:**

- Bump min version\_requirement for Puppet + deps [\#22](https://github.com/voxpupuli/puppet-yum/pull/22) ([juniorsysadmin](https://github.com/juniorsysadmin))
- Add parameter clean\_old\_kernels [\#20](https://github.com/voxpupuli/puppet-yum/pull/20) ([treydock](https://github.com/treydock))
- Correct format of fixtures file. [\#14](https://github.com/voxpupuli/puppet-yum/pull/14) ([traylenator](https://github.com/traylenator))

## [v0.9.15](https://github.com/voxpupuli/puppet-yum/tree/v0.9.15) (2016-09-26)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.14...v0.9.15)

**Merged pull requests:**

- Update changelog and version [\#12](https://github.com/voxpupuli/puppet-yum/pull/12) ([jskarpe](https://github.com/jskarpe))
- Added basic spec tests [\#11](https://github.com/voxpupuli/puppet-yum/pull/11) ([jskarpe](https://github.com/jskarpe))
- Bug: Puppet creates empty key files when using Hiera and create\_resources\(\) [\#7](https://github.com/voxpupuli/puppet-yum/pull/7) ([lklimek](https://github.com/lklimek))
- Manage yum::versionlock with concat [\#6](https://github.com/voxpupuli/puppet-yum/pull/6) ([jpoittevin](https://github.com/jpoittevin))

## [v0.9.14](https://github.com/voxpupuli/puppet-yum/tree/v0.9.14) (2016-08-15)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.13...v0.9.14)

**Merged pull requests:**

- Release 0.9.14 [\#5](https://github.com/voxpupuli/puppet-yum/pull/5) ([jyaworski](https://github.com/jyaworski))

## [v0.9.13](https://github.com/voxpupuli/puppet-yum/tree/v0.9.13) (2016-08-15)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.12...v0.9.13)

**Merged pull requests:**

- Release 0.9.13 [\#4](https://github.com/voxpupuli/puppet-yum/pull/4) ([jyaworski](https://github.com/jyaworski))

## [v0.9.12](https://github.com/voxpupuli/puppet-yum/tree/v0.9.12) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.11...v0.9.12)

## [v0.9.11](https://github.com/voxpupuli/puppet-yum/tree/v0.9.11) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.10...v0.9.11)

## [v0.9.10](https://github.com/voxpupuli/puppet-yum/tree/v0.9.10) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.9...v0.9.10)

## [v0.9.9](https://github.com/voxpupuli/puppet-yum/tree/v0.9.9) (2016-08-12)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/v0.9.8...v0.9.9)

## [v0.9.8](https://github.com/voxpupuli/puppet-yum/tree/v0.9.8) (2016-08-04)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.8...v0.9.8)

## [0.9.8](https://github.com/voxpupuli/puppet-yum/tree/0.9.8) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.7...0.9.8)

## [0.9.7](https://github.com/voxpupuli/puppet-yum/tree/0.9.7) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.6...0.9.7)

## [0.9.6](https://github.com/voxpupuli/puppet-yum/tree/0.9.6) (2015-04-29)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.5...0.9.6)

## [0.9.5](https://github.com/voxpupuli/puppet-yum/tree/0.9.5) (2015-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.4...0.9.5)

## [0.9.4](https://github.com/voxpupuli/puppet-yum/tree/0.9.4) (2014-12-08)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.3...0.9.4)

## [0.9.3](https://github.com/voxpupuli/puppet-yum/tree/0.9.3) (2014-11-06)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.2...0.9.3)

## [0.9.2](https://github.com/voxpupuli/puppet-yum/tree/0.9.2) (2014-09-02)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/0.9.1...0.9.2)

## [0.9.1](https://github.com/voxpupuli/puppet-yum/tree/0.9.1) (2014-08-20)

[Full Changelog](https://github.com/voxpupuli/puppet-yum/compare/92c4d392fa2b2a05920798c66f8bf4097bf52d2c...0.9.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
