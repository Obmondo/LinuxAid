## 1.9.0
## Summary
This release includes a change that makes this module *compatible* with AIX.

#### Added
- Make MOTD compatible with AIX. ([MODULES-7069](https://tickets.puppetlabs.com/browse/MODULES-7069))
- Parameter `windows_motd_title` to allow users to customize the Windows message of the day title.
- Converted to the latest version of PDK (1.5.0).

## Release 1.8.0
### Summary
This release includes a change that makes this module *compatible* with FreeBSD.

#### Added
- Make MOTD compatible with FreeBSD. ([MODULES-6599](https://tickets.puppetlabs.com/browse/MODULES-6599))

## Release 1.7.0
### Summary
Release for PDK 1.3.2 compatibility.

#### Changed
- Converted to the latest version of PDK. Mainly introduces travis to the release branch.

## Release 1.6.0
### Summary
A release that updates motd to become PDK compatible.

#### Changed
- All changes in this release are the product of PDK convert, the module is now PDK compatible.

## Release 1.5.1
### Summary
This release is to update the formatting of the module, rubocop having been run for all ruby files and been set to run automatically on all future commits.

### Changed
- Rubocop has been implemented.

## Release 1.5.0
### Summary
This release is a rollup of changes.

#### Features:
- Support added for Solaris SunOS.
- Default MOTD message changed to provide greater out of the box usability.
- Removed support for deprecated versions of Ubuntu.
- Added a permissions mode for the file.

#### Bug Fixes:
- Changed fact processor name.

## Release 1.4.0
### Summary
First Puppet Labs supported release of this module! Contains new features and bug fixes for tests.

#### Features:
- New readme file added for tests. Also several new tests added.
- Addition of handling in tests to run with Debian 8.

#### Bug Fixes:
- Tests tweaked to handle several Debian versions.
- Fixed acceptance tests for Windows.


## Release 1.3.0
### Summary
This release adds documentation updates, test improvements, and os support.

#### Features:
- Acceptance testing on Linux platforms.
- Rewritten documentation, inclusion of strings for automated documentation.
- Linting of manifest to conform to style guidelines.
- Adds support for several operating systems:
  - Debian 6, 7
  - CentOS 5, 6, 7
  - Oracle Linux 6, 7
  - Scientific Linux 5, 6, 7

### 2014-10-31 Release 1.2.0
### Summary
- Add content parameter to allow setting static motd content.

## 2014-07-15 Release 1.1.1
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-05-28 Release 1.1.0
###Summary

The main feature of this release is support for external templates.
It also includes documentation and testing improvements.

####Features

- Added class parameter to support external templates.
- Updated README documentation.
- Improved Testing.

####Fixes

- Add LICENSE file.

####Known Bugs
