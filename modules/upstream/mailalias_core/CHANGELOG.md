# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [1.0.5] - 2019-01-11
### Added
- Added LICENSE file
- Added test matrix to test against puppet 6

## [1.0.4] - 2018-08-17
### Added
- (PUP-9053) Enable localization
### Changed
- (PUP-9052) Bump puppet req to at least puppet 6

## [1.0.3] - 2018-05-18
### Changed
- Update PDK to 1.5.0
- Change mocks to use rspec rather than mocha
- Update acceptance tests to run successfully in a random order

## [1.0.2] - 2018-04-30
### Added
- Gem dependency on puppet-blacksmith, which is required to ship to the module
  to forge.puppet.com
### Changed
- The Gemfile and spec/spec_helper.rb are managed by pdk. Any additional content
  for these files should be defined in .syn.yml and spec/spec_helper_local.rb
  respectively

## [1.0.1] - 2018-04-30
### Summary
This is an empty release to test the release pipeline

## [1.0.0] - 2018-04-27
### Summary
This is the initial release of the extracted mailalias module

[1.0.5]: https://github.com/puppetlabs/puppetlabs-mailalias_core/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/puppetlabs/puppetlabs-mailalias_core/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/puppetlabs/puppetlabs-mailalias_core/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/puppetlabs/puppetlabs-mailalias_core/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/puppetlabs/puppetlabs-mailalias_core/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/puppetlabs/puppetlabs-mailalias_core/releases/tag/1.0.0
