# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v10.0.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/v10.0.0) (2025-06-17)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/v9.0.0...v10.0.0)

**Breaking changes:**

- Remove EOL OSes [\#87](https://github.com/voxpupuli/puppet-elastic_stack/pull/87) ([h-haaks](https://github.com/h-haaks))
- Move to apt keyrings because apt-key is deprecated since Debian11 [\#84](https://github.com/voxpupuli/puppet-elastic_stack/pull/84) ([philipp-h298](https://github.com/philipp-h298))

**Implemented enhancements:**

- Make gpg key configurable [\#27](https://github.com/voxpupuli/puppet-elastic_stack/issues/27)
- Add RedHat/Rocky/AlmaLinux/CentOS 9 support [\#90](https://github.com/voxpupuli/puppet-elastic_stack/pull/90) ([h-haaks](https://github.com/h-haaks))
- Add Debian 12 support [\#89](https://github.com/voxpupuli/puppet-elastic_stack/pull/89) ([h-haaks](https://github.com/h-haaks))
- Add Ubuntu 22.04 and 24.04 support [\#88](https://github.com/voxpupuli/puppet-elastic_stack/pull/88) ([h-haaks](https://github.com/h-haaks))
- Allow puppetlabs/apt 10.x [\#85](https://github.com/voxpupuli/puppet-elastic_stack/pull/85) ([smortex](https://github.com/smortex))
- metadata.json: Add OpenVox [\#83](https://github.com/voxpupuli/puppet-elastic_stack/pull/83) ([jstraw](https://github.com/jstraw))

## [v9.0.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/v9.0.0) (2023-08-04)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/v8.0.2...v9.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#63](https://github.com/voxpupuli/puppet-elastic_stack/pull/63) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add AlmaLinux/Rocky/CentOS support [\#67](https://github.com/voxpupuli/puppet-elastic_stack/pull/67) ([bastelfreak](https://github.com/bastelfreak))
- Add Puppet 8 support [\#66](https://github.com/voxpupuli/puppet-elastic_stack/pull/66) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#65](https://github.com/voxpupuli/puppet-elastic_stack/pull/65) ([bastelfreak](https://github.com/bastelfreak))

## [v8.0.2](https://github.com/voxpupuli/puppet-elastic_stack/tree/v8.0.2) (2022-08-28)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/v8.0.1...v8.0.2)

**Merged pull requests:**

- puppetlabs/apt: Allow 9.x [\#55](https://github.com/voxpupuli/puppet-elastic_stack/pull/55) ([bastelfreak](https://github.com/bastelfreak))

## [v8.0.1](https://github.com/voxpupuli/puppet-elastic_stack/tree/v8.0.1) (2022-08-11)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/v8.0.0...v8.0.1)

**Merged pull requests:**

- puppet/yum: Allow 6.x [\#53](https://github.com/voxpupuli/puppet-elastic_stack/pull/53) ([bastelfreak](https://github.com/bastelfreak))

## [v8.0.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/v8.0.0) (2021-12-22)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/7.0.0...v8.0.0)

**Breaking changes:**

- Unlist Operating Systems which have reached EOL [\#41](https://github.com/voxpupuli/puppet-elastic_stack/pull/41) ([smortex](https://github.com/smortex))
- Drop support for Puppet 4 and 5 \(EOL\) [\#40](https://github.com/voxpupuli/puppet-elastic_stack/pull/40) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add support for Puppet 7 [\#42](https://github.com/voxpupuli/puppet-elastic_stack/pull/42) ([smortex](https://github.com/smortex))

**Closed issues:**

- Module doesn't install and bugs puppet. [\#34](https://github.com/voxpupuli/puppet-elastic_stack/issues/34)

**Merged pull requests:**

- update metadata.json for Vox Pupuli namespace [\#50](https://github.com/voxpupuli/puppet-elastic_stack/pull/50) ([bastelfreak](https://github.com/bastelfreak))
- puppet/yum: Allow 5.x [\#49](https://github.com/voxpupuli/puppet-elastic_stack/pull/49) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/apt: allow 8.x [\#48](https://github.com/voxpupuli/puppet-elastic_stack/pull/48) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 8.x [\#47](https://github.com/voxpupuli/puppet-elastic_stack/pull/47) ([bastelfreak](https://github.com/bastelfreak))
- Drop yumrepo\_core from metadata.json [\#46](https://github.com/voxpupuli/puppet-elastic_stack/pull/46) ([bastelfreak](https://github.com/bastelfreak))
- Add recent distros [\#45](https://github.com/voxpupuli/puppet-elastic_stack/pull/45) ([smortex](https://github.com/smortex))
- Download modules from git repo for unit testing [\#44](https://github.com/voxpupuli/puppet-elastic_stack/pull/44) ([smortex](https://github.com/smortex))
- Remove Vagrant leftovers [\#43](https://github.com/voxpupuli/puppet-elastic_stack/pull/43) ([smortex](https://github.com/smortex))
- Stop using Travis CI [\#37](https://github.com/voxpupuli/puppet-elastic_stack/pull/37) ([jmlrt](https://github.com/jmlrt))
- Add badges [\#32](https://github.com/voxpupuli/puppet-elastic_stack/pull/32) ([fatmcgav](https://github.com/fatmcgav))

## [7.0.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/7.0.0) (2019-08-13)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.3.2...7.0.0)

**Merged pull requests:**

- Default to Elastic Stack version 7 [\#26](https://github.com/voxpupuli/puppet-elastic_stack/pull/26) ([ghost](https://github.com/ghost))

## [6.3.2](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.3.2) (2019-08-13)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.3.1...6.3.2)

**Closed issues:**

- r10k continuously updating elastic\_stack [\#19](https://github.com/voxpupuli/puppet-elastic_stack/issues/19)

**Merged pull requests:**

- Release 6.3.2 [\#31](https://github.com/voxpupuli/puppet-elastic_stack/pull/31) ([ghost](https://github.com/ghost))
- Do not pass facterversion to on\_supported\_os [\#30](https://github.com/voxpupuli/puppet-elastic_stack/pull/30) ([ghost](https://github.com/ghost))
- Update metadata versions [\#28](https://github.com/voxpupuli/puppet-elastic_stack/pull/28) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [6.3.1](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.3.1) (2019-04-17)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.2.4...6.3.1)

**Closed issues:**

- Current release tarball 6.2.4 erroneously contains local `.git` directory [\#24](https://github.com/voxpupuli/puppet-elastic_stack/issues/24)

**Merged pull requests:**

- Support Puppet 6 [\#25](https://github.com/voxpupuli/puppet-elastic_stack/pull/25) ([ghost](https://github.com/ghost))

## [6.2.4](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.2.4) (2018-09-16)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.2.3...6.2.4)

**Merged pull requests:**

- Allow puppetlabs-apt 6.x and newer [\#17](https://github.com/voxpupuli/puppet-elastic_stack/pull/17) ([jhooyberghs](https://github.com/jhooyberghs))

## [6.2.3](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.2.3) (2018-08-28)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.2.2...6.2.3)

## [6.2.2](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.2.2) (2018-08-27)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.2.1...6.2.2)

**Closed issues:**

- Support stdlib 5 [\#15](https://github.com/voxpupuli/puppet-elastic_stack/issues/15)

**Merged pull requests:**

- Allow the use of stdlib version 5 [\#16](https://github.com/voxpupuli/puppet-elastic_stack/pull/16) ([ghost](https://github.com/ghost))

## [6.2.1](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.2.1) (2018-08-14)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.2.0...6.2.1)

**Closed issues:**

- Allow $version to set an specific release  [\#13](https://github.com/voxpupuli/puppet-elastic_stack/issues/13)
- kibana packages not found in oss repository [\#10](https://github.com/voxpupuli/puppet-elastic_stack/issues/10)

**Merged pull requests:**

- Update puppetlabs/apt dependency [\#14](https://github.com/voxpupuli/puppet-elastic_stack/pull/14) ([l-lotz](https://github.com/l-lotz))

## [6.2.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.2.0) (2018-07-17)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.1.0...6.2.0)

**Closed issues:**

- release consistency [\#11](https://github.com/voxpupuli/puppet-elastic_stack/issues/11)
- repo\_url parameter [\#8](https://github.com/voxpupuli/puppet-elastic_stack/issues/8)

**Merged pull requests:**

- Add base\_repo\_url parameter [\#12](https://github.com/voxpupuli/puppet-elastic_stack/pull/12) ([baurmatt](https://github.com/baurmatt))

## [6.1.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.1.0) (2018-05-31)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.0.1...6.1.0)

**Closed issues:**

- Priority parameter should be undef by default [\#5](https://github.com/voxpupuli/puppet-elastic_stack/issues/5)
- apt::update ordering creates dependency cycles [\#4](https://github.com/voxpupuli/puppet-elastic_stack/issues/4)
- update Project URL on Puppet Forge and changelog [\#1](https://github.com/voxpupuli/puppet-elastic_stack/issues/1)

**Merged pull requests:**

- Support 6.3 OSS repositories [\#9](https://github.com/voxpupuli/puppet-elastic_stack/pull/9) ([tylerjl](https://github.com/tylerjl))
- Support for 2.x-style Repository URLs [\#7](https://github.com/voxpupuli/puppet-elastic_stack/pull/7) ([tylerjl](https://github.com/tylerjl))
- Change default of priority from 10 to undef [\#6](https://github.com/voxpupuli/puppet-elastic_stack/pull/6) ([baurmatt](https://github.com/baurmatt))

## [6.0.1](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.0.1) (2017-12-07)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/6.0.0...6.0.1)

**Closed issues:**

- Do not use cross module variables [\#2](https://github.com/voxpupuli/puppet-elastic_stack/issues/2)

## [6.0.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/6.0.0) (2017-11-14)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/0.2.1...6.0.0)

## [0.2.1](https://github.com/voxpupuli/puppet-elastic_stack/tree/0.2.1) (2017-11-13)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/voxpupuli/puppet-elastic_stack/tree/0.2.0) (2017-11-10)

[Full Changelog](https://github.com/voxpupuli/puppet-elastic_stack/compare/5cfd57919eb0116c82d76a782697e02d7d93604d...0.2.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
