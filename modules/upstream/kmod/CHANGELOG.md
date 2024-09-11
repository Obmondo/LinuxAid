## 2020-03-09 - Release 2.5.0

* Add support for EL8 [GH #59]

## 2020-01-07 - Release 2.4.0

* Remove augeasversion check [GH #53]
* Convert to PDK [GH #54]

## 2019-07-30 - Release 2.3.1

* Allow stdlib 6

## 2019-03-01 - Release 2.3.0

* Add hiera class parameters and update documentation [GH #47]
* kmod::load: load modules the systemd way if the system runs systemd [GH #48]
* Adapt tests for Puppet 6

## 2017-08-09 - Release 2.2.0

* Add ArchLinux support [GH #39, #40]
* Fix ensure=absent in alias [GH #42]

## 2015-08-27 - Release 2.1.0

Add minimal SuSE support

## 2015-08-21 - Release 2.0.11

Use docker for acceptance tests

## 2015-06-26 - Release 2.0.10

Fix strict_variables activation with rspec-puppet 2.2

## 2015-05-28 - Release 2.0.9

Add beaker_spec_helper to Gemfile

## 2015-05-26 - Release 2.0.8

Use random application order in nodeset

## 2015-05-26 - Release 2.0.7

add utopic & vivid nodesets

## 2015-05-25 - Release 2.0.6

Don't allow failure on Puppet 4

## 2015-05-13 - Release 2.0.5

Add puppet-lint-file_source_rights-check gem

## 2015-05-12 - Release 2.0.4

Don't pin beaker

## 2015-04-27 - Release 2.0.3

Add nodeset ubuntu-12.04-x86_64-openstack

## 2015-04-18 - Release 2.0.2

- Add beaker nodeset

## 2015-04-15 - Release 2.0.1

- Fix kmod::install's file class parameter's default

## 2015-04-03 - Release 2.0.0

- Add kmod::option and refactored everything to use kmod::setting
- removed obsolete generic.pp

## 2015-03-24 - Release 1.0.6

- Lint

## 2015-01-19 - Release 1.0.5

- Fix relative class inclusions

## 2015-01-07 - Release 1.0.4

- Fix unquoted strings in cases

## 2014-12-16 - Release 1.0.1

- Fix for future parser

## 2014-10-20 - Release 1.0.0

- Setup automatic Forge releases

## 2014-07-02 - Release 0.1.1

- Fix deprecation warnings, #22

## 2014-07-02 - Release 0.1.0

- Add unit tests
- Various improvements
