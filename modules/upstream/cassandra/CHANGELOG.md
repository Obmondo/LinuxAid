# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v3.1.0](https://github.com/voxpupuli/puppet-cassandra/tree/v3.1.0) (2020-09-18)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/v3.0.0...v3.1.0)

**Merged pull requests:**

- modulesync 3.0.0 & puppet-lint autofix [\#465](https://github.com/voxpupuli/puppet-cassandra/pull/465) ([bastelfreak](https://github.com/bastelfreak))
- Bump puppet-firewall version to allow version 2.x [\#464](https://github.com/voxpupuli/puppet-cassandra/pull/464) ([waipeng](https://github.com/waipeng))

## [v3.0.0](https://github.com/voxpupuli/puppet-cassandra/tree/v3.0.0) (2020-05-09)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/v2.7.3...v3.0.0)

**Breaking changes:**

- drop EOL Ubuntu 14.04 [\#449](https://github.com/voxpupuli/puppet-cassandra/pull/449) ([bastelfreak](https://github.com/bastelfreak))
- Drop support for Puppet 4 [\#448](https://github.com/voxpupuli/puppet-cassandra/pull/448) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add SCL support to cassandra::schema [\#445](https://github.com/voxpupuli/puppet-cassandra/pull/445) ([russellshackleford](https://github.com/russellshackleford))
- Add Ubuntu 18.04 support [\#443](https://github.com/voxpupuli/puppet-cassandra/pull/443) ([paulseward](https://github.com/paulseward))

**Fixed bugs:**

- Wrong logic in example code [\#459](https://github.com/voxpupuli/puppet-cassandra/issues/459)
- Actually choosing to manage the config file, not directory of it [\#417](https://github.com/voxpupuli/puppet-cassandra/pull/417) ([zmarois](https://github.com/zmarois))

**Closed issues:**

- Metadata: Outdated module dependencies. [\#450](https://github.com/voxpupuli/puppet-cassandra/issues/450)
- ubuntu18 [\#441](https://github.com/voxpupuli/puppet-cassandra/issues/441)

**Merged pull requests:**

- Bugfix: Correct example of calculating MAX\_HEAP\_SIZE.  Fixes \#459. [\#460](https://github.com/voxpupuli/puppet-cassandra/pull/460) ([dallinb](https://github.com/dallinb))
- Various test fixups [\#457](https://github.com/voxpupuli/puppet-cassandra/pull/457) ([alexjfisher](https://github.com/alexjfisher))
- Allow puppetlabs/stdlib 6.x [\#455](https://github.com/voxpupuli/puppet-cassandra/pull/455) ([dhoppe](https://github.com/dhoppe))
- allow puppetlabs/inifile 4.x [\#453](https://github.com/voxpupuli/puppet-cassandra/pull/453) ([bastelfreak](https://github.com/bastelfreak))
- Add default SCL params to Debian family OS [\#452](https://github.com/voxpupuli/puppet-cassandra/pull/452) ([iain-buclaw-sociomantic](https://github.com/iain-buclaw-sociomantic))
- fix puppet-string annotations & Generate REFERENCE.md [\#451](https://github.com/voxpupuli/puppet-cassandra/pull/451) ([bastelfreak](https://github.com/bastelfreak))
- Allow puppetlabs/apt 7.x, puppetlabs/inifile 3.x [\#447](https://github.com/voxpupuli/puppet-cassandra/pull/447) ([dhoppe](https://github.com/dhoppe))

## [v2.7.3](https://github.com/voxpupuli/puppet-cassandra/tree/v2.7.3) (2018-10-19)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/v2.7.2...v2.7.3)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#439](https://github.com/voxpupuli/puppet-cassandra/pull/439) ([bastelfreak](https://github.com/bastelfreak))
-  allow puppetlabs/stdlib 5.x and puppetlabs/apt 6.x [\#438](https://github.com/voxpupuli/puppet-cassandra/pull/438) ([bastelfreak](https://github.com/bastelfreak))

## [v2.7.2](https://github.com/voxpupuli/puppet-cassandra/tree/v2.7.2) (2018-08-18)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/v2.7.1...v2.7.2)

**Merged pull requests:**

- allow puppetlabs/inifile 2.x [\#433](https://github.com/voxpupuli/puppet-cassandra/pull/433) ([bastelfreak](https://github.com/bastelfreak))

## [v2.7.1](https://github.com/voxpupuli/puppet-cassandra/tree/v2.7.1) (2018-08-03)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/v2.7.0...v2.7.1)

**Closed issues:**

- Fix / update modules puppetlabs/apt dependencies  [\#426](https://github.com/voxpupuli/puppet-cassandra/issues/426)

**Merged pull requests:**

- allow puppetlabs-apt version 5.x [\#430](https://github.com/voxpupuli/puppet-cassandra/pull/430) ([bastelfreak](https://github.com/bastelfreak))
- bumping version dependency for puppetlabs/apt [\#429](https://github.com/voxpupuli/puppet-cassandra/pull/429) ([paulseward](https://github.com/paulseward))
- Remove docker nodesets [\#425](https://github.com/voxpupuli/puppet-cassandra/pull/425) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#423](https://github.com/voxpupuli/puppet-cassandra/pull/423) ([bastelfreak](https://github.com/bastelfreak))

## [v2.7.0](https://github.com/voxpupuli/puppet-cassandra/tree/v2.7.0) (2018-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/2.6.0...v2.7.0)

**Implemented enhancements:**

- migrate to voxpupuli [\#394](https://github.com/voxpupuli/puppet-cassandra/issues/394)
- adding paramter to define whether or not to manage the config file at… [\#411](https://github.com/voxpupuli/puppet-cassandra/pull/411) ([zmarois](https://github.com/zmarois))
- \#395 Adding Red Hat OS [\#396](https://github.com/voxpupuli/puppet-cassandra/pull/396) ([stijnvdb](https://github.com/stijnvdb))

**Closed issues:**

- Review metadata.json and README.md [\#410](https://github.com/voxpupuli/puppet-cassandra/issues/410)

**Merged pull requests:**

- replace validate\_hash with assert\_type [\#415](https://github.com/voxpupuli/puppet-cassandra/pull/415) ([bastelfreak](https://github.com/bastelfreak))
- regenerate puppet-strings docs [\#414](https://github.com/voxpupuli/puppet-cassandra/pull/414) ([bastelfreak](https://github.com/bastelfreak))
- Changes towards \#410 \(Review metadata.json and README.md\) [\#412](https://github.com/voxpupuli/puppet-cassandra/pull/412) ([dallinb](https://github.com/dallinb))
- This project no longer uses CircleCI. [\#408](https://github.com/voxpupuli/puppet-cassandra/pull/408) ([dallinb](https://github.com/dallinb))
- Fix merge conflicts for PR \#404 [\#405](https://github.com/voxpupuli/puppet-cassandra/pull/405) ([dallinb](https://github.com/dallinb))
- Release 2.6.0 [\#403](https://github.com/voxpupuli/puppet-cassandra/pull/403) ([dallinb](https://github.com/dallinb))
- Implement apache\_repo for RedHat [\#400](https://github.com/voxpupuli/puppet-cassandra/pull/400) ([dallinb](https://github.com/dallinb))
- Cassandra 3.X and Debian 7 clash over GLIBC version. [\#399](https://github.com/voxpupuli/puppet-cassandra/pull/399) ([dallinb](https://github.com/dallinb))
- Bugfix 397 - Spec tests not working. [\#398](https://github.com/voxpupuli/puppet-cassandra/pull/398) ([dallinb](https://github.com/dallinb))

## [2.6.0](https://github.com/voxpupuli/puppet-cassandra/tree/2.6.0) (2017-09-11)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/2.5.0...2.6.0)

**Implemented enhancements:**

- Implement apache\_repo for RedHat [\#395](https://github.com/voxpupuli/puppet-cassandra/issues/395)

**Fixed bugs:**

- Unit and acceptance tests are failing that have been successful in the past. [\#397](https://github.com/voxpupuli/puppet-cassandra/issues/397)

**Closed issues:**

- Release 2.6.0 [\#401](https://github.com/voxpupuli/puppet-cassandra/issues/401)

## [2.5.0](https://github.com/voxpupuli/puppet-cassandra/tree/2.5.0) (2017-05-31)

[Full Changelog](https://github.com/voxpupuli/puppet-cassandra/compare/2.4.1...2.5.0)

**Implemented enhancements:**

- Integration with github\_changelog\_generator [\#389](https://github.com/voxpupuli/puppet-cassandra/pull/389) ([dallinb](https://github.com/dallinb))

**Closed issues:**

- Tests failing for CentOS 6 on "Create schema for 2.1" [\#392](https://github.com/voxpupuli/puppet-cassandra/issues/392)
- Rubocop failing tests since upgrade from 0.48.1 to 0.49.0 [\#391](https://github.com/voxpupuli/puppet-cassandra/issues/391)

**Merged pull requests:**

- Release 2.5.0 [\#393](https://github.com/voxpupuli/puppet-cassandra/pull/393) ([dallinb](https://github.com/dallinb))
- Switch to role management instead of user one [\#388](https://github.com/voxpupuli/puppet-cassandra/pull/388) ([SergK](https://github.com/SergK))

## [2.4.1](https://github.com/voxpupuli/puppet-cassandra/compare/2.4.0...2.4.1) (2017-04-24)

### Summary

A non-functional release of improvements.

### Improvements

* A refactoring and extension of the acceptance tests.
* Migrated from version 1.0 to 2.0 of the CircleCI API.

## [2.4.0](https://github.com/voxpupuli/puppet-cassandra/compare/2.3.0...2.4.0) (2017-03-30)

### Summary

* Added the `cassandra::dse` class to 2.X.Y of the module.
* Added the new `cassandra::apache_repo` class.
* Minor bug fixes and improvements.

## 2017-02-28 - Release 1.27.0 ([diff](https://github.com/locp/cassandra/compare/1.26.1...1.27.0))

### Summary

Add the `cassandra::dse` class.

## 2017-01-21 - Release 2.3.0 ([diff](https://github.com/locp/cassandra/compare/2.2.1...2.3.0))

New attribute to `::cassandra` class:

* `baseline_settings`

New defined types:

* `cassandra::system::swapoff`
* `cassandra::system::sysctl`
* `cassandra::system::transparent_hugepage`

## 2016-12-08 - Release 2.2.1 ([diff](https://github.com/locp/cassandra/compare/2.2.0...2.2.1))

### Summary

Non-functional improvements and some documentation fixes.

### Improvements

* All beaker spec tests have been migrated from AWS/EC2 to Docker.
* Installed Python 2.7 onto the CentOS 6 docker image allowing the full test
  suite to be run against that operating system.
* Some documentation improvements and fixed some typos.
* The spec tests will now fail if there is not 100% coverage.

## 2016-12-01 - Release 2.2.0 ([diff](https://github.com/locp/cassandra/compare/2.1.2...2.2.0))

### Summary

At long last we have a defined type for handling permissions (something that
we have been promising since May).  Added some more facts for assisting
in JVM tuning.  Also fixed an error that was happening when attempting to
build the project.

### Features

* Added the `permissions` attribute to the `cassandra::schema` class.
* Added the `cassandra::schema::permission`

### Bugfixes

* Some refactoring of the ruby code since the release of Rubocop 0.46.0 which
  was failing code that previously had passed OK.

## 2016-11-02 - Release 2.1.2 ([diff](https://github.com/locp/cassandra/compare/2.1.1...2.1.2))

### Summary

Basically a non-functional release to reduce some of the technical debt
from the 2.0.0 release.  Also some minor improvements to the documentation.

## 2016-11-19 - Release 1.26.1 ([diff](https://github.com/locp/cassandra/compare/1.26.0...1.26.1))

### Summary

Retro-fitted a bug that was fixed in 2.1.1 into the 1.X.Y version of the module.

### Bugfixes

* A hotfix for a bug in `cassandra::schema` that has been around since version 1.18.0 of this
  module.

## 2016-11-02 - Release 2.1.1 ([diff](https://github.com/locp/cassandra/compare/2.1.0...2.1.1))

### Summary

A hotfix for a bug in `cassandra::schema` that has been around since version 1.18.0 of this
module.

### Bugfixes

* Fixed a bug where cql_types would not be created unless keyspaces were also provided.
* Fixed a minor typo in the README.

## 2016-10-29 - Release 2.1.0 ([diff](https://github.com/locp/cassandra/compare/2.0.2...2.1.0))

### Summary

A mixture of new features, a new style of documentation and other
improvements.  Also ran the [Sonar-Puppet](https://github.com/iwarapter/sonar-puppet)
plugin against the code to improve the code quality.

### Features

* The following facts are now available:
  * cassandramajorversion
  * cassandraminorversion
  * cassandrapatchversion
  * cassandrarelease
* The following attributes are now available:
  * cassandra::commitlog_directory
  * cassandra::commitlog_directory_mode
  * cassandra::data_file_directories
  * cassandra::data_file_directories_mode
  * cassandra::hints_directory
  * cassandra::hints_directory_mode
  * cassandra::saved_caches_directory
  * cassandra::saved_caches_directory_mode
  * cassandra::systemctl

### Bugfixes

* Resolved all issues identified by Sonar-Puppet from 38 (2 major,
  36 minor).  In doing so, this reduced the technical debt ration
  from 0.9% to 0.0%.

### Improvements

* The reference documentation is now processed via
  http://locp.github.io/cassandra
* Made a start on refactoring the spec/unit tests so that there is less
  duplication of code.

## 2016-10-12 - Release 2.0.2 ([diff](https://github.com/locp/cassandra/compare/2.0.1...2.0.2))

### Summary

This is a non-functional patch release that fixes some issues in documentation, and fixes some
bugs and makes some improvements in our testing framework.

### Improvements

* Ensure there is a framework for supporting the legacy 1.X.Y. module until the end of 2016.
* A more obvious test rig for the beaker/acceptance tests on TravisCI.

### Bugfixes

* Corrected misleading documentation.
* Ensure legacy test builds still work against Ruby 1.9.3.
* Corrected deprecated tags in the module metadata.

## 2016-10-08 - Release 1.26.0 ([diff](https://github.com/locp/cassandra/compare/1.25.2...1.26.0))

### Improvements
* The `cassandra::seeds` paramater can now be provided as an array or as a string.

# Bugfixes
* Ensure legacy builds still work on TravisCI.

## 2016-10-01 - Release 2.0.1 ([diff](https://github.com/locp/cassandra/compare/2.0.0...2.0.1))

### Summary

A non-functional release containing some improvements and documentation corrections.

### Improvements

* Corrected some out of date documentation.
* Removed some deprecated files.
* Regained 100% spec test coverage.

## 2016-09-29 - Release 2.0.0 ([diff](https://github.com/locp/cassandra/compare/1.26.0...2.0.0))

### Summary

This is a major release and will more than likely break your existing
manifest until you alter your code.  Please see the
[Upgrading](https://github.com/locp/cassandra/tree/release/274/v2.0.0#upgrading)
section of the README for further details.

* The method of passing parameters to Cassandra has been made more flexible.
* Support for Ubuntu 16.04.
* Changes to how `service_ensure` is handled.
* `cassandra::file` is now a define, not a class (as it should have been).

## 2016-09-03 - Release 1.25.2 ([diff](https://github.com/locp/cassandra/compare/1.25.1...1.25.2))

### Summary

The `service_systemd` attribute is now deprecated for the `cassandra`,
`cassandra::datastax_agent` and `cassandra::opscenter` classes.  See
https://github.com/locp/cassandra/wiki/DEP-020 for more details.

## 2016-08-14 - Release 1.25.1 ([diff](https://github.com/locp/cassandra/compare/1.25.0...1.25.1))

### Summary

Bugfix to ensure that the name of the PID file for the DataStax Agent service
matches with the service name.

## 2016-07-17 - Release 1.25.0 ([diff](https://github.com/locp/cassandra/compare/1.24.3...1.25.0))

### Summary

A feature release.

### Features

* The `cassandra` class now has a `disk_access_mode` attribute.

## 2016-06-26 - Release 1.24.3 ([diff](https://github.com/locp/cassandra/compare/1.24.2...1.24.3))

### Summary

A couple of non-functional bug fixes.

### Bugfixes

* The new version of RuboCop flagged code changes required in the Vagrantfile.
* The new version of Puppet Lint flagged code changes required in cassandra::java.

## 2016-06-20 - Release 1.24.2 ([diff](https://github.com/locp/cassandra/compare/1.24.1...1.24.2))

### Summary

A non-functional bug fix.

### Bugfixes

* The release of the specinfra gem (2.59.1) caused problems with our build.  Pinned now to 2.59.0.

## 2016-06-18 - Release 1.24.1 ([diff](https://github.com/locp/cassandra/compare/1.24.0...1.24.1))

### Summary

Really only affects CentOS 7 as all the other supported operating systems do
not require the systemd file to be installed.

### Bugfixes

* Change the way that systemd shuts Cassandra down.

## 2015-05-25 - Release 1.24.0 ([diff](https://github.com/locp/cassandra/compare/1.23.1...1.24.0))

### Summary

A Debian-centric release.  Debian 8 is now supported and a workaround for
[CASSANDRA-2356](https://issues.apache.org/jira/browse/CASSANDRA-2356)
(which only affects Debian.


### Features

* New attributes to the `::cassandra` class are:
  * cassandra_2356_sleep_seconds
  * config_path_parents
  * rackdc_tmpl

### Bugfixes

* CASSANDRA-2356

### Improvements

* Debian 8 is now part of the acceptance testing release process.

## 2016-05-10 - Release 1.23.1 ([diff](https://github.com/locp/cassandra/compare/1.23.0...1.23.1))

### Summary

A minor bugfix that fixes a problem that would only affect module developers,
not users of the module.

### Bugfixes

* Rubocop 0.4.0 is stricter so implemented changes that were flagged by it.

## 2016-05-07 - Release 1.23.0 ([diff](https://github.com/locp/cassandra/compare/1.22.1...1.23.0))

### Summary

A couple of new features, a non-functional improvement and a bugfix.

### Features

* Added the cassandra::file class.
* Added the following attributes to the cassandra::schema class:
  * cqlsh_client_tmpl
  * cqlsh_client_config

### Bugfixes

* Fixed a daft error that stopped beaker tests running on CentOS 7.

### Improvements

* Improved how fast the beaker/acceptance tests are run from TravisCI.

## 2016-05-03 - Release 1.22.1 ([diff](https://github.com/locp/cassandra/compare/1.22.0...1.22.1))

### Summary

A non-functional release for a minor improvement and a bug fix.

### Bugfixes

* Fixes a problem with resource ordering if the service_refresh attribute
  is set to false.

### Improvements

* Test coverage in Coveralls is now back at 100%
  (https://coveralls.io/github/locp/cassandra).

## 2016-04-25 - Release 1.22.0 ([diff](https://github.com/locp/cassandra/compare/1.21.0...1.22.0))

### Summary

Two new features.

### Features

* Allow the creation and dropping of users with the following:
  * A new defined type cassandra::schema::user
  * The new attribute cassandra::schema::users
* Allow the manipulation of the environment file with the new class
  cassandra::env.

## 2016-04-20 - Release 1.21.0 ([diff](https://github.com/locp/cassandra/compare/1.20.0...1.21.0))

### Summary

Some minor bug fixes.  Also some features and improvements that allow
acceptance tests to be run against Cassandra 3.

### Features

* Added the following attributes to cassandra::java:

  * aptkey
  * aptsource
  * yumrepo

### Bugfixes

* Corrected some errors in the README and CHANGELOG.
* Fixed problems with TravisCI builds.
* Fixed problems with CircleCI builds.

### Improvements

* Acceptance testing of Cassandra 3.

## 2016-04-13 - Release 1.20.0 ([diff](https://github.com/locp/cassandra/compare/1.19.0...1.20.0))

### Summary

A minor release for client requirements.

### Features

* Added the compaction_large_partition_warning_threshold_mb and
  memtable_allocation_type attributes to the cassandra class.

## 2016-04-06 - Release 1.19.0 ([diff](https://github.com/locp/cassandra/compare/1.18.1...1.19.0))

### Summary

A new template attribute and a couple of bug fixes.

### Features

* The hints_directory attribute has been added to the cassandra class for
  placing into the template.

### Bugfixes

* Some documentation errors that had been identified have been resolved.
* A problem with OpsCenter and systemd has been resolved.  So far only CentOS 7
  from the supported operating systems has been identified as being required
  to use systemd.

## 2016-03-27 - Release 1.18.1 ([diff](https://github.com/locp/cassandra/compare/1.18.0...1.18.1))

### Summary

Bug fixes and some minor and non-functional improvements.

### Bugfixes

* Resource ordering clarified in the cassandra::schema class.
* The cqlsh command now attempts to connect to rpc_address, not the
  listen_address.

### Improvements

* Optimised the CircleCI build process.
* Made some changes to the documentation to better reflect the new
  functionality delivered in 1.18.0.

## 2016-03-26 - Release 1.18.0 ([diff](https://github.com/locp/cassandra/compare/1.17.0...1.18.0))

### Summary

Some more functionality and sub-classes for cassandra::schema.  Also some code
and pipe-line improvements and a couple of bug fixes.

### Features

* The cassandra::schema class now has the following additional attributes:
  * cql_types
  * indexes
  * tables

  There are also corresponting defined types for those attributes:
  * cassandra::schema::cql_type
  * cassandra::schema::index
  * cassandra::schema::table

* The cassandra::opscenter class now has a new attribute called
  ldap_group_search_filter_with_dn.

### Bugfixes

* In the firewalls class, an OpsCenter server also needs to connect to the
  Cassandra node it is monitoring as a client.  The ports have been
  adjusted to allow this to happen.
* rspec-puppet version 2.4.0 was breaking our builds so pegged ourselves to
  2.3.2.

### Improvements

* Some minor and non-functional improvements to the build pipe-line.
* Carried out an audit using the Puppet plugin for SonarQube.  The number
  of issues has been reduced from 227 (13 major, 214 minor) to 4 major issues
  of which 2 are false positives. The remaining issues will be resolved in
  2.0.0.


## 2016-03-22 - Release 1.17.0 ([diff](https://github.com/locp/cassandra/compare/1.16.0...1.17.0))

### Summary

Another small change that is an emergency requirement for a client.

### Features

* Added the `storage_keyspace` attribute to the cassandra::datastax_agent class.

## 2016-03-15 - Release 1.16.0 ([diff](https://github.com/locp/cassandra/compare/1.15.1...1.16.0))

### Summary

A smaller release than usual, but containing changes required for a client.

### Features

* Added the `hosts` attribute to the cassandra::datastax_agent class.

### Bugfixes

* The **address.yaml** file for the DataStax agent is now owned by the cassandra user.

## 2016-03-11 - Release 1.15.1 ([diff](https://github.com/locp/cassandra/compare/1.15.0...1.15.1))

### Summary

A small improvement.

### Improvements

* Clarified CQL and Python versions.

## 2016-03-10 - Release 1.15.0 ([diff](https://github.com/locp/cassandra/compare/1.14.2...1.15.0))

### Summary

A rather large release.  Minor (non-functional) fixes to the production
pipeline and new features.

### Features

* A new class `cassandra::schema` allows the creation and dropping of
  keyspaces.
* Added the `additional_lines` attribute to the `cassandra` class.
* Added the `service_systemd` attribute to the `cassandra::opscenter`
  class.
* Allow the systemd template sources to be specified by the user.  This is
  with the `service_systemd_tmpl` attribute to the following classes:

  * cassandra
  * cassandra::datastax_agent
  * cassandra::opscenter
* Added another template file for `cassandra` => `service_systemd_tmpl`
  that is suitable for Cassandra 2.0.

### Bugfixes

* Worked around a problem with rake-11 in the Gemfile.
* Fixed a problem in the CircleCI configuration.

### Improvements

* Renamed the `ensure` attribute to `package_ensure` so that it is more
  in line with how it's called in other modules.  This was done on the
  the following classes:

  * cassandra::optutils
  * cassandra::opscenter
  * cassandra::opscenter::pycrypto
  * cassandra::java
* Updated the AWS AMI for the TravisCI/AWS acceptance testing to hopefully
  speed up builds a bit.

## 2016-02-29 - Release 1.14.2 ([diff](https://github.com/locp/cassandra/compare/1.14.1...1.14.2))

### Summary

A small bugfix release.

### Bugfixes

* Removed `Restart=always` from the Systemd configuration files.

## 2016-02-27 - Release 1.14.1 ([diff](https://github.com/locp/cassandra/compare/1.14.0...1.14.1))

### Summary

A non-functional release of improvements and a bugfix.

### Bugfixes

* If a systemd service file is created or updated, then systemctl daemon-reload
  is now be executed.

### Improvements

* The workflow for building the module has been improved to include:
  * Automatic integration of improvements and bugfixes into release candidates.
  * Testing of release candidates includes acceptance (beaker) as well as
    unit (spec) tests.
  * The refactoring of the majority of the Ruby code used to test and
    build this module so that it is hopefully more readable and easier to
    maintain.
  * The automation of what had previously been manual steps when building a
    release.

## 2016-02-19 - Release 1.14.0 ([diff](https://github.com/locp/cassandra/compare/1.13.0...1.14.0))

### Summary

A minor release with one of each of a feature, bug fix and improvement.

### Features

* Added the orbited_longpoll attribute to the cassandra::opscenter class.

### Bugfixes

* Fixed a problem with the DataStax agent and systemd.

### Improvements

* Refactored the contributors section of the README.

## 2016-02-14 - Release 1.13.0 ([diff](https://github.com/locp/cassandra/compare/1.12.2...1.13.0))

### Summary

A mixed back of new features in the shape of attributes for the cassandra,
cassandra::datastax_agent and cassandra::opscenter classes.  A couple of
bug fixes and some non-functional improvements.

### Features

* Added the thrift_framed_transport_size_in_mb attribute to
  ::cassandra.
* Added the following attributes to ::cassandra::datastax_agent:
  * async_pool_size
  * async_queue_size
  * service_systemd
* Added the config_purge attribute to ::cassandra::opscenter.

### Bugfixes

* Removed incorrect puppet code from the README examples.
* Fixed a problem with the beaker 2.34.0 gem which was causing problems
  during automated acceptance testing.

### Improvements

* Changed the AWS instance type used by the TravisCI triggered acceptance
  tests from a c3.xlarge to c4.xlarge.
* Merged the acceptance tests virtual nodes into family specific node sets.
* Refactored the Gemfile.
* Changed references in the documentation to parameters to refer to
  attributes as that is more Puppet-like.
* Changed the format of the contributers section.

## 2016-02-12 - Release 1.12.2 ([diff](https://github.com/locp/cassandra/compare/1.12.1...1.12.2))

### Summary

More bug fixes.

### Bugfixes

* Fixed a problem with the Red Hat family and systemd not starting the
  service and reporting all service stops as failures, regardless of
  if they were or not.

## 2016-02-08 - Release 1.12.1 ([diff](https://github.com/locp/cassandra/compare/1.12.0...1.12.1))

### Summary

This is a non-functional release.  Some bug fixes and release improvements.

### Bugfixes

* Completed documentation for attributes.  This was missing for the
  `inter_dc_stream_throughput_outbound_megabits_per_sec` and
  `stream_throughput_outbound_megabits_per_sec` options.
* Corrected the ownership and directories for the OpsCenter configuration.

### Improvements

* Nightly build created so that issues similar to those found in issues
  #136 and #157 can be caught quicker.

## 2016-01-27 - Release 1.12.0 ([diff](https://github.com/locp/cassandra/compare/1.11.0...1.12.0))

### Summary

A new feature in the cassandra::datastax_agent class, a minor bug fix and integration with CircleCI.

### Features

* There is now an agent_alias attribute for the cassandra::datastax_agent class.

### Bugfixes

* Unit tests were failing due to problems with the puppet-3.8.5 gem.

### Improvements

* In addition to TravisCI, the build process is now integrated with
  [CircleCI](https://circleci.com/gh/locp/cassandra).

## 2016-01-01 - Release 1.11.0 ([diff](https://github.com/locp/cassandra/compare/1.10.0...1.11.0))

### Summary

New features added to the main class.  Also some non-functional improvements.

### Features

* The addition of the listen_interface and rpc_interface attributes to the
  main class.

### Improvements

* Added more detail to the attributes to the main class in the README.
* Improved the module metadata.
* Clarified private defined types with the private subclass.
* The test coverage in release 1.10.0 dropped to 99.09%.  Got it back to
  100% in this release.

## 2015-12-19 - Release 1.10.0 ([diff](https://github.com/locp/cassandra/compare/1.9.2...1.10.0))

### Summary

A feature release with minor improvements.

### Features

* Added the ability to allow setting the local_interface for the DataStax
  agent configuration.
* Allow the service provider to be specified for the Cassandra, DataStax
  agent and OpsCenter services  with the service_provider attribute.
* Optionally allow a systemd system file be inserted with the
  cassandra::service_systemd attribute.

### Improvements

* Allow the files resources specified with in the cassandra attributes:
  * commitlog_directory
  * data_file_directories
  * saved_caches_directory

  To co-exist with file resources with the same name.

## 2015-11-21 - Release 1.9.2 ([diff](https://github.com/locp/cassandra/compare/1.9.1...1.9.2))

### Summary

A bug fix release that deals with some problems with Cassandra 3.

### Bugfixes

* Attempt to mitigate against problems with Debian attempting to install Cassandra 3 when
  installing the dsc22 package.
* Also reverted the project home to the GitHub project page.

## 2015-11-09 - Release 1.9.1 ([diff](https://github.com/locp/cassandra/compare/1.9.0...1.9.1))

### Summary

A bug fix release.

### Bugfixes

* The default value for the permissions mode of the Cassandra configuration
  file were far too open.  Changed from 0666 to 0644.

## 2015-10-25 - Release 1.9.0 ([diff](https://github.com/locp/cassandra/compare/1.8.1...1.9.0))

### Summary

Added more features for the configuration of Cassandra, some improvements to
the testing carried out before a release and a minor correction to the
change log documentation.

### Features

* The following attributes have been added to the ::cassandra class to be
  configured into the configuration file:

  * client_encryption_algorithm
  * client_encryption_cipher_suites
  * client_encryption_protocol
  * client_encryption_require_client_auth
  * client_encryption_store_type
  * client_encryption_truststore
  * client_encryption_truststore_password
  * counter_cache_size_in_mb
  * index_summary_capacity_in_mb
  * key_cache_save_period
  * key_cache_keys_to_save
  * seed_provider_class_name
  * server_encryption_algorithm
  * server_encryption_cipher_suites
  * server_encryption_protocol
  * server_encryption_require_client_auth
  * server_encryption_store_type

  Please see the README file for more details.

### Bugfixes

* Corrected an incorrect date (typo) in this document.

### Improvements

* There is now an automated test to mitigate the risk of unnecessarily
  refreshes of the Cassandra service due to non-functional changes to the
  configuration file.

## 2015-10-14 - Release 1.8.1 ([diff](https://github.com/locp/cassandra/compare/1.8.0...1.8.1))

### Summary

A minor bug fix.

### Bugfixes

* Fixed an edge case issue concerning users that may have been using the
  fail_on_non_supported_os before it was fixed in 1.8.0.

## 2015-10-06 - Release 1.8.0 ([diff](https://github.com/locp/cassandra/compare/1.7.1...1.8.0))

### Summary

Some new features a minor bug fix and some non-functional improvements.

### Features

* Added the service_refresh and config_file_mode attributes to the Cassandra
  class.

### Bugfixes

* The name of the fail_on_non_supported_os attribute has been corrected.

### Improvements

* Automated acceptance tests in preparation for a release now run faster.

##1015-10-01 - Release 1.7.1 ([diff](https://github.com/locp/cassandra/compare/1.7.0...1.7.1))

### Summary

A minor bug fix that incorrctly gave a failed build status for the module.

### Bugfixes

* Fixed a problem that was showing the status of the module build as an
  error since the release of the fog-google gem version 0.1.1.

## 2015-10-01 - Release 1.7.0 ([diff](https://github.com/locp/cassandra/compare/1.6.0...1.7.0))

### Summary

* Corrected a bug in how commitlog_sync has handled by Cassandra.
* Some non-functional improvements
* Additional features for the cassandra::datastax_repo class.

### Features

* Added the commitlog_segment_size_in_mb attribute to the cassandra class.
* Added the following fields to the cassandra::datastax_repo class:

  * descr
  * key_id
  * key_url
  * pkg_url
  * release

  This should make the configuring of repositories more flexible.

### Bugfixes

* Fixed a bug in how the commitlog_sync and the attributes that are
  associated with it are handled

### Improvements

The following non-functional improvements were implemented:

* Added tags to the module metadata.
* Migrated the acceptance tests from Vagrant to Docker.  The associated
  improvements to performance means that more rigorous acceptance tests can
  be applied in a shorter time.  For the first time as well, they are
  visible on Travis.

## 2015-09-23 - Release 1.6.0 ([diff](https://github.com/locp/cassandra/compare/1.5.0...1.6.0))

### Summary

More attributes for ::cassandra and ::cassandra::datastax_agent.  Also some
non-functional improvements in the automated unit tests.

### Features

* The JAVA_HOME can now be set for the datastax_agent (see the
  cassandra::datastax_agent => java_home attribute).
* The file mode for the directories can now be specified for the
  commitlog_directory, data_file_directories and the saved_caches_directory
  in the cassandra class.

### Improvements

* Uncovered resources in the unit testing are now tested.

## 2015-09-21 - Release 1.5.0 ([diff](https://github.com/locp/cassandra/compare/1.4.2...1.5.0))

### Summary

More attributes have been added that can be configured into the
cassandra.yaml file.

### Features

* The following attributes to the cassandra class can be configured into
  the cassandra configuration:
  * broadcast_address
  * broadcast_rpc_address
  * commitlog_sync
  * commitlog_sync_batch_window_in_ms
  * commitlog_total_space_in_mb
  * concurrent_compactors
  * counter_cache_keys_to_save
  * file_cache_size_in_mb
  * initial_token
  * inter_dc_stream_throughput_outbound_megabits_per_sec
  * internode_authenticator
  * internode_recv_buff_size_in_bytes
  * internode_send_buff_size_in_bytes
  * memory_allocator
  * memtable_cleanup_threshold
  * memtable_flush_writers
  * memtable_heap_space_in_mb
  * memtable_offheap_space_in_mb
  * native_transport_max_concurrent_connections
  * native_transport_max_concurrent_connections_per_ip
  * native_transport_max_frame_size_in_mb
  * native_transport_max_threads
  * permissions_update_interval_in_ms
  * phi_convict_threshold
  * request_scheduler_options_default_weight
  * request_scheduler_options_throttle_limit
  * row_cache_keys_to_save
  * rpc_max_threads
  * rpc_min_threads
  * rpc_recv_buff_size_in_bytes
  * rpc_send_buff_size_in_bytes
  * streaming_socket_timeout_in_ms
  * stream_throughput_outbound_megabits_per_sec

### Improvements

* Clarity of changes per release in the change log (this document).

## 2015-09-15 - Release 1.4.2 ([diff](https://github.com/locp/cassandra/compare/1.4.1...1.4.2))

### Summary

Fixed a problem identified whilst releasing 1.4.1 and a bug fixed by a
contributed pull request.

### Features

* n/a

### Bugfixes

* Fixed a problem with the acceptance tests.
* The datastax-agent service is restarted if the package is updated.

### Improvements

* n/a


## 2015-09-15 - Release 1.4.1 ([diff](https://github.com/locp/cassandra/compare/1.4.0...1.4.1))

### Summary

This release fixes a minor bug (possibly better described as a typing mistake)
and makes some non-functional improvements.  It also allows the user to
override the default behaviour of failing on a non-supported operating system.

### Features

* A new flag called `fail_on_non_suppoted_os` has been added to the
  `cassandra` class and can be set to **false** so that an attempt can be
  made to use this module on an operating system that is not in the Debian
  or Red Hat families.

### Bugfixes

* Changed the default value for the `package_name` of the
  `cassandra::optutils` class from `'undef'` to *undef*.

### Improvements

* Clarified the expectations of submitted contributions.
* Unit test improvements.

## 2015-09-10 - Release 1.4.0 ([diff](https://github.com/locp/cassandra/compare/1.3.7...1.4.0))

* Ensured that directories specified in the directory attributes
  are controlled with file resources.

* Added the following attributes to the cassandra.yml file:
  * batchlog_replay_throttle_in_kb
  * cas_contention_timeout_in_ms
  * column_index_size_in_kb
  * commit_failure_policy
  * compaction_throughput_mb_per_sec
  * counter_cache_save_period
  * counter_write_request_timeout_in_ms
  * cross_node_timeout
  * dynamic_snitch_badness_threshold
  * dynamic_snitch_reset_interval_in_ms
  * dynamic_snitch_update_interval_in_ms
  * hinted_handoff_throttle_in_kb
  * index_summary_resize_interval_in_minutes
  * inter_dc_tcp_nodelay
  * max_hints_delivery_threads
  * max_hint_window_in_ms
  * permissions_validity_in_ms
  * range_request_timeout_in_ms
  * read_request_timeout_in_ms
  * request_scheduler
  * request_timeout_in_ms
  * row_cache_save_period
  * row_cache_size_in_mb
  * sstable_preemptive_open_interval_in_mb
  * tombstone_failure_threshold
  * tombstone_warn_threshold
  * trickle_fsync
  * trickle_fsync_interval_in_kb
  * truncate_request_timeout_in_ms
  * write_request_timeout_in_ms

## 2015-09-08 - Release 1.3.7 ([diff](https://github.com/locp/cassandra/compare/1.3.6...1.3.7))
* Made the auto_bootstrap attribute available.

## 2015-09-03 - Release 1.3.6 ([diff](https://github.com/locp/cassandra/compare/1.3.5...1.3.6))
* Fixed a bug, now allowing the user to set the enabled state of the Cassandra
  service.
* More cleaning up of the README and more links in that file to allow
  faster navigation.

## 2015-09-01 - Release 1.3.5 ([diff](https://github.com/locp/cassandra/compare/1.3.4...1.3.5))
* Fixed a bug, now  allowing the user to set the running state of the
  Cassandra service.
* More automated testing with spec tests.
* A refactoring of the README.

## 2015-08-28 - Release 1.3.4 ([diff](https://github.com/locp/cassandra/compare/1.3.3...1.3.4))
* Minor corrections to the README.
* The addition of the storage_cassandra_seed_hosts attribute to
  cassandra::opscenter::cluster_name which is part of a bigger part of
  work but is urgently require by a client.

## 2015-08-27 - Release 1.3.3 ([diff](https://github.com/locp/cassandra/compare/1.3.2...1.3.3))
* Corrected dependency version for puppetlabs-apt.

## 2015-08-26 - Release 1.3.2 ([diff](https://github.com/locp/cassandra/compare/1.3.1...1.3.2))
* Fixed bug in cassandra::opscenter::cluster_name.
* Fixed code in cassandra::firewall_ports::rule to avoid deprecation
  warnings concerning the use of puppetlabs-firewall => port.
* Added more examples to the README

## 2015-08-22 - Release 1.3.1 ([diff](https://github.com/locp/cassandra/compare/1.3.0...1.3.1))
This was mainly a non-functional change.  The biggest thing to say is that
Debian 7 is now supported.

## 2015-08-19 - Release 1.3.0 ([diff](https://github.com/locp/cassandra/compare/1.2.0...1.3.0))
* Allow additional TCP ports to be specified for the host based firewall.
* Fixed a problem where the client subnets were ignored by the firewall.
* Added more automated testing.
* Continued work on an ongoing improvement of the documentation.
* Added the ability to set the DC and RACK in the snitch properties.

## 2015-08-10 - Release 1.2.0 ([diff](https://github.com/locp/cassandra/compare/1.1.0...1.2.0))
* Added the installation of Java Native Access (JNA) to cassandra::java
* For DataStax Enterprise, allow the remote storage of metric data with
  cassandra::opscenter::cluster_name.

## 2015-08-03 - Release 1.1.0 ([diff](https://github.com/locp/cassandra/compare/1.0.1...1.1.0))
* Provided the cassandra::firewall_ports class.
* All OpsCenter options are now configurable in opscenterd.conf.
* ssl_storage_port is now configurable.

## 2015-07-27 - Release 1.0.1 ([diff](https://github.com/locp/cassandra/compare/1.0.0...1.0.1))
* Provided a workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

## 2015-07-25 - Release 1.0.0 ([diff](https://github.com/locp/cassandra/compare/0.4.3...1.0.0))
* Changed the default installation from Cassandra 2.1 to 2.2.
* Fixed a bug that arose when the cassandra config_path was set.
* Created a workaround for
  [PUP-3829](https://tickets.puppetlabs.com/browse/PUP-3829).
* Minor changes to the API (see the Upgrading section of the README).
* Allow a basic installation of OpsCenter.

## 2015-07-18 - Release 0.4.3 ([diff](https://github.com/locp/cassandra/compare/0.4.2...0.4.3))
* Module dependency metadata was too strict.

## 2015-07-16 - Release 0.4.2 ([diff](https://github.com/locp/cassandra/compare/0.4.1...0.4.2))

* Some minor documentation changes.
* Fixed a problem with the module metadata that caused Puppetfile issues.
* Integrated with Coveralls (https://coveralls.io/github/locp/cassandra).
* Removed the deprecated config and install classes.  These were private
  so there is no change to the API.

## 2015-07-14 - Release 0.4.1 ([diff](https://github.com/locp/cassandra/compare/0.4.0...0.4.1))

* Fixed a resource ordering problem in the cassandra::datastax class.
* Tidied up the documentation a bit.
* Some refactoring of the spec tests.

## 2015-07-12 - Release 0.4.0 ([diff](https://github.com/locp/cassandra/compare/0.3.0...0.4.0))
### Summary

* Some major changes to the API on how Java, the optional Cassandra tools and
  the DataStax agent are installed.  See the Upgrading section of the README
  file.
* Allowed the setting of the *stomp_interface* for the DataStax agent.
* Non-functionally, we have integrated with Travis CI (see
  https://travis-ci.org/locp/cassandra for details) and thanks to those guys
  for providing such a neat service.
* More spec tests.

## 2015-06-27 - Release 0.3.0 ([diff](https://github.com/locp/cassandra/compare/0.2.2...0.3.0))
### Summary

* Slight changes to the API.  See the Upgrading section of the README file
  for full details.
* Allow for the installation of the DataStax Agent.
* Improved automated testing (and fixed some bugs along the way).
* Confirmed Ubuntu 12.04 works OK with this module.
* A Cassandra 1.X template has been provided.
* Some smarter handling of the differences between Ubuntu/Debian and RedHat
  derivatives.

## 2015-06-17 - Release 0.2.2 ([diff](https://github.com/locp/cassandra/compare/0.2.1...0.2.2))
### Summary
A non-functional change to change the following:

* Split the single manifest into multiple files.
* Implement automated testing.
* Test on additional operating systems.

## 2015-05-28 - Release 0.2.1 ([diff](https://github.com/locp/cassandra/compare/0.2.0...0.2.1))
### Summary
A non-functional change to fix puppet-lint problems identified by Puppet
Forge.

## 2015-05-28 - Release 0.2.0 ([diff](https://github.com/locp/cassandra/compare/0.1.0...0.2.0))
### Summary
Added more attributes and improved the module metadata.

## 2015-05-26 - Release 0.1.0
### Summary
An initial release with **VERY** limited options.


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
