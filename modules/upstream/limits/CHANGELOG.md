# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[5.0.0]
### Changed
- little code modernization (#57)
- Fix limits_template on Debian (#59)
- drop some EOL operating system releases (#58) => Debian 10, CentOS 7/8, RedHat 7

[4.0.1]
### Changed
- drop explicit version requirements in .fixtures.yml (#54)

[4.0.0]
### Added
- add empty template, fixes #47 (#52)
- Add the management of limits.conf file. (#44)
- Allow managing multiple settings in one file (#45)
- Allow Puppet 8 (#51)
- Add Ubuntu 24.04 and Debian 12 as supported OS (#51)
### Changed
- allow puppetlabs/concat < 10 (#51)
### Fixed
- Add line end character for top comment and use proper matchers for acceptance tests (#49)
### Removed
- remove Debian 9 as supported OS
- drop Puppet 6 support (#51)
- remove Ubuntu 18.04 as supported OS (#51)

[3.1.0]
### Changed
- Update Puppet version requirement to include version 7 (< 8.0.0) (#40)
- Switch to GitHub Actions and add basic acceptance tests (#41)
- Use hiera for default values (#37)

[3.0.4]
### Added
- CHANGELOG.md added
### Changed
- Update Puppet version requirement to include version 6 (< 7.0.0)
