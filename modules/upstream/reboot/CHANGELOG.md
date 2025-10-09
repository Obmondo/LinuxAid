<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v5.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v5.1.0) - 2025-01-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v5.0.0...v5.1.0)

### Added

- (CAT-2119) Add Ubuntu 24.04 support [#372](https://github.com/puppetlabs/puppetlabs-reboot/pull/372) ([shubhamshinde360](https://github.com/shubhamshinde360))
- (CAT-2101) Add support for Debian-12 [#371](https://github.com/puppetlabs/puppetlabs-reboot/pull/371) ([skyamgarp](https://github.com/skyamgarp))

### Fixed

- (CAT-2180) Upgrade rexml to address CVE-2024-49761 [#374](https://github.com/puppetlabs/puppetlabs-reboot/pull/374) ([amitkarsale](https://github.com/amitkarsale))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v5.0.0) - 2023-04-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.3.1...v5.0.0)

### Changed

- (CONT-795) Puppet 8 support / Drop Puppet 6 [#343](https://github.com/puppetlabs/puppetlabs-reboot/pull/343) ([LukasAud](https://github.com/LukasAud))

## [v4.3.1](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.3.1) - 2023-04-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.3.0...v4.3.1)

### Fixed

- pdksync - (CONT-189) Remove support for RedHat6 / OracleLinux6 / Scientific6 [#335](https://github.com/puppetlabs/puppetlabs-reboot/pull/335) ([david22swan](https://github.com/david22swan))
- pdksync - (CONT-130) - Dropping Support for Debian 9 [#332](https://github.com/puppetlabs/puppetlabs-reboot/pull/332) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.3.0) - 2022-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.2.0...v4.3.0)

### Added

- pdksync - (GH-cat-11) Certify Support for Ubuntu 22.04 [#329](https://github.com/puppetlabs/puppetlabs-reboot/pull/329) ([david22swan](https://github.com/david22swan))

### Fixed

- (MAINT) Dropped support for Windows(7,8, 2008 Server & 2008 R2 Server) and AIX (5.3, 6.1) [#330](https://github.com/puppetlabs/puppetlabs-reboot/pull/330) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.2.0) - 2022-06-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.1.0...v4.2.0)

### Added

- pdksync - (GH-cat-12) Add Support for Redhat 9 [#324](https://github.com/puppetlabs/puppetlabs-reboot/pull/324) ([david22swan](https://github.com/david22swan))
- pdksync - (FM-8922) - Add Support for Windows 2022 [#314](https://github.com/puppetlabs/puppetlabs-reboot/pull/314) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1753) - Add Support for AlmaLinux 8 [#309](https://github.com/puppetlabs/puppetlabs-reboot/pull/309) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1751) - Add Support for Rocky 8 [#308](https://github.com/puppetlabs/puppetlabs-reboot/pull/308) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (GH-iac-334) Remove Support for Ubuntu 14.04/16.04 [#316](https://github.com/puppetlabs/puppetlabs-reboot/pull/316) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1787) Remove Support for CentOS 6 [#312](https://github.com/puppetlabs/puppetlabs-reboot/pull/312) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1598) - Remove Support for Debian 8 [#307](https://github.com/puppetlabs/puppetlabs-reboot/pull/307) ([david22swan](https://github.com/david22swan))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.1.0) - 2021-08-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.0.2...v4.1.0)

### Added

- pdksync - (IAC-1709) - Add Support for Debian 11 [#304](https://github.com/puppetlabs/puppetlabs-reboot/pull/304) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-11149) Modify result of 'last' to remove current time [#305](https://github.com/puppetlabs/puppetlabs-reboot/pull/305) ([nmburgan](https://github.com/nmburgan))

## [v4.0.2](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.2) - 2021-03-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.0.1...v4.0.2)

### Fixed

- (MODULES-10963) remove win32-process on Puppet 7 [#287](https://github.com/puppetlabs/puppetlabs-reboot/pull/287) ([gimmyxd](https://github.com/gimmyxd))

## [v4.0.1](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.1) - 2021-03-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v4.0.0...v4.0.1)

### Fixed

- Cleanup: Changed to ctrl::sleep() and removed redundant reboot::sleep() function [#284](https://github.com/puppetlabs/puppetlabs-reboot/pull/284) ([fetzerms](https://github.com/fetzerms))
- (MODULES-10955) More robust handling of reboot-task output [#280](https://github.com/puppetlabs/puppetlabs-reboot/pull/280) ([fetzerms](https://github.com/fetzerms))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v4.0.0) - 2021-03-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.2.0...v4.0.0)

### Changed

- pdksync - (MAINT) Remove SLES 11 support [#279](https://github.com/puppetlabs/puppetlabs-reboot/pull/279) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - (MAINT) Remove RHEL 5 family support [#278](https://github.com/puppetlabs/puppetlabs-reboot/pull/278) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#275](https://github.com/puppetlabs/puppetlabs-reboot/pull/275) ([carabasdaniel](https://github.com/carabasdaniel))

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.2.0) - 2021-01-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.1.0...v3.2.0)

### Added

- pdksync - (feat) Add support for Puppet 7 [#265](https://github.com/puppetlabs/puppetlabs-reboot/pull/265) ([daianamezdrea](https://github.com/daianamezdrea))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.1.0) - 2020-11-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v3.0.0...v3.1.0)

### Added

- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#253](https://github.com/puppetlabs/puppetlabs-reboot/pull/253) ([david22swan](https://github.com/david22swan))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v3.0.0) - 2020-02-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.4.0...v3.0.0)

### Changed

- (GH-1376) Change `$nodes` parameter for `reboot` plan to `$targets` [#223](https://github.com/puppetlabs/puppetlabs-reboot/pull/223) ([beechtom](https://github.com/beechtom))

## [v2.4.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.4.0) - 2020-02-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.3.0...v2.4.0)

### Added

- Add `shutdown_only` parameter to tasks [#224](https://github.com/puppetlabs/puppetlabs-reboot/pull/224) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-8201) Add pending reboot due to domain join for windows. [#179](https://github.com/puppetlabs/puppetlabs-reboot/pull/179) ([razorbladex401](https://github.com/razorbladex401))

## [v2.3.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.3.0) - 2019-12-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/v2.2.0...v2.3.0)

### Added

- (FM-8700) - Addition of Support for CentOs 8 [#221](https://github.com/puppetlabs/puppetlabs-reboot/pull/221) ([david22swan](https://github.com/david22swan))
- pdksync - Add support on Debian10 [#218](https://github.com/puppetlabs/puppetlabs-reboot/pull/218) ([lionce](https://github.com/lionce))

### Fixed

- Fix reboot message for linux hosts [#213](https://github.com/puppetlabs/puppetlabs-reboot/pull/213) ([nmaludy](https://github.com/nmaludy))

## [v2.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/v2.2.0) - 2019-07-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.2.0...v2.2.0)

## [2.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.2.0) - 2019-07-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.1.2...2.2.0)

### Added

- (FM-8051) Add RedHat 8 support [#207](https://github.com/puppetlabs/puppetlabs-reboot/pull/207) ([eimlav](https://github.com/eimlav))
- (MODULES-8148) - Add SLES 15 support [#191](https://github.com/puppetlabs/puppetlabs-reboot/pull/191) ([eimlav](https://github.com/eimlav))

### Fixed

- Add additional guards for nix process detach [#210](https://github.com/puppetlabs/puppetlabs-reboot/pull/210) ([reidmv](https://github.com/reidmv))
- Fix plan return value [#209](https://github.com/puppetlabs/puppetlabs-reboot/pull/209) ([reidmv](https://github.com/reidmv))
- MODULES-8726: Ensure sbin is in the path [#205](https://github.com/puppetlabs/puppetlabs-reboot/pull/205) ([xalimar](https://github.com/xalimar))
- [MODULES-8718] Check for root or sudo in the reboot task nix.sh script [#203](https://github.com/puppetlabs/puppetlabs-reboot/pull/203) ([thilinapiy](https://github.com/thilinapiy))
- (MODULES-8717) Fix dependency issue on boltspec [#202](https://github.com/puppetlabs/puppetlabs-reboot/pull/202) ([HelenCampbell](https://github.com/HelenCampbell))

## [2.1.2](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.1.2) - 2018-12-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.1.1...2.1.2)

### Fixed

- (MODULES-8353) Infinite reboot wait loop bug [#188](https://github.com/puppetlabs/puppetlabs-reboot/pull/188) ([TraGicCode](https://github.com/TraGicCode))

### Other

- (MODULES-8095) release merge-back to master [#183](https://github.com/puppetlabs/puppetlabs-reboot/pull/183) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))

## [2.1.1](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.1.1) - 2018-12-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.1.0...2.1.1)

### Other

- (MODULES-8091) Update module version 2.1.1 [#185](https://github.com/puppetlabs/puppetlabs-reboot/pull/185) ([glennsarti](https://github.com/glennsarti))
- (packaging) Make task implementations unique for the Forge and PE [#184](https://github.com/puppetlabs/puppetlabs-reboot/pull/184) ([MikaelSmith](https://github.com/MikaelSmith))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.1.0) - 2018-12-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/2.0.0...2.1.0)

### Added

- (BOLT-459) Create reboot plan [#178](https://github.com/puppetlabs/puppetlabs-reboot/pull/178) ([MikaelSmith](https://github.com/MikaelSmith))

### Other

- (MODULES-8094) Changelog Updates for Release 2.1.0 [#182](https://github.com/puppetlabs/puppetlabs-reboot/pull/182) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- (BOLT-957) Make last_boot_time task more portable [#180](https://github.com/puppetlabs/puppetlabs-reboot/pull/180) ([MikaelSmith](https://github.com/MikaelSmith))
- (MODULES-8091) Prep module for 2.1.0 release [#173](https://github.com/puppetlabs/puppetlabs-reboot/pull/173) ([glennsarti](https://github.com/glennsarti))
- (MODULES-7832) Update module for Puppet 6 [#172](https://github.com/puppetlabs/puppetlabs-reboot/pull/172) ([glennsarti](https://github.com/glennsarti))
- (MODULES-8046) Added function to wait for reboots [#171](https://github.com/puppetlabs/puppetlabs-reboot/pull/171) ([dylanratcliffe](https://github.com/dylanratcliffe))
- (maint) Fix broken link in metadata file [#170](https://github.com/puppetlabs/puppetlabs-reboot/pull/170) ([catay](https://github.com/catay))
- pdksync - (MODULES-7658) use beaker4 in puppet-module-gems [#169](https://github.com/puppetlabs/puppetlabs-reboot/pull/169) ([tphoney](https://github.com/tphoney))
- pdksync - (MODULES-7658) use beaker3 in puppet-module-gems [#168](https://github.com/puppetlabs/puppetlabs-reboot/pull/168) ([tphoney](https://github.com/tphoney))
- (MODULES-7403) PDK Convert the module [#167](https://github.com/puppetlabs/puppetlabs-reboot/pull/167) ([glennsarti](https://github.com/glennsarti))
- (MODULES-7634) - Update README Limitations section [#166](https://github.com/puppetlabs/puppetlabs-reboot/pull/166) ([eimlav](https://github.com/eimlav))
- (MODULES-6745) Use testmode-switcher [#165](https://github.com/puppetlabs/puppetlabs-reboot/pull/165) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-7417) Addition of support for Debian 9 and Ubuntu 16.04 and 18.04 [#164](https://github.com/puppetlabs/puppetlabs-reboot/pull/164) ([david22swan](https://github.com/david22swan))
- [FM-6968] Removal of unsupported OS from reboot [#163](https://github.com/puppetlabs/puppetlabs-reboot/pull/163) ([david22swan](https://github.com/david22swan))
- (MODULES-6745) Add testmode to tests [#162](https://github.com/puppetlabs/puppetlabs-reboot/pull/162) ([glennsarti](https://github.com/glennsarti))
- Update README.md to clarify provider restriction [#161](https://github.com/puppetlabs/puppetlabs-reboot/pull/161) ([claw-real](https://github.com/claw-real))
- (maint) Fix typo in for travis yaml file [#159](https://github.com/puppetlabs/puppetlabs-reboot/pull/159) ([glennsarti](https://github.com/glennsarti))
- Improve parameter validation [#158](https://github.com/puppetlabs/puppetlabs-reboot/pull/158) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Modules 5896 fix for rubocop [#157](https://github.com/puppetlabs/puppetlabs-reboot/pull/157) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- (MODULES-5896)(MODULES-3975) Fix rubocop violations [#156](https://github.com/puppetlabs/puppetlabs-reboot/pull/156) ([glennsarti](https://github.com/glennsarti))
- Mergeback from release into master [#155](https://github.com/puppetlabs/puppetlabs-reboot/pull/155) ([glennsarti](https://github.com/glennsarti))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/2.0.0) - 2018-01-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/1.2.1...2.0.0)

### Other

- (MAINT) Update changelog to KAC standard [#154](https://github.com/puppetlabs/puppetlabs-reboot/pull/154) ([michaeltlombardi](https://github.com/michaeltlombardi))
- minor edits on readme [#153](https://github.com/puppetlabs/puppetlabs-reboot/pull/153) ([clairecadman](https://github.com/clairecadman))
- (MODULES-6443) Update OS compatibility metdata [#152](https://github.com/puppetlabs/puppetlabs-reboot/pull/152) ([glennsarti](https://github.com/glennsarti))
- (MAINT) move test dependences from metadata to spec_helper_acceptnace [#150](https://github.com/puppetlabs/puppetlabs-reboot/pull/150) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- (MODULES-6443) Prep for v2.0.0 release [#149](https://github.com/puppetlabs/puppetlabs-reboot/pull/149) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) modulesync 65530a4 Update Travis [#148](https://github.com/puppetlabs/puppetlabs-reboot/pull/148) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) Remove Nokogiri from Gemfile [#147](https://github.com/puppetlabs/puppetlabs-reboot/pull/147) ([Iristyle](https://github.com/Iristyle))
- (maint) bump nokogiri pin [#146](https://github.com/puppetlabs/puppetlabs-reboot/pull/146) ([eputnam](https://github.com/eputnam))
- (maint) modulesync cd884db Remove AppVeyor OpenSSL update on Ruby 2.4 [#145](https://github.com/puppetlabs/puppetlabs-reboot/pull/145) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) - modulesync 384f4c1 [#144](https://github.com/puppetlabs/puppetlabs-reboot/pull/144) ([tphoney](https://github.com/tphoney))
- (MODULES-5977) convert acceptance tests to beaker rspec [#143](https://github.com/puppetlabs/puppetlabs-reboot/pull/143) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- (maint) - modulesync 1d81b6a [#142](https://github.com/puppetlabs/puppetlabs-reboot/pull/142) ([pmcmaw](https://github.com/pmcmaw))
- (maint) Add Github Pull Request Template [#141](https://github.com/puppetlabs/puppetlabs-reboot/pull/141) ([jpogran](https://github.com/jpogran))
- (maint) Modify beaker task to simulate direct beaker invocation [#140](https://github.com/puppetlabs/puppetlabs-reboot/pull/140) ([glennsarti](https://github.com/glennsarti))
- Added `reboot` task [#139](https://github.com/puppetlabs/puppetlabs-reboot/pull/139) ([dylanratcliffe](https://github.com/dylanratcliffe))
- (maint) modulesync 892c4cf [#138](https://github.com/puppetlabs/puppetlabs-reboot/pull/138) ([HAIL9000](https://github.com/HAIL9000))
- (maint) modulesync 915cde70e20 [#137](https://github.com/puppetlabs/puppetlabs-reboot/pull/137) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4328) Implement reboot reason for windows [#136](https://github.com/puppetlabs/puppetlabs-reboot/pull/136) ([johnf](https://github.com/johnf))
- Update README.md [#135](https://github.com/puppetlabs/puppetlabs-reboot/pull/135) ([tramaswami](https://github.com/tramaswami))
- (MODULES-5187) mysnc puppet 5 and ruby 2.4 [#134](https://github.com/puppetlabs/puppetlabs-reboot/pull/134) ([eputnam](https://github.com/eputnam))
- Fixed markdown in README.md [#133](https://github.com/puppetlabs/puppetlabs-reboot/pull/133) ([farshidlk](https://github.com/farshidlk))
- (MODULES-5144) Prep for puppet 5 [#132](https://github.com/puppetlabs/puppetlabs-reboot/pull/132) ([hunner](https://github.com/hunner))
- (MODULES-4976) Remove rspec configuration for win32_console [#131](https://github.com/puppetlabs/puppetlabs-reboot/pull/131) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4836) Update puppet compatibility with 4.7 as lower bound [#130](https://github.com/puppetlabs/puppetlabs-reboot/pull/130) ([lbayerlein](https://github.com/lbayerlein))
- Update README.md [#129](https://github.com/puppetlabs/puppetlabs-reboot/pull/129) ([andycondon](https://github.com/andycondon))
- [msync] 786266 Implement puppet-module-gems, a45803 Remove metadata.json from locales config [#128](https://github.com/puppetlabs/puppetlabs-reboot/pull/128) ([wilson208](https://github.com/wilson208))
- modulesync e25ca9 - Add locales folder and config.yaml, update default nodeset [#127](https://github.com/puppetlabs/puppetlabs-reboot/pull/127) ([wilson208](https://github.com/wilson208))
- [MODULES-4556] Remove PE requirement from metadata.json [#126](https://github.com/puppetlabs/puppetlabs-reboot/pull/126) ([wilson208](https://github.com/wilson208))
- (MODULES-4098) Sync the rest of the files [#125](https://github.com/puppetlabs/puppetlabs-reboot/pull/125) ([hunner](https://github.com/hunner))
- (MODULES-4263) add blacksmith rake tasks [#124](https://github.com/puppetlabs/puppetlabs-reboot/pull/124) ([eputnam](https://github.com/eputnam))
- (MODULES-4097) Sync travis.yml [#123](https://github.com/puppetlabs/puppetlabs-reboot/pull/123) ([hunner](https://github.com/hunner))
- (FM-5972) Update to next modulesync_configs [dedaf10] [#122](https://github.com/puppetlabs/puppetlabs-reboot/pull/122) ([DavidS](https://github.com/DavidS))
- Designate former 'tests' file as examples [#121](https://github.com/puppetlabs/puppetlabs-reboot/pull/121) ([DavidS](https://github.com/DavidS))
- Workaround frozen strings on ruby 1.9 [#120](https://github.com/puppetlabs/puppetlabs-reboot/pull/120) ([hunner](https://github.com/hunner))
- (MODULES-3632) Use json_pure always [#119](https://github.com/puppetlabs/puppetlabs-reboot/pull/119) ([hunner](https://github.com/hunner))
- (MODULES-3704) Update gemfile template to be identical [#118](https://github.com/puppetlabs/puppetlabs-reboot/pull/118) ([hunner](https://github.com/hunner))
- (MODULES-3775) (msync 8d0455c) update travis/appveyer w/Ruby 2.3 [#117](https://github.com/puppetlabs/puppetlabs-reboot/pull/117) ([MosesMendoza](https://github.com/MosesMendoza))
- (maint) modulesync 70360747 [#116](https://github.com/puppetlabs/puppetlabs-reboot/pull/116) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3640) Update modulesync 30fc4ab [#115](https://github.com/puppetlabs/puppetlabs-reboot/pull/115) ([MosesMendoza](https://github.com/MosesMendoza))
- (maint) Update module for use with PE 2016.2 [#112](https://github.com/puppetlabs/puppetlabs-reboot/pull/112) ([glennsarti](https://github.com/glennsarti))
- (maint) Update rakefile for puppetlabs_spec_helper [#111](https://github.com/puppetlabs/puppetlabs-reboot/pull/111) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3536) modsync update [#110](https://github.com/puppetlabs/puppetlabs-reboot/pull/110) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3356) Branding Name Change [#109](https://github.com/puppetlabs/puppetlabs-reboot/pull/109) ([jpogran](https://github.com/jpogran))
- Merge up to master after stable changes [#107](https://github.com/puppetlabs/puppetlabs-reboot/pull/107) ([ferventcoder](https://github.com/ferventcoder))
- (maint) modsync update - stable [#105](https://github.com/puppetlabs/puppetlabs-reboot/pull/105) ([glennsarti](https://github.com/glennsarti))
- Revert "(maint) Use appropriate conditionals" [#104](https://github.com/puppetlabs/puppetlabs-reboot/pull/104) ([ferventcoder](https://github.com/ferventcoder))
- (FM-4913) update modulesync / Fix Specs for Rspec 3+ compatibility [#103](https://github.com/puppetlabs/puppetlabs-reboot/pull/103) ([ferventcoder](https://github.com/ferventcoder))
- (maint) update modsync / fix build [#101](https://github.com/puppetlabs/puppetlabs-reboot/pull/101) ([ferventcoder](https://github.com/ferventcoder))
- (maint) Use appropriate conditionals [#100](https://github.com/puppetlabs/puppetlabs-reboot/pull/100) ([Iristyle](https://github.com/Iristyle))
- (maint) update modulesync files [#95](https://github.com/puppetlabs/puppetlabs-reboot/pull/95) ([ferventcoder](https://github.com/ferventcoder))

## [1.2.1](https://github.com/puppetlabs/puppetlabs-reboot/tree/1.2.1) - 2015-11-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/1.2.0...1.2.1)

### Other

- (FM-3881) prep for 1.2.1 supported release [#99](https://github.com/puppetlabs/puppetlabs-reboot/pull/99) ([ferventcoder](https://github.com/ferventcoder))
- (MODULES-2822) Adjust reboot_required specs [#98](https://github.com/puppetlabs/puppetlabs-reboot/pull/98) ([Iristyle](https://github.com/Iristyle))
- (MODULES-2822) Windows provider reboot_required [#97](https://github.com/puppetlabs/puppetlabs-reboot/pull/97) ([Iristyle](https://github.com/Iristyle))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/1.2.0) - 2015-10-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/1.1.0...1.2.0)

### Other

- (maint) Emit Windows debug messages for pending [#94](https://github.com/puppetlabs/puppetlabs-reboot/pull/94) ([Iristyle](https://github.com/Iristyle))
- (FM-3747) Prepare Supported release 1.2.0 [#93](https://github.com/puppetlabs/puppetlabs-reboot/pull/93) ([ferventcoder](https://github.com/ferventcoder))
- (MODULES-2659) Detect CCM pending reboot state [#92](https://github.com/puppetlabs/puppetlabs-reboot/pull/92) ([Iristyle](https://github.com/Iristyle))
- (MODULES-2658) Detect DSC pending reboot state [#91](https://github.com/puppetlabs/puppetlabs-reboot/pull/91) ([Iristyle](https://github.com/Iristyle))
- (MODULES-2674) Windows masterless acceptance testing [#90](https://github.com/puppetlabs/puppetlabs-reboot/pull/90) ([Iristyle](https://github.com/Iristyle))
- (MODULES-2657) Detect Windows computer rename [#88](https://github.com/puppetlabs/puppetlabs-reboot/pull/88) ([Iristyle](https://github.com/Iristyle))
- (maint) Guarantee Facter version for old Puppets / (MODULES-2452) Update Beaker Version [#87](https://github.com/puppetlabs/puppetlabs-reboot/pull/87) ([ferventcoder](https://github.com/ferventcoder))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/1.1.0) - 2015-07-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/1.0.0...1.1.0)

### Other

- (maint) puppetlabs_spec_helper ~>0.10.3 [#86](https://github.com/puppetlabs/puppetlabs-reboot/pull/86) ([ferventcoder](https://github.com/ferventcoder))
- (MODULES-2207) Gem restrictions for Older puppet versions [#84](https://github.com/puppetlabs/puppetlabs-reboot/pull/84) ([ferventcoder](https://github.com/ferventcoder))
- (MODULES-2207) Update Modulesync [#83](https://github.com/puppetlabs/puppetlabs-reboot/pull/83) ([ferventcoder](https://github.com/ferventcoder))
- (FM-2978) Update beaker setting log_level => debug [#82](https://github.com/puppetlabs/puppetlabs-reboot/pull/82) ([cyberious](https://github.com/cyberious))
- (maint) Move to use Beaker-puppet_install_helper - Setup to use puppet_install_helper for simplicity   Allows for AIO testing without addition [#81](https://github.com/puppetlabs/puppetlabs-reboot/pull/81) ([cyberious](https://github.com/cyberious))
- (maint) Update tests to use apply_manifests_on - Also update to accept either of the possible exit codes [#80](https://github.com/puppetlabs/puppetlabs-reboot/pull/80) ([cyberious](https://github.com/cyberious))
- (FM-2752) Add/update travis with modulesync [#78](https://github.com/puppetlabs/puppetlabs-reboot/pull/78) ([cyberious](https://github.com/cyberious))
- FM-2591 - Fix acceptance tests. [#77](https://github.com/puppetlabs/puppetlabs-reboot/pull/77) ([bmjen](https://github.com/bmjen))
- (MODULES-1977) Fix problems with POSIX provider [#76](https://github.com/puppetlabs/puppetlabs-reboot/pull/76) ([elyscape](https://github.com/elyscape))
- (MODULES-1977) Convert Linux provider to POSIX [#75](https://github.com/puppetlabs/puppetlabs-reboot/pull/75) ([elyscape](https://github.com/elyscape))
- (MODULES-1724) Emit notice when scheduling reboot [#74](https://github.com/puppetlabs/puppetlabs-reboot/pull/74) ([elyscape](https://github.com/elyscape))
- Fix reboot spec tests [#73](https://github.com/puppetlabs/puppetlabs-reboot/pull/73) ([cyberious](https://github.com/cyberious))
- 1.0.0 release [#72](https://github.com/puppetlabs/puppetlabs-reboot/pull/72) ([elyscape](https://github.com/elyscape))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-reboot/tree/1.0.0) - 2015-04-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.9...1.0.0)

### Other

- (MODULES-1729) Document Linux :timeout restrictions [#71](https://github.com/puppetlabs/puppetlabs-reboot/pull/71) ([elyscape](https://github.com/elyscape))
- FM-2425 - Supported release 1.0.0 prep [#70](https://github.com/puppetlabs/puppetlabs-reboot/pull/70) ([cyberious](https://github.com/cyberious))
- FM-2393 Fix spacing issues with test cases and the regex to match it [#69](https://github.com/puppetlabs/puppetlabs-reboot/pull/69) ([cyberious](https://github.com/cyberious))
- Updates README per DOC-1495 [#68](https://github.com/puppetlabs/puppetlabs-reboot/pull/68) ([psoloway](https://github.com/psoloway))
- Remove init.pp to pass lint [#67](https://github.com/puppetlabs/puppetlabs-reboot/pull/67) ([hunner](https://github.com/hunner))
- Remove unused and uncessesary init.pp [#66](https://github.com/puppetlabs/puppetlabs-reboot/pull/66) ([cyberious](https://github.com/cyberious))
- Travis improvements: run on non-master branches, build on Ruby 1.8.7, and reduce build times [#65](https://github.com/puppetlabs/puppetlabs-reboot/pull/65) ([elyscape](https://github.com/elyscape))
- (MODULES-1730) Only run the shutdown command once [#64](https://github.com/puppetlabs/puppetlabs-reboot/pull/64) ([elyscape](https://github.com/elyscape))
- (MODULES-1729) Round :timeout up to the nearest minute and warn [#63](https://github.com/puppetlabs/puppetlabs-reboot/pull/63) ([elyscape](https://github.com/elyscape))
- (MODULES-1638) Remove prompt parameter [#62](https://github.com/puppetlabs/puppetlabs-reboot/pull/62) ([elyscape](https://github.com/elyscape))
- Add default action to install_puppet for unsupported platforms [#61](https://github.com/puppetlabs/puppetlabs-reboot/pull/61) ([cyberious](https://github.com/cyberious))
- Fix summary and license in metadata.json [#60](https://github.com/puppetlabs/puppetlabs-reboot/pull/60) ([elyscape](https://github.com/elyscape))
- Replace watcher with at_exit for Windows provider [#59](https://github.com/puppetlabs/puppetlabs-reboot/pull/59) ([elyscape](https://github.com/elyscape))
- Fix checks on output for test cases [#58](https://github.com/puppetlabs/puppetlabs-reboot/pull/58) ([cyberious](https://github.com/cyberious))
- Add Linux support [#57](https://github.com/puppetlabs/puppetlabs-reboot/pull/57) ([elyscape](https://github.com/elyscape))
- Add metadata summary per FM-1523 [#56](https://github.com/puppetlabs/puppetlabs-reboot/pull/56) ([lrnrthr](https://github.com/lrnrthr))
- (maint) Allow setting gem mirror via GEM_SOURCE env var [#54](https://github.com/puppetlabs/puppetlabs-reboot/pull/54) ([justinstoller](https://github.com/justinstoller))
- Merge 0.1.x [#53](https://github.com/puppetlabs/puppetlabs-reboot/pull/53) ([underscorgan](https://github.com/underscorgan))

## [0.1.9](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.9) - 2014-11-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.8...0.1.9)

### Other

- 0.1.9 release prep [#52](https://github.com/puppetlabs/puppetlabs-reboot/pull/52) ([cyberious](https://github.com/cyberious))
- Remove unused gems from Gemfile which were causing issues of Beaker version being updated [#51](https://github.com/puppetlabs/puppetlabs-reboot/pull/51) ([cyberious](https://github.com/cyberious))
- Update Rakefile to rescue LoadError for beaker/tasks/test especially for those on windows [#49](https://github.com/puppetlabs/puppetlabs-reboot/pull/49) ([cyberious](https://github.com/cyberious))
- MODULES-1404 fix project url [#48](https://github.com/puppetlabs/puppetlabs-reboot/pull/48) ([cyberious](https://github.com/cyberious))

## [0.1.8](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.8) - 2014-08-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.7...0.1.8)

### Other

- Release 0.1.8 [#47](https://github.com/puppetlabs/puppetlabs-reboot/pull/47) ([hunner](https://github.com/hunner))
- Foss testing refactor [#46](https://github.com/puppetlabs/puppetlabs-reboot/pull/46) ([cyberious](https://github.com/cyberious))
- Test fixes and merging master to 0.1.x [#45](https://github.com/puppetlabs/puppetlabs-reboot/pull/45) ([cyberious](https://github.com/cyberious))
- (MODULES-1247) FFI module - allow to work on x86 / x64 [#44](https://github.com/puppetlabs/puppetlabs-reboot/pull/44) ([Iristyle](https://github.com/Iristyle))

## [0.1.7](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.7) - 2014-07-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.6...0.1.7)

### Other

- Prepare a 0.1.7 release. [#42](https://github.com/puppetlabs/puppetlabs-reboot/pull/42) ([apenney](https://github.com/apenney))

## [0.1.6](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.6) - 2014-07-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.5...0.1.6)

### Other

- Merged 0.1.x into master branch [#41](https://github.com/puppetlabs/puppetlabs-reboot/pull/41) ([cyberious](https://github.com/cyberious))
- Remove unit tests to test windows isolation as this is testing core confines [#40](https://github.com/puppetlabs/puppetlabs-reboot/pull/40) ([cyberious](https://github.com/cyberious))
- rebase master into 0.1.x [#38](https://github.com/puppetlabs/puppetlabs-reboot/pull/38) ([cyberious](https://github.com/cyberious))
- rebase master into 0.1.x and remove os restriction [#37](https://github.com/puppetlabs/puppetlabs-reboot/pull/37) ([cyberious](https://github.com/cyberious))
- 0.1.6 prep [#34](https://github.com/puppetlabs/puppetlabs-reboot/pull/34) ([underscorgan](https://github.com/underscorgan))
- merge back fixes to master from bugfix release branch [#33](https://github.com/puppetlabs/puppetlabs-reboot/pull/33) ([cyberious](https://github.com/cyberious))
- 0.1.x [#32](https://github.com/puppetlabs/puppetlabs-reboot/pull/32) ([cyberious](https://github.com/cyberious))
- Add testing for unsupported OS and throws error [#29](https://github.com/puppetlabs/puppetlabs-reboot/pull/29) ([cyberious](https://github.com/cyberious))

## [0.1.5](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.5) - 2014-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.4...0.1.5)

### Other

- Patch metadata [#27](https://github.com/puppetlabs/puppetlabs-reboot/pull/27) ([hunner](https://github.com/hunner))
- Release 0.1.5 [#26](https://github.com/puppetlabs/puppetlabs-reboot/pull/26) ([hunner](https://github.com/hunner))
- Add "Release Notes/Known Bugs" to Changelog [#25](https://github.com/puppetlabs/puppetlabs-reboot/pull/25) ([lrnrthr](https://github.com/lrnrthr))
- Update version and metadata for forge [#24](https://github.com/puppetlabs/puppetlabs-reboot/pull/24) ([adreyer](https://github.com/adreyer))

## [0.1.4](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.4) - 2014-02-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/0.1.3...0.1.4)

## [0.1.3](https://github.com/puppetlabs/puppetlabs-reboot/tree/0.1.3) - 2014-02-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-reboot/compare/bb99c810e5a22c068828e365ca54123ea4e1c6cb...0.1.3)
