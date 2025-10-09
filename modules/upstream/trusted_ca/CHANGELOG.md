# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.1.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v5.1.0) (2024-08-21)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v5.0.0...v5.1.0)

**Implemented enhancements:**

- Support Debian 11 & 12 + Ubuntu 22.04 & 24.04 [\#70](https://github.com/voxpupuli/puppet-trusted_ca/pull/70) ([ekohl](https://github.com/ekohl))
- Support EL 9: Avoid running update-ca-trust twice [\#69](https://github.com/voxpupuli/puppet-trusted_ca/pull/69) ([ekohl](https://github.com/ekohl))
- Convert to puppet-strings documentation [\#61](https://github.com/voxpupuli/puppet-trusted_ca/pull/61) ([ekohl](https://github.com/ekohl))
- Use validate\_cmd & expose filename parameter [\#60](https://github.com/voxpupuli/puppet-trusted_ca/pull/60) ([ekohl](https://github.com/ekohl))

## [v5.0.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v5.0.0) (2023-08-02)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v4.1.0...v5.0.0)

**Breaking changes:**

- require puppetlabs/stdlib 9 [\#52](https://github.com/voxpupuli/puppet-trusted_ca/pull/52) ([robertc99](https://github.com/robertc99))
- Drop Puppet 6 support / Drop EoL Debian 9 [\#50](https://github.com/voxpupuli/puppet-trusted_ca/pull/50) ([bastelfreak](https://github.com/bastelfreak))
- Default to using the installed version [\#48](https://github.com/voxpupuli/puppet-trusted_ca/pull/48) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Add Puppet 8 support [\#55](https://github.com/voxpupuli/puppet-trusted_ca/pull/55) ([bastelfreak](https://github.com/bastelfreak))

## [v4.1.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v4.1.0) (2022-03-09)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Drop requirement for CA sources to use platform-specific suffix [\#40](https://github.com/voxpupuli/puppet-trusted_ca/pull/40) ([optiz0r](https://github.com/optiz0r))
- Allow stdlib 8.x dependencies [\#39](https://github.com/voxpupuli/puppet-trusted_ca/pull/39) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v4.0.0) (2021-06-02)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v3.1.0...v4.0.0)

This release drops compatibility with EOL distros. This means EL6 (which can no longer be tested since the CentOS repos have been removed), Ubuntu 16.04 (EOL since April 2021) and Debian 8 (LTS is EOL since July 2020, though there is ELTS).

Puppet 5 support is also dropped since it went EOL in February 2021.

It should be noted that this it metadata-only. No code was changed.

**Breaking changes:**

- Drop Puppet 5 support [\#36](https://github.com/voxpupuli/puppet-trusted_ca/pull/36) ([ekohl](https://github.com/ekohl))
- Drop Ubuntu 16.04 and Debian 8 support [\#35](https://github.com/voxpupuli/puppet-trusted_ca/pull/35) ([ekohl](https://github.com/ekohl))
- Drop EL6 support [\#29](https://github.com/voxpupuli/puppet-trusted_ca/pull/29) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Mark compatible with Ubuntu 20.04 [\#33](https://github.com/voxpupuli/puppet-trusted_ca/pull/33) ([ekohl](https://github.com/ekohl))
- Mark compatible with Puppet 7 [\#32](https://github.com/voxpupuli/puppet-trusted_ca/pull/32) ([ekohl](https://github.com/ekohl))
- Mark compatible with puppetlabs/stdlib 7.x [\#31](https://github.com/voxpupuli/puppet-trusted_ca/pull/31) ([ekohl](https://github.com/ekohl))

## [v3.1.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v3.1.0) (2020-05-11)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v3.0.0...v3.1.0)

**Breaking changes:**

- drop Ubuntu 14.04 support [\#16](https://github.com/voxpupuli/puppet-trusted_ca/pull/16) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add EL8 support [\#24](https://github.com/voxpupuli/puppet-trusted_ca/pull/24) ([ehelms](https://github.com/ehelms))
- Add Debian 10 support [\#21](https://github.com/voxpupuli/puppet-trusted_ca/pull/21) ([ekohl](https://github.com/ekohl))
- Make aliases stored in java keystore case insensitive [\#18](https://github.com/voxpupuli/puppet-trusted_ca/pull/18) ([pseiler](https://github.com/pseiler))

**Fixed bugs:**

- keystore needs to be checked on each puppet run [\#15](https://github.com/voxpupuli/puppet-trusted_ca/pull/15) ([pseiler](https://github.com/pseiler))
- fixed behaviour for SLES \> 11, support SLES 15 [\#14](https://github.com/voxpupuli/puppet-trusted_ca/pull/14) ([pseiler](https://github.com/pseiler))

**Merged pull requests:**

- Use voxpupuli-acceptance [\#23](https://github.com/voxpupuli/puppet-trusted_ca/pull/23) ([ekohl](https://github.com/ekohl))
- updated supported distributions in README [\#19](https://github.com/voxpupuli/puppet-trusted_ca/pull/19) ([pseiler](https://github.com/pseiler))
- Remove duplicate CONTRIBUTING.md file [\#17](https://github.com/voxpupuli/puppet-trusted_ca/pull/17) ([dhoppe](https://github.com/dhoppe))

## [v3.0.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v3.0.0) (2019-05-30)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- drop puppet 4 support. require at least puppet 5.5.8 [\#11](https://github.com/voxpupuli/puppet-trusted_ca/pull/11) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Use ensure\_packages to allow multiple package declarations [\#9](https://github.com/voxpupuli/puppet-trusted_ca/pull/9) ([dol](https://github.com/dol))

**Closed issues:**

- Package\[ca-certificates\] is already declared at [\#8](https://github.com/voxpupuli/puppet-trusted_ca/issues/8)

**Merged pull requests:**

- allow puppetlabs-stdlib 6.x [\#10](https://github.com/voxpupuli/puppet-trusted_ca/pull/10) ([mmoll](https://github.com/mmoll))
- \(docs\) Match documentation to metadata [\#6](https://github.com/voxpupuli/puppet-trusted_ca/pull/6) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.0.0](https://github.com/voxpupuli/puppet-trusted_ca/tree/v2.0.0) (2018-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-trusted_ca/compare/1.1.0...v2.0.0)

**Breaking changes:**

- Drop Puppet \<4.10.0 release [\#4](https://github.com/voxpupuli/puppet-trusted_ca/issues/4)

**Merged pull requests:**

- Change module to Voxpupuli and modernize [\#1](https://github.com/voxpupuli/puppet-trusted_ca/pull/1) ([ekohl](https://github.com/ekohl))

## 1.1.0
  Add support for SLES 12, Ubuntu 15.10 <Sebastian Reitenbach>
  Renamed from evenup to jlambert121
## 1.0.1
  Fix relationship with jks <adamwenner>
## 1.0.0
  Rewrote module to use system methods for trusted certificates
  Add separate java define for java keystores
  Add acceptance tests
  Remove dependency on puppetlabs/concat
## 0.3.0
  Allow specifying java_keystore file
  Doc fixes
## 0.2.0
  Update certificate install method
## 0.1.2
  Java class required for keytool
## 0.1.1
  Fix path
## 0.1.0
  Add ability to add CA to java keyfile
  Spec updates
## 0.0.2:
  Fix documentation
## 0.0.1:
  Initial release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
