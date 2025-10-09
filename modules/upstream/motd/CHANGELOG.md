<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v7.3.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v7.3.0) - 2025-04-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v7.2.0...v7.3.0)

### Added

- (MODULES-11473) Add windows 2022 support [#526](https://github.com/puppetlabs/puppetlabs-motd/pull/526) ([amitkarsale](https://github.com/amitkarsale))

## [v7.2.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v7.2.0) - 2024-12-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v7.1.0...v7.2.0)

### Added

- (CAT-2124) Add support for Ubuntu 24 [#522](https://github.com/puppetlabs/puppetlabs-motd/pull/522) ([skyamgarp](https://github.com/skyamgarp))
- (CAT-2100) Add Debian 12 support [#521](https://github.com/puppetlabs/puppetlabs-motd/pull/521) ([shubhamshinde360](https://github.com/shubhamshinde360))

### Fixed

- (CAT-2180) Upgrade rexml to address CVE-2024-49761 [#523](https://github.com/puppetlabs/puppetlabs-motd/pull/523) ([amitkarsale](https://github.com/amitkarsale))
- (BUGFIX) Update values to correctly reflect what is expected [#508](https://github.com/puppetlabs/puppetlabs-motd/pull/508) ([david22swan](https://github.com/david22swan))

## [v7.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v7.1.0) - 2023-06-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v7.0.0...v7.1.0)

### Added

- pdksync - (MAINT) - Allow Stdlib 9.x [#487](https://github.com/puppetlabs/puppetlabs-motd/pull/487) ([LukasAud](https://github.com/LukasAud))

### Fixed

- (CONT-860) Update registry dependency [#475](https://github.com/puppetlabs/puppetlabs-motd/pull/475) ([LukasAud](https://github.com/LukasAud))

## [v7.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v7.0.0) - 2023-04-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v6.3.0...v7.0.0)

### Changed

- (Cont 787) Add Support for Puppet 8 / Drop Support for Puppet 6 [#472](https://github.com/puppetlabs/puppetlabs-motd/pull/472) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (CONT-189) Remove support for RedHat6 / OracleLinux6 / Scientific6 [#456](https://github.com/puppetlabs/puppetlabs-motd/pull/456) ([david22swan](https://github.com/david22swan))
- pdksync - (CONT-130) - Dropping Support for Debian 9 [#450](https://github.com/puppetlabs/puppetlabs-motd/pull/450) ([jordanbreen28](https://github.com/jordanbreen28))

## [v6.3.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v6.3.0) - 2022-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v6.2.0...v6.3.0)

### Added

- pdksync - (GH-cat-11) Certify Support for Ubuntu 22.04 [#447](https://github.com/puppetlabs/puppetlabs-motd/pull/447) ([david22swan](https://github.com/david22swan))
- pdksync - (GH-cat-12) Add Support for Redhat 9 [#446](https://github.com/puppetlabs/puppetlabs-motd/pull/446) ([david22swan](https://github.com/david22swan))

### Fixed

- (MAINT) Dropped support for Windows Server 2008 R2 and FreeBSD [#448](https://github.com/puppetlabs/puppetlabs-motd/pull/448) ([jordanbreen28](https://github.com/jordanbreen28))

## [v6.2.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v6.2.0) - 2022-05-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v6.1.0...v6.2.0)

### Added

- Update motd location for FreeBSD 13 and above [#431](https://github.com/puppetlabs/puppetlabs-motd/pull/431) ([Scnaeg](https://github.com/Scnaeg))
- pdksync - (IAC-1753) - Add Support for AlmaLinux 8 [#428](https://github.com/puppetlabs/puppetlabs-motd/pull/428) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1751) - Add Support for Rocky 8 [#427](https://github.com/puppetlabs/puppetlabs-motd/pull/427) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (GH-iac-334) Remove Support for Ubuntu 16.04 [#433](https://github.com/puppetlabs/puppetlabs-motd/pull/433) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1787) Remove Support for CentOS 6 [#430](https://github.com/puppetlabs/puppetlabs-motd/pull/430) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1598) - Remove Support for Debian 8 [#426](https://github.com/puppetlabs/puppetlabs-motd/pull/426) ([david22swan](https://github.com/david22swan))

## [v6.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v6.1.0) - 2021-08-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v6.0.0...v6.1.0)

### Added

- pdksync - (IAC-1709) - Add Support for Debian 11 [#420](https://github.com/puppetlabs/puppetlabs-motd/pull/420) ([david22swan](https://github.com/david22swan))

### Fixed

- (IAC-1741) Allow stdlib v8.0.0 [#421](https://github.com/puppetlabs/puppetlabs-motd/pull/421) ([david22swan](https://github.com/david22swan))

## [v6.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v6.0.0) - 2021-05-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v5.0.0...v6.0.0)

### Fixed

- (IAC-1497) - Removal of unsupported `translate` dependency [#404](https://github.com/puppetlabs/puppetlabs-motd/pull/404) ([david22swan](https://github.com/david22swan))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v5.0.0) - 2021-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v4.3.0...v5.0.0)

### Changed

- Update metadata.json - remove ubuntu 14.04 [#401](https://github.com/puppetlabs/puppetlabs-motd/pull/401) ([daianamezdrea](https://github.com/daianamezdrea))
- pdksync -  Remove SLES 11 support [#399](https://github.com/puppetlabs/puppetlabs-motd/pull/399) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove RHEL 5 family support [#398](https://github.com/puppetlabs/puppetlabs-motd/pull/398) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#394](https://github.com/puppetlabs/puppetlabs-motd/pull/394) ([carabasdaniel](https://github.com/carabasdaniel))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v4.3.0) - 2020-12-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v4.2.0...v4.3.0)

### Added

- pdksync - (feat) - Add support for Puppet 7 [#369](https://github.com/puppetlabs/puppetlabs-motd/pull/369) ([daianamezdrea](https://github.com/daianamezdrea))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v4.2.0) - 2020-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v4.1.1...v4.2.0)

### Added

- (IAC-974) - Removal of inappropriate terminology [#326](https://github.com/puppetlabs/puppetlabs-motd/pull/326) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch main [#320](https://github.com/puppetlabs/puppetlabs-motd/pull/320) ([david22swan](https://github.com/david22swan))
- (IAC-746) - Add ubuntu 20.04 support [#309](https://github.com/puppetlabs/puppetlabs-motd/pull/309) ([david22swan](https://github.com/david22swan))

## [v4.1.1](https://github.com/puppetlabs/puppetlabs-motd/tree/v4.1.1) - 2020-05-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v4.1.0...v4.1.1)

### Fixed

- (MAINT) Ensure FreeBSD compatibility [#271](https://github.com/puppetlabs/puppetlabs-motd/pull/271) ([dandrzejewski](https://github.com/dandrzejewski))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v4.1.0) - 2020-01-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v4.0.0...v4.1.0)

### Added

- (MODULES-10242) Add back support for Ubuntu 14.04 [#267](https://github.com/puppetlabs/puppetlabs-motd/pull/267) ([sheenaajay](https://github.com/sheenaajay))
- (FM-8691) - Addition of Support for CentOS 8 [#264](https://github.com/puppetlabs/puppetlabs-motd/pull/264) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-10387) Raise lower bound for puppetlabs-registry dependency to 4.0.0 [#276](https://github.com/puppetlabs/puppetlabs-motd/pull/276) ([daianamezdrea](https://github.com/daianamezdrea))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v4.0.0) - 2019-11-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v3.1.0...v4.0.0)

### Changed

- pdksync - FM-8499 - remove ubuntu14 support [#262](https://github.com/puppetlabs/puppetlabs-motd/pull/262) ([lionce](https://github.com/lionce))

### Added

- FM-8405 Debian10 support [#242](https://github.com/puppetlabs/puppetlabs-motd/pull/242) ([lionce](https://github.com/lionce))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v3.1.0) - 2019-08-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/v3.0.0...v3.1.0)

### Added

- (MODULES-9653) Add Windows Server 2019 support [#235](https://github.com/puppetlabs/puppetlabs-motd/pull/235) ([eimlav](https://github.com/eimlav))
- FM-8043 - redhat8 support [#222](https://github.com/puppetlabs/puppetlabs-motd/pull/222) ([lionce](https://github.com/lionce))

### Fixed

- (bugfix) allow private keys in ssh testing [#223](https://github.com/puppetlabs/puppetlabs-motd/pull/223) ([tphoney](https://github.com/tphoney))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/v3.0.0) - 2019-05-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/2.1.2...v3.0.0)

### Changed

- pdksync - (MODULES-8444) - Raise lower Puppet bound [#208](https://github.com/puppetlabs/puppetlabs-motd/pull/208) ([david22swan](https://github.com/david22swan))

### Added

- simplistic support for vscode integration to litmus added [#212](https://github.com/puppetlabs/puppetlabs-motd/pull/212) ([abuxton](https://github.com/abuxton))
- (MODULES-8767) Add support for SLES 15 [#205](https://github.com/puppetlabs/puppetlabs-motd/pull/205) ([eimlav](https://github.com/eimlav))
- (FM-7647) use puppet_litmus for acceptance testing [#200](https://github.com/puppetlabs/puppetlabs-motd/pull/200) ([tphoney](https://github.com/tphoney))

### Fixed

- (bugfix) remove scientific 5 testing [#217](https://github.com/puppetlabs/puppetlabs-motd/pull/217) ([tphoney](https://github.com/tphoney))
- (FM-8073) litmus block support [#216](https://github.com/puppetlabs/puppetlabs-motd/pull/216) ([tphoney](https://github.com/tphoney))
- (bugfix) changes needed for litmus 0.1.0 release [#214](https://github.com/puppetlabs/puppetlabs-motd/pull/214) ([tphoney](https://github.com/tphoney))
- (MODULES-8758) Change memoryfree to memorysize in template [#204](https://github.com/puppetlabs/puppetlabs-motd/pull/204) ([eimlav](https://github.com/eimlav))

## [2.1.2](https://github.com/puppetlabs/puppetlabs-motd/tree/2.1.2) - 2019-01-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/2.1.1...2.1.2)

### Fixed

- pdksync - (FM-7655) Fix rubygems-update for ruby < 2.3 [#188](https://github.com/puppetlabs/puppetlabs-motd/pull/188) ([tphoney](https://github.com/tphoney))

## [2.1.1](https://github.com/puppetlabs/puppetlabs-motd/tree/2.1.1) - 2018-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/2.1.0...2.1.1)

### Fixed

- (fix) - Changelog Fix [#171](https://github.com/puppetlabs/puppetlabs-motd/pull/171) ([david22swan](https://github.com/david22swan))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/2.1.0) - 2018-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/2.0.0...2.1.0)

### Added

- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#164](https://github.com/puppetlabs/puppetlabs-motd/pull/164) ([tphoney](https://github.com/tphoney))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/2.0.0) - 2018-09-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.9.0...2.0.0)

### Changed

- [FM-6965] Removal of unsupported OS from motd [#131](https://github.com/puppetlabs/puppetlabs-motd/pull/131) ([david22swan](https://github.com/david22swan))

### Added

- (FM-7310)- Updating Windows version support [#156](https://github.com/puppetlabs/puppetlabs-motd/pull/156) ([lionce](https://github.com/lionce))
- (FM-7306) - Added Puppet 4 data types and changed templates to .epp [#152](https://github.com/puppetlabs/puppetlabs-motd/pull/152) ([eimlav](https://github.com/eimlav))
- (FM-7307) - added translation functionality [#150](https://github.com/puppetlabs/puppetlabs-motd/pull/150) ([Lavinia-Dan](https://github.com/Lavinia-Dan))
- (maint) removing registry pin, update stdlib bound [#145](https://github.com/puppetlabs/puppetlabs-motd/pull/145) ([tphoney](https://github.com/tphoney))
- (FM-7237) - Addition of support for Ubuntu 18.04 on motd [#140](https://github.com/puppetlabs/puppetlabs-motd/pull/140) ([david22swan](https://github.com/david22swan))

## [1.9.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.9.0) - 2018-05-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.8.0...1.9.0)

### Added

- (MODULES-7069) Add compatibility for AIX [#115](https://github.com/puppetlabs/puppetlabs-motd/pull/115) ([jarretlavallee](https://github.com/jarretlavallee))
- windows_motd_title parameter added [#108](https://github.com/puppetlabs/puppetlabs-motd/pull/108) ([cgpeanut](https://github.com/cgpeanut))

## [1.8.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.8.0) - 2018-02-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.7.0...1.8.0)

### Added

- (MODULES-6599) Make MOTD compatible with FreeBSD [#104](https://github.com/puppetlabs/puppetlabs-motd/pull/104) ([Q1tum](https://github.com/Q1tum))

## [1.7.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.7.0) - 2018-01-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.6.0...1.7.0)

## [1.6.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.6.0) - 2018-01-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.5.1...1.6.0)

### Added

- Convert module to PDK standards using pdk convert [#89](https://github.com/puppetlabs/puppetlabs-motd/pull/89) ([davinhanlon](https://github.com/davinhanlon))

## [1.5.1](https://github.com/puppetlabs/puppetlabs-motd/tree/1.5.1) - 2017-10-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.5.0...1.5.1)

## [1.5.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.5.0) - 2017-10-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.4.0...1.5.0)

### Added

- Add set mode for File [#81](https://github.com/puppetlabs/puppetlabs-motd/pull/81) ([willmeek](https://github.com/willmeek))
- Added Solaris support to motd [#74](https://github.com/puppetlabs/puppetlabs-motd/pull/74) ([wfsaxton](https://github.com/wfsaxton))
- (#5955) Support for /etc/issue and /etc/issue.net [#60](https://github.com/puppetlabs/puppetlabs-motd/pull/60) ([GeoffWilliams](https://github.com/GeoffWilliams))

### Fixed

- (MODULES-5468) removed 'delete appveyor' code from .sync.yml [#77](https://github.com/puppetlabs/puppetlabs-motd/pull/77) ([8675309](https://github.com/8675309))
- (MODULES-3593) Changes default MOTD to something more useful [#76](https://github.com/puppetlabs/puppetlabs-motd/pull/76) ([8675309](https://github.com/8675309))
- Corrected SLES version [#67](https://github.com/puppetlabs/puppetlabs-motd/pull/67) ([cetanu](https://github.com/cetanu))
- [MODULES-4556] Remove PE requirement from metadata.json [#66](https://github.com/puppetlabs/puppetlabs-motd/pull/66) ([wilson208](https://github.com/wilson208))

## [1.4.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.4.0) - 2016-01-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.3.0...1.4.0)

### Added

- (FM-3924) Create Master/Agent automation test for Puppetlabs-motd [#29](https://github.com/puppetlabs/puppetlabs-motd/pull/29) ([phongdly](https://github.com/phongdly))

## [1.3.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.3.0) - 2015-12-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.2.0...1.3.0)

### Added

- Added option to disable dynamic motd on Debian based systems [#20](https://github.com/puppetlabs/puppetlabs-motd/pull/20) ([dlactin](https://github.com/dlactin))
- Added logic for Windows Logon Message [#19](https://github.com/puppetlabs/puppetlabs-motd/pull/19) ([ncorrare](https://github.com/ncorrare))

### Fixed

- Use strings for parameter documentation MODULES-2664 [#26](https://github.com/puppetlabs/puppetlabs-motd/pull/26) ([borcean](https://github.com/borcean))
- Fix for MODULES-2590 [#22](https://github.com/puppetlabs/puppetlabs-motd/pull/22) ([HelenCampbell](https://github.com/HelenCampbell))
- Add missing stdlib fixture [#21](https://github.com/puppetlabs/puppetlabs-motd/pull/21) ([arioch](https://github.com/arioch))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.2.0) - 2014-11-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.1.1...1.2.0)

### Added

- Add source parameter to motd [#16](https://github.com/puppetlabs/puppetlabs-motd/pull/16) ([adreyer](https://github.com/adreyer))

## [1.1.1](https://github.com/puppetlabs/puppetlabs-motd/tree/1.1.1) - 2014-07-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.1.0...1.1.1)

## [1.1.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.1.0) - 2014-05-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.0.1...1.1.0)

### Added

- add test and ERB conditional logic for when ::domain not present [#13](https://github.com/puppetlabs/puppetlabs-motd/pull/13) ([nrvale0](https://github.com/nrvale0))
- Added class parameter for external templates and tests [#7](https://github.com/puppetlabs/puppetlabs-motd/pull/7) ([solarkennedy](https://github.com/solarkennedy))

### Fixed

- fix a deprecation warning introduced by puppet issue 19058 [#5](https://github.com/puppetlabs/puppetlabs-motd/pull/5) ([nagas](https://github.com/nagas))
- Init.pp doesn't meet puppet style guidelines [#2](https://github.com/puppetlabs/puppetlabs-motd/pull/2) ([brianvans](https://github.com/brianvans))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-motd/tree/1.0.1) - 2012-03-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/puppetlabs/puppetlabs-motd/tree/1.0.0) - 2012-03-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-motd/compare/9702b8126e28be589b9edd9ea2a357f81a22e029...1.0.0)
