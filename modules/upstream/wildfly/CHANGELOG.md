# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.0.0](https://github.com/voxpupuli/puppet-wildfly/tree/v4.0.0) (2024-10-29)

[Full Changelog](https://github.com/voxpupuli/puppet-wildfly/compare/v3.2.1...v4.0.0)

The v3.2.1 release was done by accident. It contained breaking changes. v4.0.0 is a relrelease . We deleted the v3.2.1 release from the forge.

**Breaking changes:**

- Drop EoL CentOS 8 support [\#335](https://github.com/voxpupuli/puppet-wildfly/pull/335) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow setting java\_opts only [\#343](https://github.com/voxpupuli/puppet-wildfly/pull/343) ([tuxmea](https://github.com/tuxmea))

**Fixed bugs:**

- Missing template when using jboss-eap as distribution [\#337](https://github.com/voxpupuli/puppet-wildfly/issues/337)

**Merged pull requests:**

- Remove artefact from sysvinit [\#341](https://github.com/voxpupuli/puppet-wildfly/pull/341) ([tuxmea](https://github.com/tuxmea))

## [v3.2.1](https://github.com/voxpupuli/puppet-wildfly/tree/v3.2.1) (2024-10-28)

[Full Changelog](https://github.com/voxpupuli/puppet-wildfly/compare/v3.2.0...v3.2.1)

**Breaking changes:**

- Drop support for non-systemd [\#330](https://github.com/voxpupuli/puppet-wildfly/pull/330) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Ubuntu 18.04 support [\#329](https://github.com/voxpupuli/puppet-wildfly/pull/329) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL Debian 10 support [\#328](https://github.com/voxpupuli/puppet-wildfly/pull/328) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL EL7/Scientific Linux support [\#327](https://github.com/voxpupuli/puppet-wildfly/pull/327) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Fix systemd templates [\#334](https://github.com/voxpupuli/puppet-wildfly/pull/334) ([tuxmea](https://github.com/tuxmea))

## [v3.2.0](https://github.com/voxpupuli/puppet-wildfly/tree/v3.2.0) (2024-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-wildfly/compare/v3.1.0...v3.2.0)

**Implemented enhancements:**

- feat: allow jboss to run with systemd [\#331](https://github.com/voxpupuli/puppet-wildfly/pull/331) ([tuxmea](https://github.com/tuxmea))
- puppetlabs/stdlib: Allow 9.x [\#321](https://github.com/voxpupuli/puppet-wildfly/pull/321) ([zilchms](https://github.com/zilchms))

**Fixed bugs:**

- `wildfly::host::server_config` with `ensure => absent` in already absent server tries to stop it and fails with timeout [\#292](https://github.com/voxpupuli/puppet-wildfly/issues/292)
- Use correct download URLs for Wildfly version \>= 25 [\#316](https://github.com/voxpupuli/puppet-wildfly/pull/316) ([EmersonPrado](https://github.com/EmersonPrado))
- Don't try to stop absent servers in `wildfly::host::server_config` [\#313](https://github.com/voxpupuli/puppet-wildfly/pull/313) ([EmersonPrado](https://github.com/EmersonPrado))
- Create missing `$wildfly::install_cache_dir` directory [\#310](https://github.com/voxpupuli/puppet-wildfly/pull/310) ([EmersonPrado](https://github.com/EmersonPrado))

**Merged pull requests:**

- README.md: fix badges [\#317](https://github.com/voxpupuli/puppet-wildfly/pull/317) ([zilchms](https://github.com/zilchms))
- Remove legacy top-scope syntax [\#312](https://github.com/voxpupuli/puppet-wildfly/pull/312) ([smortex](https://github.com/smortex))

## [v3.1.0](https://github.com/voxpupuli/puppet-wildfly/tree/v3.1.0) (2023-11-03)

[Full Changelog](https://github.com/voxpupuli/puppet-wildfly/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- Update metadata.json: fix author name, fix project name and raise stdlib boundaries [\#306](https://github.com/voxpupuli/puppet-wildfly/pull/306) ([rwaffen](https://github.com/rwaffen))

## [v3.0.0](https://github.com/voxpupuli/puppet-wildfly/tree/v3.0.0) (2023-10-27)

[Full Changelog](https://github.com/voxpupuli/puppet-wildfly/compare/v2.3.2...v3.0.0)

**Breaking changes:**

- Drop EoL Operating system support & Drop Puppet 4/5/6 support [\#296](https://github.com/voxpupuli/puppet-wildfly/pull/296) ([rwaffen](https://github.com/rwaffen))

**Implemented enhancements:**

- Puppet unable to manage wildfly behind a secured connection [\#207](https://github.com/voxpupuli/puppet-wildfly/issues/207)
- Initial install fails because /var/cache/wget does not exist. [\#191](https://github.com/voxpupuli/puppet-wildfly/issues/191)
- \(\#288\) Add parameter to set JAVA\_OPTS option MaxMetaspaceSize [\#291](https://github.com/voxpupuli/puppet-wildfly/pull/291) ([EmersonPrado](https://github.com/EmersonPrado))
- \(\#287\) Add parameters for \(PROCESS|HOST\)\_CONTROLLER\_JAVA\_OPTS in domain.conf [\#290](https://github.com/voxpupuli/puppet-wildfly/pull/290) ([EmersonPrado](https://github.com/EmersonPrado))
- Allow domain management using wildfly::domain::server\_group and wildfly::host::server\_config [\#270](https://github.com/voxpupuli/puppet-wildfly/pull/270) ([thiagomarinho](https://github.com/thiagomarinho))
- add StandardOutput to systemd [\#268](https://github.com/voxpupuli/puppet-wildfly/pull/268) ([bc-bjoern](https://github.com/bc-bjoern))
- Add new `refreshonly` parameter to wildfly\_cli and wrapper [\#267](https://github.com/voxpupuli/puppet-wildfly/pull/267) ([alexjfisher](https://github.com/alexjfisher))
- Setup and use HTTPS/TLS on the Management API [\#223](https://github.com/voxpupuli/puppet-wildfly/pull/223) ([frozen3](https://github.com/frozen3))

**Fixed bugs:**

- Fix wildfly\_cli.rb property `executed` [\#269](https://github.com/voxpupuli/puppet-wildfly/pull/269) ([thiagomarinho](https://github.com/thiagomarinho))

**Merged pull requests:**

- Update Readme code examples and rubocop\_todos [\#301](https://github.com/voxpupuli/puppet-wildfly/pull/301) ([rwaffen](https://github.com/rwaffen))
- disable beaker acceptance testing [\#299](https://github.com/voxpupuli/puppet-wildfly/pull/299) ([rwaffen](https://github.com/rwaffen))
- fix spec tests [\#297](https://github.com/voxpupuli/puppet-wildfly/pull/297) ([rwaffen](https://github.com/rwaffen))
- Fix linter [\#295](https://github.com/voxpupuli/puppet-wildfly/pull/295) ([rwaffen](https://github.com/rwaffen))
- Use rvm and Ruby 2.7 in README test setup section [\#285](https://github.com/voxpupuli/puppet-wildfly/pull/285) ([EmersonPrado](https://github.com/EmersonPrado))
- Update bundle install commands in README test setup section [\#282](https://github.com/voxpupuli/puppet-wildfly/pull/282) ([EmersonPrado](https://github.com/EmersonPrado))
- Code content quality [\#281](https://github.com/voxpupuli/puppet-wildfly/pull/281) ([Joris29](https://github.com/Joris29))
- Remove obsolete java parameter [\#280](https://github.com/voxpupuli/puppet-wildfly/pull/280) ([Joris29](https://github.com/Joris29))

## [v2.3.2](https://github.com/voxpupuli/puppet-wildfly/tree/v2.3.2) (2018-08-18)

- Fixes to CLI parser
- Improve init paramters

## v2.3.1

- Fix install_source validation


## v2.3.0

- Override wildfly user home
- Support for overlays installation
- Fixes for EL7 systemd unit file
- Parameterized username, password, host and port on resource wrappers


## v2.2.0

- Fix title patterns.
- Fix unauthorized race condition.
- Fix systemd service permissions
- JMS Connection Factory

## v2.1.0

- Fix class containment in init.pp
- Fix undefined comparison for wildfly::cli
- Remove string comparison support.
- Remove sorting of array elements.
- Remove data obfuscation for sensitive values.
- Refactor wildfly_resource to use Puppet::Property subclass.

## v2.0.3

- Introduce data types.
- Remove unnecessary v1 code.
- Introduce external facts.
- Fix patch::online

## v2.0.2

- Fix wildfly_resource's with array of hashes values.
- Allow custom templates or file for module.xml.
- Support for jgroups stacks
- Rewrite functions in Puppet language.

## v2.0.1

- Bring cache_dir back.
- Introduce deployment cache dir.
- Remove WILDFLY_HOME management with package installation in order to proper support packages.

## v2.0.0

- Introduce Puppet 4 features (epp, data types and etc)
- Introduce puppet-strings
- Small fixes fori JBoss-CLI Parser.

## v1.2.8

- Fix summary
- Improve CLI parser error message

## v1.2.7

- Keep compatibility with Ruby 1.8.7 (necessary while claiming compatibility with 2.7/3.8)

## v1.2.6

- Major wildfly_resource refactor
- Recursively stringify array values to avoid non-idempotent behavior
- Allow resources with special characters in its name using quotes

## v1.2.5

- Fix for deployment in domain mode
- Fix custom types docs.

## v1.2.4

- Fix for wildfly 10 with systemd

## v1.2.3

- Use composite namevar for wildfly_resource to allow management of multiple instance from a single node.
- EAP7 topics and queues.
- Infinispan/JDG template.

## v1.2.2

- Update supported OS's list and add propert suport for upstart through sysvinit
- Introduce remote_user parameter

## v1.2.1

- Use a unique name for service resource with different name attribute value.

## v1.2.0

- Installation from system packages
- Bundle gems with the module

## v1.1.0

- Introduce patch management feature
- Move providers dependencies to a single place

## v1.0.1

- Fix for Wildfly 10 with systemd.

## v1.0.0

- Improve domain support
- Out of the box support for a wide range of versions (EAP 6.1+/EAP7, Wildfly 8/9/10)
- Better tests/code coverage, both unit and acceptance (version X OS matrix).
- Use properties file instead of Augeas to manage port/address binding.
- Introduce a proper CLI parser.
- Lots of minor issues fixes.
- Support for operation-headers in wildfly_resource and wildfly_deployment.
- Move things from wildfly::util to wildfly.
- Major refactoring of custom types/providers and puppet_x namespace.

## v0.5.7

- Replace each_with_object (193) with inject (187)

## v0.5.6

- Fix wildfly_resource when non managed properties are a hash

## v0.5.5

- Fix non idempotent behavior in wildfly_resource when resource contains a nested hash.
- Obfuscate sensitive data in wildfly_resource change_to_s.

## v0.5.4

- Fix for digest authentication in Wildfly 10.
- Fix wildfly_cli should_execute? condition
- Excluded-contexts for modcluster configuration.
- HTTPS support for AS7/EAP6.

## v0.5.3

- Fix for true/false comparison in custom types.
- Improved wildfly::modcluster::config.
- Fix version comparison.
- SSL for Wildfly 9+
- Still support Ruby 1.8.7.

## v0.5.2

- Support file and puppet protocol for module/deployment installation
- Download timeout parameter
- Login module management
- Optional package dependencies management
- wildfly_reload custom type/provider
- Fix wildfly service in EL7
- Fix wildfly_resource when HTTP API return numbers
- Support digest authentication
- Ignore HTTP Proxy in net/http
- Improve acceptance tests

## v0.5.1

- Support datasource database properties
- Support logging::category, only for full profiles
- Support system property, only for full profiles
- Be able to provide your own service wildfly initd script
- Wildfy Service enable & ensure parameters
- Fix module installation

## v0.5.0

- Removed nanliu-archive dependency
- Removed nexus deployment support
- Rename deploy to deployment
- Simplify user management

## v0.4.3

- Allow setting the uid/gid for the wildfly user and group
- Uses JBOSS_OPTS to configure socket binding and bind address. (Operation mode independent)
- Improve Domain mode support. (Easy master/slave setup)
- User management defined types name refactor. (Breaking change)
- Non destructive update initial support.

## v0.4.2

- Adds timeout parameter for wildfly_deploy custom type.

## v0.4.1

- Template fixes so it also works for puppet 4.2.1
- Standalone mode also works with an empty java_opts

## v0.4.0

- Unified deploy for domain/standalone modes (wildfly::deploy)
- Removed wildfly::standalone namespace since domain and standalone configurations share the same defitions
- Fix wildfly service to detect profile changes
- Remove params of private classes. init.pp is suposed to be the only public class.

## v0.3.7

- Update README.md content and format to follow recommended guidelines
- Add acceptance test for Wildfly 9

## v0.3.6

- Service needs to restart if we change anything in the standalone.conf
- Several fixes for domain mode
- Support escaped slashes in resource names
- Support ensure parameter in resource util
- Support installing non-system modules
- Update definitions optional parameters.
- CLI, Support for 'has' operator to check if item is in array

## v0.3.5

- Changes to allow wildfly module to deploy jboss EAP
- java_opts parameters which will override the default
- puppet 4 templates path fix
- XA datasource support

## v0.3.4

- deploy from nexus
- manage_user parameter for controling the default creation of the wildfly user/group

## v0.3.3

- Beaker unit tests for CentOS 6.6, 7.0 and Debian 7
- fix debian wildlfy configuration file /etc/default/wildfly

## v0.3.2

- More improvements

## v0.3.1

- Code quality improvement and support for onlyif in wildfly_cli

## v0.3.0

- Introducing custom types/providers in replacement of cli-wrapper and jboss-cli.sh. These custom types/providers use HTTP API instead of JBoss-CLI. It maks it 5-10x faster and easier to maintain. More info here: cpitman/puppet-jboss_admin#68
- Using archive in replacement of wget cause it's faster and incredible simple.
- Removing nexus deployment support since cescoffier/puppet-nexus is not in forge and not being active developed, I'll try to work on a PR for archive (some sort of archive::nexus) and have a single define for deployment that accepts multiple formats of deployment.
- Users still can download from Nexus outside deploy and pass file URL as a parameter.

## v0.2.4

- Debian fix so wildfly-init-debian.sh will be used instead of redhat

## v0.2.3

- update readme

## v0.2.2

- Configure wildfly log with console_log parameter
- Deployment option
- User management
- Module installation
- Datasource configuration
- HTTPS/SSL & Identity store
- Modcluster (Only for HA profiles)
- Messaging Queue or Topics

## v0.2.1

- All port & interface sed actions has been replaced by augeas

## v0.2.0

- Major re-factoring by Jairo Junior
- Extracted some resources to new manifests in order to avoid excessive relationships (require, notify, before, after, etc).
- Created new manifests to express new concepts (wildfly user management).
- Removed shell script templates in order to use package script (wildfly/bin/init.d).
- Using only class { 'wildfly' } instead of class { 'wildfly:install' } cause it gives the impression that i am able to instantiate multiple instances*, like tomcat module (https://forge.puppetlabs.com/puppetlabs/tomcat).
- Removing $install_file parameter cause it can be inferred (file_name_from_url.rb).
- The wildfly management user password is declared in plain text and hash is performed internally (password_hash.rb).
- Introduced new dependencies (wget and stdlib)

## v0.1.9

- some exec executed on every puppet run

## v0.1.8

- Added license
- Support for Wildfly 8.2
- Removed the password on the wildfly user

## v0.1.7

- fix for updating user mgmt file

## v0.1.6

- Fix for Debian, Ubuntu


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
