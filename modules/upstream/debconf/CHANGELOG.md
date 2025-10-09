## 2025-08-15 - Release 7.0.1

### Features

- Update CHANGELOG.md that support has been removed for Ubuntu-18.04 and not Ubuntu-24.04.

## 2025-08-14 - Release 7.0.0

### Features

- Add Debian-13 (Trixie) to the list of supported operating systems.

### Breaking changes

- Drop support for Debian-10.
- Drop support for Ubuntu-18.04.

## 2025-05-29 - Release 6.2.0

### Bugfixes

- The debconf value can now also be an empty string

### Features

- Remove legacy facts

## 2024-08-13 - Release 6.1.0

### Features

- Add sensible error message when calling `puppet resource debconf`.
- Add Ubuntu-24.04 (Noble) to the list of support operating systems.

## 2023-07-07 - Release 6.0.0

### Features

- Add support for Puppet 8

### Breaking changes

- Drop support for Puppet 6

## 2022-07-27 - Release 5.0.0

### Features

- Add Ubuntu 22.04 (Jammy) to the list of supported operating systems.

### Breaking changes

- Drop Ubuntu 16.04 support
- Drop Debian 9 support

## 2021-09-15 - Release 4.1.0

### Bugfixes

- Allow multiple resources for the same item in different packages without raising a duplicate resource error.

## 2021-08-30 - Release 4.0.0

### Breaking changes

- Drop Ubuntu 14.04 support
- Drop Debian 8 support

### Features

- Add Debian 11 (Bullseye) to the list of supported operating systems.

## 2021-03-04 - Release 3.3.1

### Bugfixes

- Fix `wrong number of arguments` error introduced by Rubocop triggered change.

## 2021-03-04 - Release 3.3.0

### Features

- Add support for Puppet 7.

## 2020-06-22 - Release 3.2.0

### Features

- Add Ubuntu 20.04 (Focal Fossa) to the list of supported operating systems.
- Add Debian 10 (Buster) to the list of supported operating systems.

## 2019-09-27 - Release 3.0.0

### Breaking changes

- Remove support for Puppet 4.

## 2018-10-14 - Release 2.3.0

### Features

- Add support for Puppet 6.
- Remove Debian 7 and Ubuntu 17.10 as supported operating systems.

## 2018-07-02 - Release 2.2.1

### Features

- Add Ubuntu 18.04 (Bionic Beaver) to the list of supported operating systems.
- Convert to Puppet PDK.

## 2018-05-08 - Release 2.2.0

### Features

- The type has a new `seen` parameter to define the value of the seen flag for an item. Setting this parameter to a boolean value will set the flag to the specified value. Leaving this parameter undefined will retain the old behavior.

## 2018-02-04 - Release 2.1.0

### Features

This release removes support for some legacy OS releases.

### Bugfixes

- Fix a bug where a pipe to a subprocess was closed too late. This caused a subprocess to become a zombie until the Puppet run finished.

## 2017-03-10 - Release 2.0.0

### Features

- Added Ubuntu 16.10 (Yakkety Yak) to the list of supported operating systems.

### Bugfixes

- Added an additional validation for the `type` parameter. This effectively makes the parameter mandatory for `ensure => present`. The type of the entry is required when the entry is missing in the debconf database and has to be created.
- Fix a bug that prevented reading a preseeded password correctly. Previously a password item would trigger a resource update with every Puppet run.

## 2016-05-13 - Release 1.0.0

### Summary

Initial release.
