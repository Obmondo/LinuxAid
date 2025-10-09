# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.1.2](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v5.1.2) (2024-08-22)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/v5.1.1...v5.1.2)

**Fixed bugs:**

- fix: limit scope of update-bls-cmdline to RHEL9 [\#104](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/104) ([vchepkov](https://github.com/vchepkov))

## [v5.1.1](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v5.1.1) (2024-07-09)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/v5.1.0...v5.1.1)

**Fixed bugs:**

- RHEL \>= 9.3 - `grub2-mkconfig` does not update BLS kernel options anymore per default [\#95](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/95)
- Update BLS kernel options on EL \>= 9.3 [\#98](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/98) ([silug](https://github.com/silug))

## [v5.1.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v5.1.0) (2023-10-30)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/v5.0.1...v5.1.0)

**Implemented enhancements:**

- Add EL9 support [\#92](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/92) ([bastelfreak](https://github.com/bastelfreak))
- Add AlmaLinux/Rocky support [\#91](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/91) ([bastelfreak](https://github.com/bastelfreak))
- Add Ubuntu 22.04 support [\#90](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/90) ([bastelfreak](https://github.com/bastelfreak))
- Add Debian 12 support [\#89](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/89) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update project page to point to github repo [\#88](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/88) ([tuxmea](https://github.com/tuxmea))

## [v5.0.1](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v5.0.1) (2023-10-15)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/v5.0.0...v5.0.1)

**Fixed bugs:**

- v4.0.0: Standard error of `grub-mkconfig` written to `grub.cfg` [\#74](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/74)

**Merged pull requests:**

- Drop stderr from mkconfig output when updating grub  [\#84](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/84) ([glangloi](https://github.com/glangloi))

## [v5.0.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v5.0.0) (2023-06-22)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/v4.0.0...v5.0.0)

**Breaking changes:**

- Debian: Drop 9, add support for 10 & 11 [\#82](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/82) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 6 support [\#77](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/77) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- puppet/augeasproviders\_core: Allow 4.x [\#80](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/80) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Add puppet 8 support [\#79](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/79) ([bastelfreak](https://github.com/bastelfreak))
- Add RHEL 9 to supported OS [\#76](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/76) ([tuxmea](https://github.com/tuxmea))
- Fix broken Apache-2 license [\#73](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/73) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/v4.0.0) (2022-07-29)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/3.2.0...v4.0.0)

**Breaking changes:**

- Call grub2-mkconfig on all targets [\#57](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/57) ([traylenator](https://github.com/traylenator))

**Fixed bugs:**

- grub\_menuentry resource fail if directory /boot/grub doe not exist [\#53](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/53)
- grub.cfg isn't being properly updated on EFI systems running CentOS 7 [\#4](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/4)
- Fix grub\_menuentry issues [\#56](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/56) ([trevor-vaughan](https://github.com/trevor-vaughan))

**Closed issues:**

- The mkconfig update in \#4 needs to be ported to the other providers [\#63](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/63)
- kernel\_parameters set incorrectly on CentOS 8 [\#58](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/58)
- Typo in provider grub for custom type grub\_menuentry [\#54](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/54)
- Kernel\_parameter subscribe executes on every run [\#41](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/41)
- More informative error message for missing dependency [\#34](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/34)
- Support for Puppet 4 [\#26](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/26)
- Issue w/Puppet 2016.x [\#24](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/24)

**Merged pull requests:**

- Update augeasproviders\_core version [\#67](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/67) ([sazzle2611](https://github.com/sazzle2611))
- Fix mkconfig calls [\#64](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/64) ([trevor-vaughan](https://github.com/trevor-vaughan))
- error message improvement: specify that it's a missing module [\#61](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/61) ([kenyon](https://github.com/kenyon))
- Fix typo in grub\_menuentry provider [\#55](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/55) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [3.2.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/3.2.0) (2020-03-31)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/3.1.0...3.2.0)

**Fixed bugs:**

- grub\_menuentry is broken in EL8 and Fedora 30+ [\#49](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/49)

**Closed issues:**

- grub\_config values with spaces cause augeas errors [\#44](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/44)
- Absent GRUB\_CMDLINE\_LINUX\_DEFAULT can result in duplicated kernel parameters. [\#38](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/38)
- The grub2 system should update both the EFI and non-EFI configurations when triggered [\#37](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/37)

**Merged pull requests:**

- Add BLS support to grub\_menuentry [\#50](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/50) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Fixed the EFI code for grub\_config and grub\_menuentry [\#48](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/48) ([tparkercbn](https://github.com/tparkercbn))
- Fix String value issues in grub\_config [\#46](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/46) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Puppet6 [\#42](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/42) ([raphink](https://github.com/raphink))

## [3.1.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/3.1.0) (2019-02-28)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/3.0.1...3.1.0)

**Closed issues:**

- Hard dependency on grub2-tools on CentOS7 missing [\#20](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/20)

**Merged pull requests:**

- Add back path for grub.cfg on Debian OS. [\#36](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/36) ([olifre](https://github.com/olifre))

## [3.0.1](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/3.0.1) (2018-05-09)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/3.0.0...3.0.1)

**Closed issues:**

- EFI support for all oses, not only fedora [\#27](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/27)

**Merged pull requests:**

- Grub2 grub\_user fix [\#32](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/32) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Update grub2.rb for EFI systems [\#29](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/29) ([cohdjn](https://github.com/cohdjn))

## [3.0.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/3.0.0) (2017-08-29)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.4.0...3.0.0)

**Closed issues:**

- Unable to set/determine correct provider on Arch Linux [\#22](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/22)

**Merged pull requests:**

- Add Global EFI support [\#28](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/28) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Raise exception on missing augeasproviders\_core [\#25](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/25) ([igalic](https://github.com/igalic))

## [2.4.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.4.0) (2016-05-03)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.3.0...2.4.0)

**Implemented enhancements:**

- Requesting support for grub 'module' statements [\#10](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/10)
- Confine GRUB providers to presence of menus, prefer GRUB 2 [\#8](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/8) ([ckoenig](https://github.com/ckoenig))

**Closed issues:**

- Fails on CentOS 6 [\#6](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/6)

**Merged pull requests:**

- Update grub2.rb to add On UEFI Systems, grub.cfg [\#21](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/21) ([stivesso](https://github.com/stivesso))
- Updated the Changelog [\#19](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/19) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Added support for global GRUB configuration [\#18](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/18) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [2.3.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.3.0) (2016-02-18)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.2.0...2.3.0)

**Closed issues:**

- wrong version of grub detection on Ubuntu Trusty [\#13](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/13)
- Grub2 does not add the /files/etc/default/grub/GRUB\_CMDLINE\_LINUX\_DEFAULT path if it is missing [\#11](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/11)

**Merged pull requests:**

- adding 2 defaults for grub 2 [\#17](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/17) ([wanix](https://github.com/wanix))
- add grub.cfg location for grub2 on UEFI systems [\#16](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/16) ([tedwardia](https://github.com/tedwardia))
- Fix GRUB\_CMDLINE\_LINUX\_DEFAULT [\#14](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/14) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [2.2.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.2.0) (2016-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.1.0...2.2.0)

## [2.1.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.1.0) (2015-11-17)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.0.1...2.1.0)

**Closed issues:**

- undefined method `provider' for nil:NilClass [\#12](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/12)
- Wrong provider selected in Centos7 [\#7](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/7)

**Merged pull requests:**

- Set default to grub2 provider on el7 based systems [\#9](https://github.com/voxpupuli/puppet-augeasproviders_grub/pull/9) ([vinzent](https://github.com/vinzent))

## [2.0.1](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.0.1) (2014-12-10)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/2.0.0...2.0.1)

**Closed issues:**

- Undefined method "provider" on Centos 6.5 [\#2](https://github.com/voxpupuli/puppet-augeasproviders_grub/issues/2)

## [2.0.0](https://github.com/voxpupuli/puppet-augeasproviders_grub/tree/2.0.0) (2014-08-11)

[Full Changelog](https://github.com/voxpupuli/puppet-augeasproviders_grub/compare/a9a2ad1f0685c21d9f0e5fd222c12f21b029a40b...2.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
