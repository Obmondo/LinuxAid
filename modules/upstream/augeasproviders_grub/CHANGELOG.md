# Changelog

## 3.2.0

- Support Puppet 6 (#42)
- Fix String value issues in grub_config (#46)
- Fix EFI code for grub_config and grub_menuentry (#48)
- Add BLS support to grub_menuentry (#50)

## 3.1.0

- Add back path for grub.cfg on Debian OS. (#36)
- Deprecate support for Puppet < 5
- Support Puppet 5 & 6
- Update supported OSes in metadata.json

## 3.0.1
- Fix generation of grub2 user entries
- Add support for OEL

## 3.0.0

- Added code to fix the EFI stack on Linux hosts
- Restricted the RHEL and CentOS support to only what can be tested
- Pinned supported puppet versions between 4.7.2 and 5.0.0
  - This is the oldest Puppet, Inc. supported version and there are currently
    issues in 5.X

## 2.4.0

- Add support for global GRUB configuration
- Add support for grub_menuentry providing the ability to manage individual
  menu entries for both GRUB Legacy and GRUB2
- Add support for managing GRUB2 users
- The following custom types were created:
  * grub_config :  Manages global GRUB settings
  * grub_menuentry : Manages GRUB menuentries
  * grub_user : Manages GRUB2 users
- Confine GRUB providers to presence of menus, prefer GRUB 2 (#8)
- Fix build on Ruby 1.8

## 2.3.0

- Fix GRUB_CMDLINE_LINUX_DEFAULT (issue #14)
- Add grub.cfg location for UEFI systems (issue #16)
- Add two defaults in grub2 provider (issue #17)

## 2.2.0

- Add support for bootmode 'default' (issue #3)

## 2.1.0

- Set default to grub2 provider on el7 based systems (fix #9)
- Load lenses from lib/augeas/lenses in tests
- Add Puppet 4 to test matrix

## 2.0.1

- Fix metadata.json
- Various minor updates to Travis test configuration

## 2.0.0

- First release of split module.
