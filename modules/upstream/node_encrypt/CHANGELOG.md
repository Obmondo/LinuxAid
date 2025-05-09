<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v3.2.0) - 2024-12-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v3.1.0...v3.2.0)

### Added

- (CAT-2124) Add support for Ubuntu 24 [#120](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/120) ([skyamgarp](https://github.com/skyamgarp))
- (CAT-2100) Add Debian 12 support [#119](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/119) ([shubhamshinde360](https://github.com/shubhamshinde360))

### Fixed

- (CAT-2158) Upgrade rexml to address CVE-2024-49761 [#121](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/121) ([amitkarsale](https://github.com/amitkarsale))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v3.1.0) - 2024-04-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v3.0.0...v3.1.0)

### Added

- (MAINT) - Fixing dependency issue [#111](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/111) ([Ramesh7](https://github.com/Ramesh7))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v3.0.0) - 2023-06-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v2.0.0...v3.0.0)

### Changed

- (CONT-1042) - Remove unsupported OS [#96](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/96) ([jordanbreen28](https://github.com/jordanbreen28))
- (CONT-1041) - Add Puppet 8 Support/Drop Puppet 6 Support [#95](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/95) ([jordanbreen28](https://github.com/jordanbreen28))
- (CONT-1048) - Removal of deprecated node_encrypt::file defined type [#94](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/94) ([jordanbreen28](https://github.com/jordanbreen28))

### Added

- (CONT-1042) - Add Support for Ubuntu 22.04 [#97](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/97) ([jordanbreen28](https://github.com/jordanbreen28))
- (CONT-88) - Add puppet module support [#93](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/93) ([jordanbreen28](https://github.com/jordanbreen28))

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v2.0.0) - 2022-10-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v1.0.0...v2.0.0)

## [v1.0.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v1.0.0) - 2022-10-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.4.1...v1.0.0)

### Changed

- Remove legacy support. This now requires Puppet 6.x+ [#82](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/82) ([binford2k](https://github.com/binford2k))

### Added

- Add support for mocking (Onceover/rspec) [#70](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/70) ([alexjfisher](https://github.com/alexjfisher))

### Fixed

- pdk apparently requires you to manually ignore .git [#83](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/83) ([binford2k](https://github.com/binford2k))
- Fix redacting shared defined type parameters [#75](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/75) ([alexjfisher](https://github.com/alexjfisher))

## [v0.4.1](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.4.1) - 2019-08-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.4.0...v0.4.1)

### Fixed

- Allow node_encrypt::secret to accept Sensitive[String] values [#52](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/52) ([danielparks](https://github.com/danielparks))

## [v0.4.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.4.0) - 2019-01-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.3.3...v0.4.0)

### Added

- Use client certs from the CA if they exist [#48](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/48) ([binford2k](https://github.com/binford2k))
- Add p6 Deferred function [#46](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/46) ([binford2k](https://github.com/binford2k))
- Disable verification for Puppet 6 certificate chain [#41](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/41) ([binford2k](https://github.com/binford2k))
- Try a different approach to determining what certs to use [#37](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/37) ([binford2k](https://github.com/binford2k))
- Support Sensitive values to node_encrypt::file [#35](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/35) ([danielparks](https://github.com/danielparks))

### Fixed

- Add alternate of sending clientcert as fact [#49](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/49) ([binford2k](https://github.com/binford2k))
- delete the no longer relevant test [#47](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/47) ([binford2k](https://github.com/binford2k))
- certificates: Do not purge cached ca.pem. [#45](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/45) ([olifre](https://github.com/olifre))
- Purge stale certificates [#44](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/44) ([binford2k](https://github.com/binford2k))
- Remove serialized class from transactionstore [#43](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/43) ([binford2k](https://github.com/binford2k))

## [v0.3.3](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.3.3) - 2018-06-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.3.1...v0.3.3)

### Fixed

- This should be a != compare as if the node's puppet server is not the… [#28](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/28) ([dustinak](https://github.com/dustinak))

## [v0.3.1](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.3.1) - 2017-11-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.3.0...v0.3.1)

## [v0.3.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.3.0) - 2017-10-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.7...v0.3.0)

### Added

- Add Puppet 5 support to the certificates class [#23](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/23) ([binford2k](https://github.com/binford2k))
- node_encrypt.rb: Use dummy 4 byte password to read key. [#20](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/20) ([olifre](https://github.com/olifre))

### Fixed

- Use pseudo-relative include paths in parser-function and type. [#19](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/19) ([olifre](https://github.com/olifre))

## [v0.2.7](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.7) - 2017-06-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.6...v0.2.7)

### Added

- Allow redact to take defines as well as classes [#17](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/17) ([ross-w](https://github.com/ross-w))

## [v0.2.6](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.6) - 2017-06-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.5...v0.2.6)

### Fixed

- Correctly Handle Namespace Capitalization [#15](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/15) ([JeremyEinfeld](https://github.com/JeremyEinfeld))

## [v0.2.5](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.5) - 2016-04-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.4...v0.2.5)

## [v0.2.4](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.4) - 2016-03-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.3...v0.2.4)

## [v0.2.3](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.3) - 2016-02-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.2...v0.2.3)

## [v0.2.2](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.2) - 2015-12-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.2.1...v0.2.2)

## [v0.2.1](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.2.1) - 2015-12-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.1.2...v0.2.1)

### Added

- Allow to run on non-CA nodes. Requires setup. [#2](https://github.com/puppetlabs/puppetlabs-node_encrypt/pull/2) ([binford2k](https://github.com/binford2k))

## [v0.1.2](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.1.2) - 2015-12-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.1.1...v0.1.2)

## [v0.1.1](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.1.1) - 2015-12-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/puppetlabs/puppetlabs-node_encrypt/tree/v0.1.0) - 2015-12-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-node_encrypt/compare/edf02937dbb441fc254aa0e9939fb94fca0edb10...v0.1.0)
