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
