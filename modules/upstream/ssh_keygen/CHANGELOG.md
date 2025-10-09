# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v6.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v6.0.0) (2023-07-30)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v5.0.2...v6.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#80](https://github.com/voxpupuli/puppet-ssh_keygen/pull/80) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Puppet 8 support [\#86](https://github.com/voxpupuli/puppet-ssh_keygen/pull/86) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#85](https://github.com/voxpupuli/puppet-ssh_keygen/pull/85) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Remove old nodesets [\#76](https://github.com/voxpupuli/puppet-ssh_keygen/pull/76) ([ekohl](https://github.com/ekohl))

## [v5.0.2](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v5.0.2) (2022-02-26)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v5.0.1...v5.0.2)

**Merged pull requests:**

- metadata.json: use HTTPS for git URL & cleanup README.md [\#74](https://github.com/voxpupuli/puppet-ssh_keygen/pull/74) ([bastelfreak](https://github.com/bastelfreak))
- cleanup .sync.yml an add puppet-lint-param-docs [\#69](https://github.com/voxpupuli/puppet-ssh_keygen/pull/69) ([bastelfreak](https://github.com/bastelfreak))

## [v5.0.1](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v5.0.1) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v5.0.0...v5.0.1)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#66](https://github.com/voxpupuli/puppet-ssh_keygen/pull/66) ([smortex](https://github.com/smortex))

## [v5.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v5.0.0) (2021-06-15)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v4.1.0...v5.0.0)

**Breaking changes:**

- Drop EoL Puppet 5 support; Add Puppet 7 support [\#64](https://github.com/voxpupuli/puppet-ssh_keygen/pull/64) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- puppetlabs/stdlib: Allow 7.x [\#62](https://github.com/voxpupuli/puppet-ssh_keygen/pull/62) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Fix several markdown lint issues [\#58](https://github.com/voxpupuli/puppet-ssh_keygen/pull/58) ([dhoppe](https://github.com/dhoppe))
- Use voxpupuli-acceptance [\#57](https://github.com/voxpupuli/puppet-ssh_keygen/pull/57) ([ekohl](https://github.com/ekohl))

## [v4.1.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v4.1.0) (2020-04-03)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v4.0.0...v4.1.0)

**Merged pull requests:**

- Allow puppetlabs/stdlib 6.x [\#54](https://github.com/voxpupuli/puppet-ssh_keygen/pull/54) ([dhoppe](https://github.com/dhoppe))

## [v4.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v4.0.0) (2019-04-28)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v3.0.1...v4.0.0)

**Breaking changes:**

- modulesync 2.6.0 & drop Puppet 4 [\#47](https://github.com/voxpupuli/puppet-ssh_keygen/pull/47) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- ssh\_keygen fails when using ed25519 [\#30](https://github.com/voxpupuli/puppet-ssh_keygen/issues/30)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#44](https://github.com/voxpupuli/puppet-ssh_keygen/pull/44) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.1](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v3.0.1) (2018-09-09)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v3.0.0...v3.0.1)

**Fixed bugs:**

- puppet/stdlib is no more [\#35](https://github.com/voxpupuli/puppet-ssh_keygen/issues/35)
- Fix puppetlabs-stdlib entry in metadata.json [\#36](https://github.com/voxpupuli/puppet-ssh_keygen/pull/36) ([juniorsysadmin](https://github.com/juniorsysadmin))

**Merged pull requests:**

- allow puppetlabs/stdlib 5.x [\#41](https://github.com/voxpupuli/puppet-ssh_keygen/pull/41) ([bastelfreak](https://github.com/bastelfreak))
- Remove docker nodesets [\#38](https://github.com/voxpupuli/puppet-ssh_keygen/pull/38) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v3.0.0) (2018-03-29)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v2.0.1...v3.0.0)

**Breaking changes:**

- BREAKING: Use secure shell escaping for user provided data [\#28](https://github.com/voxpupuli/puppet-ssh_keygen/pull/28) ([vinzent](https://github.com/vinzent))

**Implemented enhancements:**

- Support more key types [\#27](https://github.com/voxpupuli/puppet-ssh_keygen/pull/27) ([jcharaoui](https://github.com/jcharaoui))

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#33](https://github.com/voxpupuli/puppet-ssh_keygen/pull/33) ([bastelfreak](https://github.com/bastelfreak))

## [v2.0.1](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v2.0.1) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v2.0.0...v2.0.1)

**Merged pull requests:**

- Update .sync.yml again with correct name for parameter [\#24](https://github.com/voxpupuli/puppet-ssh_keygen/pull/24) ([wyardley](https://github.com/wyardley))
- switch string to int in example [\#22](https://github.com/voxpupuli/puppet-ssh_keygen/pull/22) ([wyardley](https://github.com/wyardley))

## [v2.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v2.0.0) (2017-09-09)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v1.3.1...v2.0.0)

**Breaking changes:**

- Switch to Puppet 4 data types and make 'bits' an integer.  [\#16](https://github.com/voxpupuli/puppet-ssh_keygen/pull/16) ([wyardley](https://github.com/wyardley))
- Update metadata in preparation for Vox Pupuli cutover \(\#12\) [\#13](https://github.com/voxpupuli/puppet-ssh_keygen/pull/13) ([wyardley](https://github.com/wyardley))

**Fixed bugs:**

- Fix undefined variable problem [\#20](https://github.com/voxpupuli/puppet-ssh_keygen/pull/20) ([wyardley](https://github.com/wyardley))

**Closed issues:**

- Finish migration to VoxPupuli [\#12](https://github.com/voxpupuli/puppet-ssh_keygen/issues/12)
- Is this module still maintained? [\#10](https://github.com/voxpupuli/puppet-ssh_keygen/issues/10)
- Hardcoded default /home/ path? [\#4](https://github.com/voxpupuli/puppet-ssh_keygen/issues/4)

**Merged pull requests:**

- Additional fixes to README [\#18](https://github.com/voxpupuli/puppet-ssh_keygen/pull/18) ([wyardley](https://github.com/wyardley))
- rubocop -a fixes [\#15](https://github.com/voxpupuli/puppet-ssh_keygen/pull/15) ([wyardley](https://github.com/wyardley))
- License readme [\#14](https://github.com/voxpupuli/puppet-ssh_keygen/pull/14) ([wyardley](https://github.com/wyardley))
- Fix broken link [\#11](https://github.com/voxpupuli/puppet-ssh_keygen/pull/11) ([nnutter](https://github.com/nnutter))

## [v1.3.1](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v1.3.1) (2015-09-19)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v1.3.0...v1.3.1)

**Merged pull requests:**

- Prefer command defaults for bits and comment [\#7](https://github.com/voxpupuli/puppet-ssh_keygen/pull/7) ([edestecd](https://github.com/edestecd))

## [v1.3.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v1.3.0) (2015-07-09)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v1.2.0...v1.3.0)

## [v1.2.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v1.2.0) (2014-05-14)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Module not found in foreman [\#1](https://github.com/voxpupuli/puppet-ssh_keygen/issues/1)

**Merged pull requests:**

- Add tests and doc for new options [\#3](https://github.com/voxpupuli/puppet-ssh_keygen/pull/3) ([edestecd](https://github.com/edestecd))
- Add options [\#2](https://github.com/voxpupuli/puppet-ssh_keygen/pull/2) ([edestecd](https://github.com/edestecd))

## [v1.1.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v1.1.0) (2013-11-11)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/v1.0.0...v1.1.0)

## [v1.0.0](https://github.com/voxpupuli/puppet-ssh_keygen/tree/v1.0.0) (2012-12-06)

[Full Changelog](https://github.com/voxpupuli/puppet-ssh_keygen/compare/38313a26e9186207b7e99560388285655ca2ebda...v1.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
