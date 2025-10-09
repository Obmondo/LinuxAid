<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/v2.0.0) - 2024-05-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/v1.1.0...v2.0.0)

### Changed

- drop support for Puppet 6 and older [#117](https://github.com/puppetlabs/puppetlabs-hocon/pull/117) ([h0tw1r3](https://github.com/h0tw1r3))
- Drop unsupported operating systems [#114](https://github.com/puppetlabs/puppetlabs-hocon/pull/114) ([h0tw1r3](https://github.com/h0tw1r3))

### Added

- Add current Debian, Ubuntu, and SLES OS support [#115](https://github.com/puppetlabs/puppetlabs-hocon/pull/115) ([h0tw1r3](https://github.com/h0tw1r3))
- add support for Puppet 7 and 8 [#113](https://github.com/puppetlabs/puppetlabs-hocon/pull/113) ([h0tw1r3](https://github.com/h0tw1r3))
- Add EL8 to metadata.json [#106](https://github.com/puppetlabs/puppetlabs-hocon/pull/106) ([trevor-vaughan](https://github.com/trevor-vaughan))

### Fixed

- Fix to replace an existing array with an empty array [#105](https://github.com/puppetlabs/puppetlabs-hocon/pull/105) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/v1.1.0) - 2019-10-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/1.0.1...v1.1.0)

### Added

- Add support for CeentOS, RHEL, and OEL [#90](https://github.com/puppetlabs/puppetlabs-hocon/pull/90) ([trevor-vaughan](https://github.com/trevor-vaughan))
- (MODULES-6805) Add support for Puppet 6 [#88](https://github.com/puppetlabs/puppetlabs-hocon/pull/88) ([tphoney](https://github.com/tphoney))

### Fixed

- Resolve config object before manipulating it [#89](https://github.com/puppetlabs/puppetlabs-hocon/pull/89) ([Magisus](https://github.com/Magisus))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-hocon/tree/1.0.1) - 2018-06-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/1.0.0...1.0.1)

### Other

- 1.0.1 PreRelease [#83](https://github.com/puppetlabs/puppetlabs-hocon/pull/83) ([david22swan](https://github.com/david22swan))
- PDK Convert 1.5.0 [#82](https://github.com/puppetlabs/puppetlabs-hocon/pull/82) ([david22swan](https://github.com/david22swan))
- Add lint to rakefile in .sync.yml [#80](https://github.com/puppetlabs/puppetlabs-hocon/pull/80) ([HelenCampbell](https://github.com/HelenCampbell))
- Remove gitlab file from being managed [#79](https://github.com/puppetlabs/puppetlabs-hocon/pull/79) ([HelenCampbell](https://github.com/HelenCampbell))
- Update .sync.yml for pdk purposes [#77](https://github.com/puppetlabs/puppetlabs-hocon/pull/77) ([HelenCampbell](https://github.com/HelenCampbell))
- (maint) modulesync 65530a4 Update Travis [#73](https://github.com/puppetlabs/puppetlabs-hocon/pull/73) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) - modulesync 384f4c1 [#72](https://github.com/puppetlabs/puppetlabs-hocon/pull/72) ([tphoney](https://github.com/tphoney))
- (maint) - modulesync 1d81b6a [#71](https://github.com/puppetlabs/puppetlabs-hocon/pull/71) ([pmcmaw](https://github.com/pmcmaw))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/1.0.0) - 2017-10-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.4...1.0.0)

### Other

- Updating supported OS for Ubuntu and Debian [#70](https://github.com/puppetlabs/puppetlabs-hocon/pull/70) ([pmcmaw](https://github.com/pmcmaw))
- Document that this module is not meant to manage auth.conf [#69](https://github.com/puppetlabs/puppetlabs-hocon/pull/69) ([ghoneycutt](https://github.com/ghoneycutt))
- (maint) modulesync 892c4cf [#68](https://github.com/puppetlabs/puppetlabs-hocon/pull/68) ([HAIL9000](https://github.com/HAIL9000))
- (MODULES-4854) remove allow_deprecations [#67](https://github.com/puppetlabs/puppetlabs-hocon/pull/67) ([eputnam](https://github.com/eputnam))
- (MODULES-5350) release 1.0.0 prep [#66](https://github.com/puppetlabs/puppetlabs-hocon/pull/66) ([eputnam](https://github.com/eputnam))
- (maint) modulesync 915cde70e20 [#65](https://github.com/puppetlabs/puppetlabs-hocon/pull/65) ([glennsarti](https://github.com/glennsarti))
- (MODULES-5187) mysnc puppet 5 and ruby 2.4 [#64](https://github.com/puppetlabs/puppetlabs-hocon/pull/64) ([eputnam](https://github.com/eputnam))
- (MODULES-5144) Prep for puppet 5 [#63](https://github.com/puppetlabs/puppetlabs-hocon/pull/63) ([hunner](https://github.com/hunner))
- Fix markdown [#62](https://github.com/puppetlabs/puppetlabs-hocon/pull/62) ([hfm](https://github.com/hfm))
- [msync] 786266 Implement puppet-module-gems, a45803 Remove metadata.json from locales config [#61](https://github.com/puppetlabs/puppetlabs-hocon/pull/61) ([wilson208](https://github.com/wilson208))
- [msync] Add locales folder and config.yaml [#60](https://github.com/puppetlabs/puppetlabs-hocon/pull/60) ([wilson208](https://github.com/wilson208))
- remove cprice404 [#58](https://github.com/puppetlabs/puppetlabs-hocon/pull/58) ([call](https://github.com/call))
- (MODULES-4098) Sync the rest of the files [#57](https://github.com/puppetlabs/puppetlabs-hocon/pull/57) ([hunner](https://github.com/hunner))
- (MODULES-4097) Sync travis.yml [#56](https://github.com/puppetlabs/puppetlabs-hocon/pull/56) ([hunner](https://github.com/hunner))
- (FM-5972) gettext and spec.opts [#55](https://github.com/puppetlabs/puppetlabs-hocon/pull/55) ([eputnam](https://github.com/eputnam))
- (MODULES-3631) msync Gemfile for 1.9 frozen strings [#54](https://github.com/puppetlabs/puppetlabs-hocon/pull/54) ([hunner](https://github.com/hunner))
- Designate former tests files as examples [#53](https://github.com/puppetlabs/puppetlabs-hocon/pull/53) ([DavidS](https://github.com/DavidS))
- (maint) Various test fixes [#52](https://github.com/puppetlabs/puppetlabs-hocon/pull/52) ([bmjen](https://github.com/bmjen))
- (maint) Actually fix conditional statement [#51](https://github.com/puppetlabs/puppetlabs-hocon/pull/51) ([HAIL9000](https://github.com/HAIL9000))
- (maint) Correct gem installation conditional [#50](https://github.com/puppetlabs/puppetlabs-hocon/pull/50) ([HAIL9000](https://github.com/HAIL9000))
- (maint) Move the hocon gem to development [#49](https://github.com/puppetlabs/puppetlabs-hocon/pull/49) ([HAIL9000](https://github.com/HAIL9000))
- (MODULES-3704) Update gemfile template to be identical [#48](https://github.com/puppetlabs/puppetlabs-hocon/pull/48) ([hunner](https://github.com/hunner))
- (maint) Use correct providers to install gems [#47](https://github.com/puppetlabs/puppetlabs-hocon/pull/47) ([HAIL9000](https://github.com/HAIL9000))
- (HC-98) Update specs to reflect new output format [#46](https://github.com/puppetlabs/puppetlabs-hocon/pull/46) ([HAIL9000](https://github.com/HAIL9000))
- Change 0x2002 to 0x20 [#45](https://github.com/puppetlabs/puppetlabs-hocon/pull/45) ([hunner](https://github.com/hunner))
- Fix sync [#44](https://github.com/puppetlabs/puppetlabs-hocon/pull/44) ([hunner](https://github.com/hunner))
- (HC-94) Add hocon to module sync [#42](https://github.com/puppetlabs/puppetlabs-hocon/pull/42) ([HAIL9000](https://github.com/HAIL9000))
- (HC-91) Make tests compatible with newer ruby versions [#39](https://github.com/puppetlabs/puppetlabs-hocon/pull/39) ([HAIL9000](https://github.com/HAIL9000))
- (maint) Fix indentation error in test file [#38](https://github.com/puppetlabs/puppetlabs-hocon/pull/38) ([HAIL9000](https://github.com/HAIL9000))
- (maint) Update PuppetLint configuration [#37](https://github.com/puppetlabs/puppetlabs-hocon/pull/37) ([HAIL9000](https://github.com/HAIL9000))
- Add internal_list key to MAINTAINERS [#36](https://github.com/puppetlabs/puppetlabs-hocon/pull/36) ([theshanx](https://github.com/theshanx))
- (200) Add MAINTAINERS [#35](https://github.com/puppetlabs/puppetlabs-hocon/pull/35) ([cprice404](https://github.com/cprice404))
- Add maintainers section [#32](https://github.com/puppetlabs/puppetlabs-hocon/pull/32) ([karenvdv](https://github.com/karenvdv))
- (HC-30) Make path and setting namevars [#30](https://github.com/puppetlabs/puppetlabs-hocon/pull/30) ([MSLilah](https://github.com/MSLilah))

## [0.9.4](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.4) - 2016-03-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.3...0.9.4)

### Other

- Release 0.9.4 [#29](https://github.com/puppetlabs/puppetlabs-hocon/pull/29) ([hunner](https://github.com/hunner))
- (HC-46) Confine provider based on hocon feature [#28](https://github.com/puppetlabs/puppetlabs-hocon/pull/28) ([joshcooper](https://github.com/joshcooper))
- (HC-31) Handle type change from scalar -> array [#26](https://github.com/puppetlabs/puppetlabs-hocon/pull/26) ([vilmibm](https://github.com/vilmibm))
- (HC-33) Support adding element when array does not exist yet [#25](https://github.com/puppetlabs/puppetlabs-hocon/pull/25) ([camlow325](https://github.com/camlow325))

## [0.9.3](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.3) - 2015-09-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.2...0.9.3)

### Other

- 0.9.3 prep [#24](https://github.com/puppetlabs/puppetlabs-hocon/pull/24) ([underscorgan](https://github.com/underscorgan))
- Add array_element [#23](https://github.com/puppetlabs/puppetlabs-hocon/pull/23) ([underscorgan](https://github.com/underscorgan))
- (MAINT) Update to hocon 0.9.2 [#20](https://github.com/puppetlabs/puppetlabs-hocon/pull/20) ([MSLilah](https://github.com/MSLilah))

## [0.9.2](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.2) - 2015-06-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.1...0.9.2)

### Other

- Make metadata match PMT output [#19](https://github.com/puppetlabs/puppetlabs-hocon/pull/19) ([underscorgan](https://github.com/underscorgan))
- aio fixes [#18](https://github.com/puppetlabs/puppetlabs-hocon/pull/18) ([underscorgan](https://github.com/underscorgan))
- Switch to using puppet_install_helper to support AIO testing [#17](https://github.com/puppetlabs/puppetlabs-hocon/pull/17) ([underscorgan](https://github.com/underscorgan))
- Remove unnecessary hocon require, add write_conf method [#16](https://github.com/puppetlabs/puppetlabs-hocon/pull/16) ([highb](https://github.com/highb))

## [0.9.1](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.1) - 2015-05-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.0...0.9.1)

### Other

- Release 0.9.1 prep [#15](https://github.com/puppetlabs/puppetlabs-hocon/pull/15) ([bmjen](https://github.com/bmjen))
- (MAINT) Set up Travis [#14](https://github.com/puppetlabs/puppetlabs-hocon/pull/14) ([MSLilah](https://github.com/MSLilah))
- (MAINT) Fix README examples [#13](https://github.com/puppetlabs/puppetlabs-hocon/pull/13) ([MSLilah](https://github.com/MSLilah))
- Handle stringified numerics [#12](https://github.com/puppetlabs/puppetlabs-hocon/pull/12) ([glarizza](https://github.com/glarizza))

## [0.9.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.0) - 2015-04-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/2949ddadc2fea633fffa90fe74f4207a4c730a3a...0.9.0)
