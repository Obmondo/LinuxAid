# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v8.0.0](https://github.com/voxpupuli/puppet-kibana/tree/v8.0.0) (2023-08-04)

[Full Changelog](https://github.com/voxpupuli/puppet-kibana/compare/v7.0.1...v8.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#74](https://github.com/voxpupuli/puppet-kibana/pull/74) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Puppet 8 support [\#76](https://github.com/voxpupuli/puppet-kibana/pull/76) ([bastelfreak](https://github.com/bastelfreak))
- Remove template erb and puppet\_x folder [\#72](https://github.com/voxpupuli/puppet-kibana/pull/72) ([phaedriel](https://github.com/phaedriel))
- Add optional parameter plugindir \(Directory containing kibana plugins\) [\#71](https://github.com/voxpupuli/puppet-kibana/pull/71) ([phaedriel](https://github.com/phaedriel))
- Add sensitive for kibana config [\#68](https://github.com/voxpupuli/puppet-kibana/pull/68) ([phaedriel](https://github.com/phaedriel))
- Add service\_name and package\_name parameters [\#66](https://github.com/voxpupuli/puppet-kibana/pull/66) ([phaedriel](https://github.com/phaedriel))
- Allow to change `kibana.yml` ownership [\#64](https://github.com/voxpupuli/puppet-kibana/pull/64) ([phaedriel](https://github.com/phaedriel))

**Closed issues:**

- Support alternative package & service name for Kibana [\#16](https://github.com/voxpupuli/puppet-kibana/issues/16)

## [v7.0.1](https://github.com/voxpupuli/puppet-kibana/tree/v7.0.1) (2022-06-13)

[Full Changelog](https://github.com/voxpupuli/puppet-kibana/compare/v7.0.0...v7.0.1)

**Fixed bugs:**

- Allow empty string values in kibana::config [\#44](https://github.com/voxpupuli/puppet-kibana/pull/44) ([smokris](https://github.com/smokris))
- Crossport hash.rb from elastic/puppet-elasticsearch [\#41](https://github.com/voxpupuli/puppet-kibana/pull/41) ([baurmatt](https://github.com/baurmatt))

**Closed issues:**

- Module dependency for elastic-elastick\_stack [\#57](https://github.com/voxpupuli/puppet-kibana/issues/57)

**Merged pull requests:**

- Remove .ruby-version and .tool-versions [\#60](https://github.com/voxpupuli/puppet-kibana/pull/60) ([root-expert](https://github.com/root-expert))
- Update module name [\#59](https://github.com/voxpupuli/puppet-kibana/pull/59) ([luoymu](https://github.com/luoymu))
- elastic/elastic\_stack deprecation [\#58](https://github.com/voxpupuli/puppet-kibana/pull/58) ([anesterova](https://github.com/anesterova))

## [v7.0.0](https://github.com/voxpupuli/puppet-kibana/tree/v7.0.0) (2022-03-25)

[Full Changelog](https://github.com/voxpupuli/puppet-kibana/compare/6.3.1...v7.0.0)

**Breaking changes:**

- Drop versions of Puppet which have reached EOL; require puppet 6 or 7 [\#51](https://github.com/voxpupuli/puppet-kibana/pull/51) ([smortex](https://github.com/smortex))
- Drop support for OS which have reached EOL [\#49](https://github.com/voxpupuli/puppet-kibana/pull/49) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Support for multiple Kibana instances [\#10](https://github.com/voxpupuli/puppet-kibana/issues/10)
- Add support for recent operating systems [\#53](https://github.com/voxpupuli/puppet-kibana/pull/53) ([smortex](https://github.com/smortex))
- Add support Puppet 6 and 7 [\#50](https://github.com/voxpupuli/puppet-kibana/pull/50) ([smortex](https://github.com/smortex))

**Closed issues:**

- Plugin install should either update existing plugin or break with error [\#33](https://github.com/voxpupuli/puppet-kibana/issues/33)

**Merged pull requests:**

- Stop using Travis CI [\#48](https://github.com/voxpupuli/puppet-kibana/pull/48) ([jmlrt](https://github.com/jmlrt))
- Update hiera yaml to version 5 [\#36](https://github.com/voxpupuli/puppet-kibana/pull/36) ([mmoll](https://github.com/mmoll))

## [6.3.1](https://github.com/voxpupuli/puppet-kibana/tree/6.3.1) (2018-10-19)

#### Fixes
* This module no longer requires or enforces a version of the puppetlabs/apt module, which is transitively handled through the `elastic/elastic_stack` dependency.
* Permit hashes to be passed as configuration parameter values.

## 6.3.0 (June 18, 2018)

This release deprecates Kibana 4.x, which is end-of-life.

### Migration Guide

* Support for 4.x has been deprecated, so consider upgrading to Kibana 5 or later before upgrading this module since only versions 5 and later are supported.
* The module defaults to the upstream package repositories, which now include X-Pack bundled by default. To preserve previous behavior which does _not_ include X-Pack, follow the `README` instructions to configure `oss`-only repositories/packages.
* Use of the `elastic_stack::repo` class for managing package repositories may mean that leftover yum/apt/etc. repositories named `kibana` may persist after upgrade.

#### Features
* Support for 6.3 style repositories using elastic_stack module

#### Fixes

## 6.0.1 (March 13, 2018)

#### Fixes
* Fixed language compatibility errors that could arise when using JRuby 1.7 on Puppet Servers.

## 6.0.0 (November 14, 2017)

Major version upgrade with important deprecations:

* Puppet version 3 is no longer supported.

The following migration guide is intended to help aid in upgrading this module.

### Migration Guide

#### Puppet 3.x No Longer Supported

Puppet 4.5.0 is the new minimum required version of Puppet, which offers better safety, module metadata, and Ruby features.
Migrating from Puppet 3 to Puppet 4 is beyond the scope of this guide, but the [official upgrade documentation](https://docs.puppet.com/upgrade/upgrade_steps.html) can help.
As with any version or module upgrade, remember to restart any agents and master servers as needed.

## 5.2.0 (November 13, 2017)

#### Features
* Added support for service status

## 5.1.0 (August 18, 2017)

#### Features
* Installation via package files (`.deb`/`.rpm`) now supported. See documentation for the `package_source` parameter for usage.
* Updated puppetlabs/apt dependency to reflect support for 4.x versions.

## 5.0.1 (July 19, 2017)

This is a bugfix release to properly contain classes within the `kibana` class so that relationship ordering is respected correctly.

## 5.0.0 (May 10, 2017)

### Summary
Formally release major version 5.0 of the module.

#### Fixes
* metadata.json dependencies now compatible with Puppet 3.x.

## 0.3.0 (April 26, 2017)

### Summary
This release backports support for Puppet 3.8.

## 0.2.1 (April 10, 2017)

### Summary
Bugfix release resolving several minor issues.

#### Features
* Package revisions now supported for ensure values.

#### Fixes
* The `url` parameter for 4.x plugins is now properly passed to the plugin install command.
* Nonzero plugin commmands now properly raise errors during catalog runs.
* Boolean values allowed in config hash.
* apt-transport-https package no longer managed by this module.

## 0.2.0 (March 20, 2017)

### Summary
Minor fixes and full 4.x support.

#### Features
* Feature parity when managing plugins on Kibana 4.x.

#### Fixes
* Removed potential conflict with previously-defined apt-transport-https packages.
* Permit boolean values in configuration hashes.

## 0.1.1 (March 11, 2017)

### Summary
Small bugfix release.

#### Fixes
* Actually aknowledge and use the manage_repo class flag.

## 0.1.0 (March 8, 2017)

### Summary
Initial release.

#### Features
* Support for installing, removing, and updating Kibana and the Kibana service.
* Plugin support.
* Initial support for version 4.x management.

#### Fixes


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
