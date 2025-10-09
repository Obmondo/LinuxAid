# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v5.0.0](https://github.com/voxpupuli/puppet-mumble/tree/v5.0.0) (2023-07-13)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v4.0.0...v5.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#79](https://github.com/voxpupuli/puppet-mumble/pull/79) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Puppet 8 support [\#83](https://github.com/voxpupuli/puppet-mumble/pull/83) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#82](https://github.com/voxpupuli/puppet-mumble/pull/82) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/apt: Allow 9.x [\#81](https://github.com/voxpupuli/puppet-mumble/pull/81) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/voxpupuli/puppet-mumble/tree/v4.0.0) (2021-09-09)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- Drop support for Debian 9, Ubuntu 16.04 \(EOL\) [\#72](https://github.com/voxpupuli/puppet-mumble/pull/72) ([smortex](https://github.com/smortex))
- Drop support of Puppet 5 \(EOL\) [\#70](https://github.com/voxpupuli/puppet-mumble/pull/70) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add support for Puppet 7 [\#71](https://github.com/voxpupuli/puppet-mumble/pull/71) ([smortex](https://github.com/smortex))
- Add support for Debian 11 and Ubuntu 20.04 [\#68](https://github.com/voxpupuli/puppet-mumble/pull/68) ([smortex](https://github.com/smortex))

**Merged pull requests:**

- Allow stdlib 8.x and apt 7.x [\#67](https://github.com/voxpupuli/puppet-mumble/pull/67) ([smortex](https://github.com/smortex))
- modulesync 3.0.0 & puppet-lint updates [\#64](https://github.com/voxpupuli/puppet-mumble/pull/64) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-mumble/tree/v3.0.0) (2020-05-09)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v2.1.2...v3.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#49](https://github.com/voxpupuli/puppet-mumble/pull/49) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- mumble\_set\_password fail with exit code 1 [\#52](https://github.com/voxpupuli/puppet-mumble/issues/52)
- fix mumble\_set\_password \(idempotency and returns\)\(Closes: \#52\) [\#53](https://github.com/voxpupuli/puppet-mumble/pull/53) ([sbadia](https://github.com/sbadia))

**Closed issues:**

- check debian support [\#36](https://github.com/voxpupuli/puppet-mumble/issues/36)
- registerName option in mumble.ini is not a parameter [\#3](https://github.com/voxpupuli/puppet-mumble/issues/3)

**Merged pull requests:**

- Use voxpupuli-acceptance [\#62](https://github.com/voxpupuli/puppet-mumble/pull/62) ([ekohl](https://github.com/ekohl))
- Fix for server\_password management [\#60](https://github.com/voxpupuli/puppet-mumble/pull/60) ([smortex](https://github.com/smortex))
- Clean up acceptance spec helper [\#57](https://github.com/voxpupuli/puppet-mumble/pull/57) ([ekohl](https://github.com/ekohl))
- fix puppet-string annotations & Generate REFERENCE.md [\#55](https://github.com/voxpupuli/puppet-mumble/pull/55) ([bastelfreak](https://github.com/bastelfreak))
- metadata: bump ubuntu and debian support to latest version \(refs: \#36\) [\#54](https://github.com/voxpupuli/puppet-mumble/pull/54) ([sbadia](https://github.com/sbadia))
- Allow puppetlabs/apt 7.x [\#50](https://github.com/voxpupuli/puppet-mumble/pull/50) ([dhoppe](https://github.com/dhoppe))

## [v2.1.2](https://github.com/voxpupuli/puppet-mumble/tree/v2.1.2) (2018-10-19)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v2.1.1...v2.1.2)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#45](https://github.com/voxpupuli/puppet-mumble/pull/45) ([bastelfreak](https://github.com/bastelfreak))

## [v2.1.1](https://github.com/voxpupuli/puppet-mumble/tree/v2.1.1) (2018-09-06)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v2.1.0...v2.1.1)

**Fixed bugs:**

- Starts service on every provision [\#1](https://github.com/voxpupuli/puppet-mumble/issues/1)

**Merged pull requests:**

- allow puppetlabs/apt 6.x [\#43](https://github.com/voxpupuli/puppet-mumble/pull/43) ([bastelfreak](https://github.com/bastelfreak))
- Remove docker nodesets [\#37](https://github.com/voxpupuli/puppet-mumble/pull/37) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#35](https://github.com/voxpupuli/puppet-mumble/pull/35) ([bastelfreak](https://github.com/bastelfreak))
- regenerate puppet-strings docs [\#32](https://github.com/voxpupuli/puppet-mumble/pull/32) ([bastelfreak](https://github.com/bastelfreak))

## [v2.1.0](https://github.com/voxpupuli/puppet-mumble/tree/v2.1.0) (2017-11-13)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v2.0.0...v2.1.0)

**Merged pull requests:**

- release 2.1.0 [\#30](https://github.com/voxpupuli/puppet-mumble/pull/30) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.21.3, bump to minimal recommended puppet version [\#26](https://github.com/voxpupuli/puppet-mumble/pull/26) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.0](https://github.com/voxpupuli/puppet-mumble/tree/v2.0.0) (2017-05-14)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v1.1.0...v2.0.0)

**Merged pull requests:**

- Fix license in metadata.json [\#24](https://github.com/voxpupuli/puppet-mumble/pull/24) ([alexjfisher](https://github.com/alexjfisher))

## [v1.1.0](https://github.com/voxpupuli/puppet-mumble/tree/v1.1.0) (2017-02-11)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/v1.0.0...v1.1.0)

**Merged pull requests:**

- modulesync 0.16.7 [\#17](https://github.com/voxpupuli/puppet-mumble/pull/17) ([bastelfreak](https://github.com/bastelfreak))
- Set min version\_requirement for Puppet + apt [\#16](https://github.com/voxpupuli/puppet-mumble/pull/16) ([juniorsysadmin](https://github.com/juniorsysadmin))
- modulesync 0.16.6 [\#15](https://github.com/voxpupuli/puppet-mumble/pull/15) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.16.4 [\#14](https://github.com/voxpupuli/puppet-mumble/pull/14) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.16.3 [\#13](https://github.com/voxpupuli/puppet-mumble/pull/13) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.15.0 [\#12](https://github.com/voxpupuli/puppet-mumble/pull/12) ([bastelfreak](https://github.com/bastelfreak))
- Add missing badges [\#11](https://github.com/voxpupuli/puppet-mumble/pull/11) ([dhoppe](https://github.com/dhoppe))
- Update based on voxpupuli/modulesync\_config 0.14.1 [\#10](https://github.com/voxpupuli/puppet-mumble/pull/10) ([dhoppe](https://github.com/dhoppe))
- modulesync 0.13.0 [\#9](https://github.com/voxpupuli/puppet-mumble/pull/9) ([bbriggs](https://github.com/bbriggs))
- modulesync 0.12.9 [\#8](https://github.com/voxpupuli/puppet-mumble/pull/8) ([bbriggs](https://github.com/bbriggs))
- modulesync 0.12.5 [\#7](https://github.com/voxpupuli/puppet-mumble/pull/7) ([bastelfreak](https://github.com/bastelfreak))

## [v1.0.0](https://github.com/voxpupuli/puppet-mumble/tree/v1.0.0) (2016-08-18)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/0.0.3...v1.0.0)

**Merged pull requests:**

- modulesync 0.12.1 & Release 1.0.0 [\#6](https://github.com/voxpupuli/puppet-mumble/pull/6) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 0.11.1 [\#5](https://github.com/voxpupuli/puppet-mumble/pull/5) ([bastelfreak](https://github.com/bastelfreak))
- Added support to install a specific version of mumble [\#4](https://github.com/voxpupuli/puppet-mumble/pull/4) ([x3dfxjunkie](https://github.com/x3dfxjunkie))
- added register\_name variable [\#2](https://github.com/voxpupuli/puppet-mumble/pull/2) ([sjpilot](https://github.com/sjpilot))

## [0.0.3](https://github.com/voxpupuli/puppet-mumble/tree/0.0.3) (2014-05-09)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/voxpupuli/puppet-mumble/tree/0.0.2) (2014-01-19)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/voxpupuli/puppet-mumble/tree/0.0.1) (2014-01-16)

[Full Changelog](https://github.com/voxpupuli/puppet-mumble/compare/112cade991b4878f26eae62bcf534f12faa20df6...0.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
