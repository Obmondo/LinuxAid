<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v3.0.1](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v3.0.1) - 2025-11-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/v3.0.0...v3.0.1)

### Fixed

- Specify correct supported puppet version, 8.x only [#85](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/85) ([tvpartytonight](https://github.com/tvpartytonight))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v3.0.0) - 2025-11-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/v2.1.0...v3.0.0)

### Other

- (PA-7815) Updates for pdk template 3.5.1 [#82](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/82) ([tvpartytonight](https://github.com/tvpartytonight))
- (PA-6856) Add beaker-hostgenerator gem with dynamic version support [#80](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/80) ([skyamgarp](https://github.com/skyamgarp))
- (PA-7366) Use puppetcore for testing [#79](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/79) ([tvpartytonight](https://github.com/tvpartytonight))
- (PA-7215) Add Amazonfips as a supported platform [#78](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/78) ([shubhamshinde360](https://github.com/shubhamshinde360))
- (PA-6139) Drop beaker-puppet_install_helper gem in yumrepo-core module [#73](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/73) ([amitkarsale](https://github.com/amitkarsale))

## [v2.1.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v2.1.0) - 2024-03-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/v2.0.0...v2.1.0)

### Added

- (PA-5575) Add Amazon to display support in Puppet forge [#65](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/65) ([shubhamshinde360](https://github.com/shubhamshinde360))

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v2.0.0) - 2023-06-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/v1.2.0...v2.0.0)

### Changed

- (maint) Drop Puppet 6 and PDK Update [#55](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/55) ([mhashizume](https://github.com/mhashizume))

### Added

- (PA-5187) Add target support [#54](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/54) ([mhashizume](https://github.com/mhashizume))

## [v1.2.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v1.2.0) - 2023-02-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/v1.1.0...v1.2.0)

### Added

- (MODULES-11371) Updates PDK template [#49](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/49) ([mhashizume](https://github.com/mhashizume))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/v1.1.0) - 2021-10-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.7...v1.1.0)

### Added

- (MODULES-11167)(MODULES-11191) Add RockyLinux && AlmaLinux to yumrepo_core metadata [#39](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/39) ([BobosilaVictor](https://github.com/BobosilaVictor))

## [1.0.7](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.7) - 2020-04-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.6...1.0.7)

### Added

- (MODULES-10617) Add property module_hotfixes [#28](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/28) ([seriv](https://github.com/seriv))

## [1.0.6](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.6) - 2019-12-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.5...1.0.6)

### Fixed

- (MODULES-10357) Fix `proxy => absent` [#24](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/24) ([alexjfisher](https://github.com/alexjfisher))

## [1.0.5](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.5) - 2019-12-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.4...1.0.5)

### Fixed

- (MODULES-10246) Proxy settings allow empty string [#22](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/22) ([Dorin-Pleava](https://github.com/Dorin-Pleava))

## [1.0.4](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.4) - 2019-11-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.3...1.0.4)

### Added

- (PUP-10028) Add minrate to yumrepo [#18](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/18) ([jtappa](https://github.com/jtappa))

## [1.0.3](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.3) - 2019-01-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.2...1.0.3)

### Added

- (maint) add LICENSE file [#13](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/13) ([melissa](https://github.com/melissa))

## [1.0.2](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.2) - 2018-11-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.1...1.0.2)

### Added

- (L10n) Update Japanese translations [#9](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/9) ([melissa](https://github.com/melissa))

### Fixed

- (MODULES-8114) Use old way of defining sensitive params [#6](https://github.com/puppetlabs/puppetlabs-yumrepo_core/pull/6) ([melissa](https://github.com/melissa))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.1) - 2018-08-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/puppetlabs/puppetlabs-yumrepo_core/tree/1.0.0) - 2018-07-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-yumrepo_core/compare/5c905b7ed57e5c60b4469050b7306a9c9b78e304...1.0.0)
