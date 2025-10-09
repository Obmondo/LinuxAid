# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v1.0.0](https://github.com/voxpupuli/puppet-drbd/tree/v1.0.0) (2025-09-24)

[Full Changelog](https://github.com/voxpupuli/puppet-drbd/compare/v0.5.2...v1.0.0)

**Breaking changes:**

- Define package name for RedHat family. [\#140](https://github.com/voxpupuli/puppet-drbd/pull/140) ([FZoffel](https://github.com/FZoffel))
- Drop puppet, update openvox minimum version to 8.19 [\#138](https://github.com/voxpupuli/puppet-drbd/pull/138) ([TheMeier](https://github.com/TheMeier))
- Drop RedHat 6 and 7 [\#128](https://github.com/voxpupuli/puppet-drbd/pull/128) ([zilchms](https://github.com/zilchms))
- Drop Debian 8, 9 and 10 [\#127](https://github.com/voxpupuli/puppet-drbd/pull/127) ([zilchms](https://github.com/zilchms))
- Drop Puppet 6 support [\#114](https://github.com/voxpupuli/puppet-drbd/pull/114) ([bastelfreak](https://github.com/bastelfreak))
- drop Ubuntu support [\#95](https://github.com/voxpupuli/puppet-drbd/pull/95) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 2.7.0 and drop puppet 4 [\#85](https://github.com/voxpupuli/puppet-drbd/pull/85) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- metadata.json: Add OpenVox [\#134](https://github.com/voxpupuli/puppet-drbd/pull/134) ([jstraw](https://github.com/jstraw))
- Update Readme, delete old travis information and fix rubocop todos [\#129](https://github.com/voxpupuli/puppet-drbd/pull/129) ([zilchms](https://github.com/zilchms))
- Add Debian 11 and 12 [\#126](https://github.com/voxpupuli/puppet-drbd/pull/126) ([zilchms](https://github.com/zilchms))
- Add Ubuntu 20.04, 22.04 and 24.04 support [\#125](https://github.com/voxpupuli/puppet-drbd/pull/125) ([zilchms](https://github.com/zilchms))
- Add RedHat 8 and 9 support [\#119](https://github.com/voxpupuli/puppet-drbd/pull/119) ([zilchms](https://github.com/zilchms))
- puppetlabs/concat: Allow 9.x [\#118](https://github.com/voxpupuli/puppet-drbd/pull/118) ([zilchms](https://github.com/zilchms))
- Add Puppet 8 support [\#116](https://github.com/voxpupuli/puppet-drbd/pull/116) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#115](https://github.com/voxpupuli/puppet-drbd/pull/115) ([bastelfreak](https://github.com/bastelfreak))
- Parameters for global options [\#113](https://github.com/voxpupuli/puppet-drbd/pull/113) ([trefzer](https://github.com/trefzer))
- Fix package names with hiera / Add Debian 8/9/10 support [\#93](https://github.com/voxpupuli/puppet-drbd/pull/93) ([trefzer](https://github.com/trefzer))
- New features: external metadisk, handlers\_parameters, startup\_parameters, split initialize/up [\#87](https://github.com/voxpupuli/puppet-drbd/pull/87) ([slm0n87](https://github.com/slm0n87))

**Fixed bugs:**

- fix resource not defined in your config \(for this host\) for fqdn [\#100](https://github.com/voxpupuli/puppet-drbd/pull/100) ([efoft](https://github.com/efoft))
- fix metadisk parameter [\#94](https://github.com/voxpupuli/puppet-drbd/pull/94) ([trefzer](https://github.com/trefzer))
- fix dependency, exec depends on himself [\#92](https://github.com/voxpupuli/puppet-drbd/pull/92) ([trefzer](https://github.com/trefzer))
- Allow puppetlabs/concat 6.x, puppetlabs/stdlib 6.x [\#88](https://github.com/voxpupuli/puppet-drbd/pull/88) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- Ubuntu Support - README and metadata.json mismatch [\#110](https://github.com/voxpupuli/puppet-drbd/issues/110)
- Puppet 7 Support [\#109](https://github.com/voxpupuli/puppet-drbd/issues/109)
- drbd package name has changed for most distros [\#89](https://github.com/voxpupuli/puppet-drbd/issues/89)
- check debian support [\#69](https://github.com/voxpupuli/puppet-drbd/issues/69)
- Update module on puppetforge? [\#34](https://github.com/voxpupuli/puppet-drbd/issues/34)
- Package name needs to be configurable [\#25](https://github.com/voxpupuli/puppet-drbd/issues/25)
- voxpupuli transfer checklist [\#24](https://github.com/voxpupuli/puppet-drbd/issues/24)

**Merged pull requests:**

- document with strings [\#142](https://github.com/voxpupuli/puppet-drbd/pull/142) ([trefzer](https://github.com/trefzer))
- Allow stdlib 8.0.0 [\#107](https://github.com/voxpupuli/puppet-drbd/pull/107) ([smortex](https://github.com/smortex))
- modulesync 3.0.0 & puppet-lint updates [\#102](https://github.com/voxpupuli/puppet-drbd/pull/102) ([bastelfreak](https://github.com/bastelfreak))
- update repo links to https [\#99](https://github.com/voxpupuli/puppet-drbd/pull/99) ([bastelfreak](https://github.com/bastelfreak))
- Remove duplicate CONTRIBUTING.md file [\#96](https://github.com/voxpupuli/puppet-drbd/pull/96) ([dhoppe](https://github.com/dhoppe))

## [v0.5.2](https://github.com/voxpupuli/puppet-drbd/tree/v0.5.2) (2018-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-drbd/compare/v0.5.1...v0.5.2)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#81](https://github.com/voxpupuli/puppet-drbd/pull/81) ([bastelfreak](https://github.com/bastelfreak))

## [v0.5.1](https://github.com/voxpupuli/puppet-drbd/tree/v0.5.1) (2018-09-06)

[Full Changelog](https://github.com/voxpupuli/puppet-drbd/compare/v0.5.0...v0.5.1)

**Closed issues:**

- Update dependency towards concat module [\#60](https://github.com/voxpupuli/puppet-drbd/issues/60)

**Merged pull requests:**

- allow puppetlabs/stdlib 5.x [\#79](https://github.com/voxpupuli/puppet-drbd/pull/79) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#77](https://github.com/voxpupuli/puppet-drbd/pull/77) ([bastelfreak](https://github.com/bastelfreak))
- Remove docker nodesets [\#70](https://github.com/voxpupuli/puppet-drbd/pull/70) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#68](https://github.com/voxpupuli/puppet-drbd/pull/68) ([bastelfreak](https://github.com/bastelfreak))
- bump puppet version dependency to \>= 4.10.0 \< 6.0.0 [\#67](https://github.com/voxpupuli/puppet-drbd/pull/67) ([bastelfreak](https://github.com/bastelfreak))
- Allow concat module version up to 4.1.1 [\#61](https://github.com/voxpupuli/puppet-drbd/pull/61) ([Yyuzu](https://github.com/Yyuzu))

## [v0.5.0](https://github.com/voxpupuli/puppet-drbd/tree/v0.5.0) (2017-11-16)

[Full Changelog](https://github.com/voxpupuli/puppet-drbd/compare/v0.4.0...v0.5.0)

**Merged pull requests:**

- bump puppet version dependency to \>= 4.7.1 \< 6.0.0 [\#57](https://github.com/voxpupuli/puppet-drbd/pull/57) ([bastelfreak](https://github.com/bastelfreak))
- Add disk parameters support in resources [\#54](https://github.com/voxpupuli/puppet-drbd/pull/54) ([jsosic](https://github.com/jsosic))

## [v0.4.0](https://github.com/voxpupuli/puppet-drbd/tree/v0.4.0) (2017-02-11)

This is the last release with Puppet3 support!
* Modulesync with latest Vox Pupuli defaults
* Allow changing of drbd-utils pacakge name

## 2016-12-24 Release 0.3.0

* Modulesync with latest Vox Pupuli defaults
* Support puppetlabs-concat >= 2
* Cleanup spec tests
* use drbd as package name resource
* Add minimal documentation
* Add missing require of package drbd in drbd::service
* Set minimum version dependencies (for Puppet 4)

## 2016-08-19 Release 0.2.0

  * First release in the Vox Pupuli namespace
  * Drop of ruby1.8.7 support
  * Modulesync with latest Vox Pupuli defaults
  * adds the rate option
  * stacked-on-top-of support
  * Allow configurable mkfs options
  * Don't create-md during VerifyS and VerifyT states
  * Allow to disable service
  * Allow to specify rate
  * Allow to specify net parameters
  * add missing dep on puppetlabs/stdlib


## 2012-10-14 Release 0.1.0

  * Initial PuppetLabs release
  * Auto-discovery via exported resource
  * Static-discovery via parameters
  * Optional disk formatting
  * Alternate mountpoints
  * Mountpoint owner/groups


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
