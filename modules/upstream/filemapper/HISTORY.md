## [v2.1.0](https://github.com/voxpupuli/puppet-filemapper/tree/v2.1.0) (2017-02-11)

This is the last release with Puppet3 support!

* Set minimum version_requirement for Puppet
* Remove unnecessary disabling of RSpec/NestedGroups

## 2016-12-08 Release 2.0.1

  * Modulesync with latest Vox Pupuli changes
  * Fix several rubocop issues
  * define #path on filetype mocks/fix broken symbols

## 2016-08-19 Release 2.0.0

This is a backwards incompatible release.

  * Drop Ruby 1.8.7 support
  * Move to Vox Pupuli namespace
  * Significant code quality improvements
  * Modulesync with latest Vox Pupuli defaults
  * Sync mk_resource_methods with Puppet Core


Thanks to Joseph Yaworski and the Vox Pupuli teams for their work on this release.


## 2014-09-02 Release 1.1.3

This is a backwards compatible bugfix release.

  * Invoke super in self.initvars to initialize `@defaults`

Thanks to Igor Galić for his work on this release.


## 2014-07-04 Release 1.1.2

This is a backwards compatible bugfix release.

  * Update permissions of built modules to be a+rX.


## 2012-12-30 Release 1.1.1

This is a backwards compatible bugfix release.

  * (filemapper-#4) Add resource failure when in error state

Thanks to Reid Vandewiele for his contribution for this release.


## 2012-12-07 Release 1.1.0

This is a backwards compatible feature release.

  * Add Apache 2.0 LICENSE
  * Add Gemfile
  * (filemapper-#3) Add `unlink_empty_files` attribute
  * (maint) spec cleanup for readability
  * (filemapper-#2) Add pre and post flush hook support


## 2012-10-28 Release 1.0.2

This is a backwards compatible maintenance release.

  * Update metadata to reference forge username
  * Ensure implementing classes return a string from format_file


## 2012-10-16 Release 1.0.1

This is a backwards compatible maintenance release.

  * Remove call `#symbolize` method; said method was removed in Puppet 3.0.0
  * Fail fast if an including class returns bad data from Provider.parse_file
  * Don't try to fall back to `@resource.should` value for properties
