<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.0.1](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v2.0.1) - 2025-11-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v2.0.0...v2.0.1)

### Other

- Specify correct supported puppet version, 8.x only [#98](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/98) ([tvpartytonight](https://github.com/tvpartytonight))

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v2.0.0) - 2025-11-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v1.6.1...v2.0.0)

### Other

- (PA-7815) Updates for pdk template 3.5.1 [#96](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/96) ([tvpartytonight](https://github.com/tvpartytonight))
- (PA-7366) Use puppetcore for testing [#93](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/93) ([tvpartytonight](https://github.com/tvpartytonight))
- (PA-6139) Drop beaker-puppet_install_helper gem in zfs-core module [#90](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/90) ([amitkarsale](https://github.com/amitkarsale))

## [v1.6.1](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v1.6.1) - 2024-07-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v1.6.0) - 2024-07-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v1.5.0...v1.6.0)

### Added

- (PA-6738) Update zfs with relatime support [#84](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/84) ([AriaXLi](https://github.com/AriaXLi))
- (PA-5790) Add zfs attribute defaultuserquota [#83](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/83) ([AriaXLi](https://github.com/AriaXLi))
- Add support for nvme devices [#66](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/66) ([murkyway](https://github.com/murkyway))

## [v1.5.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v1.5.0) - 2024-03-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v1.4.0...v1.5.0)

## [v1.4.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v1.4.0) - 2023-02-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/v1.3.0...v1.4.0)

### Added

- (PA-4806) Updates PDK template [#56](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/56) ([mhashizume](https://github.com/mhashizume))

## [v1.3.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/v1.3.0) - 2021-10-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.2.0...v1.3.0)

### Added

- (MODULES-10874) Add property 'sync' [#43](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/43) ([puppetjoy](https://github.com/puppetjoy))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.2.0) - 2020-10-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.1.0...1.2.0)

### Added

- (Modules-7207) Add 'caches' support [#38](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/38) ([kBite](https://github.com/kBite))

### Fixed

- (MODULES-10848) Do not redefine PARAMETER_UNSET_OR_NOT_AVAILABLE [#39](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/39) ([beechtom](https://github.com/beechtom))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.1.0) - 2020-07-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.5...1.1.0)

### Added

- (MODULES-10726) Add support for ashift/autoexpand/failmode to the zpool provider. [#30](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/30) ([KeithWard](https://github.com/KeithWard))

## [1.0.5](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.5) - 2020-04-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.4...1.0.5)

### Fixed

- (MODULES-10592) Fix `zpool status` parsing on Linux [#27](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/27) ([GabrielNagy](https://github.com/GabrielNagy))

## [1.0.4](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.4) - 2019-11-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.3...1.0.4)

### Fixed

- (MODULES-8823) Better handling of ZFS overlay property on Linux [#23](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/23) ([GabrielNagy](https://github.com/GabrielNagy))

## [1.0.3](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.3) - 2019-11-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.2...1.0.3)

### Added

- (MODULES-8823) Add support for overlay option in zfs on Linux [#22](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/22) ([GabrielNagy](https://github.com/GabrielNagy))
- Use "zpool status -P" instead of "zpool status" [#14](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/14) ([bluthg](https://github.com/bluthg))

## [1.0.2](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.2) - 2019-02-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.1...1.0.2)

### Added

- Add anchors for l10n [#10](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/10) ([joshcooper](https://github.com/joshcooper))
- Expand test coverage [#8](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/8) ([joshcooper](https://github.com/joshcooper))
-  (L10n) Delivering translations for POT and README files [#7](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/7) ([ehom](https://github.com/ehom))

### Fixed

- (L10n) Updating translations for readmes/README_ja_JP.md [#11](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/11) ([ehom](https://github.com/ehom))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.1) - 2018-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/1.0.0...1.0.1)

### Added

- Install module on all hosts, not just those with default role [#4](https://github.com/puppetlabs/puppetlabs-zfs_core/pull/4) ([joshcooper](https://github.com/joshcooper))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-zfs_core/tree/1.0.0) - 2018-05-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-zfs_core/compare/576d12b67e6d531b15315329d7a98f4c3549e2dc...1.0.0)
