# deric-beegfs Changelog

## 2024-06-25 Release 1.0.0

- **BC** `puppetlabs/stdlib` >= 9.0.0 is required due to usage of `stdlib::ensure_package` function
- `puppetlabs/apt` >= 9.0.0 needs [this patch](https://github.com/puppetlabs/puppetlabs-apt/pull/1050/commits/ea68ea521b8ea0ef460ee639759e76e22a620a7e) to work with ruby 3.0
- Fix incorrected `puppetlabs/concat` dependency requirement - at least `4.1.0` is needed (removed deprecated `is_string()`)
- Puppet 8 compatible

[Full changes](https://github.com/deric/puppet-beegfs/compare/v0.8.2...v1.0.0)


## 2024-03-06 Release 0.8.2

- Support fetching packages over http via `package_source` param [#36](https://github.com/deric/puppet-beegfs/pull/36)

[Full changes](https://github.com/deric/puppet-beegfs/compare/v0.8.1...v0.8.2)


## 2024-02-07 Release 0.8.1

- Fix unknown variables, revert to using inheritance [#35](https://github.com/deric/puppet-beegfs/issues/35)

[Full changes](https://github.com/deric/puppet-beegfs/compare/v0.8.0...v0.8.1)


## 2024-02-03 Release 0.8.0

- Add optional `sys_file_event_log_mask` parameter  [#33](https://github.com/deric/puppet-beegfs/pull/33)
- Add parameter for client tuneFileCacheType [#34](https://github.com/deric/puppet-beegfs/pull/34)
- Switch debian apt to https, use appropriate gpg key since 7.2.5
- Remove deprecated `has_key` function (removed in stdlib 9)
- Fix types, remove lookup call

[Full changes](https://github.com/deric/puppet-beegfs/compare/v0.7.2...v0.8.0)


## 2023-08-10 Release 0.7.2

- Add override parameter for baseurl in repo/redhat [#28](https://github.com/deric/puppet-beegfs/pull/28)
- Add `conn_auth_file` parameter [#26](https://github.com/deric/puppet-beegfs/pull/26)


## 2022-05-18 Release 0.7.1

- Support name change for repo GPG key (since BeeGFS release 7.2.6) [#25](https://github.com/deric/puppet-beegfs/pull/25)
- Make remoteFSync and connUseRDMA configurable [#21](https://github.com/deric/puppet-beegfs/pull/21)
- Bump dependencies [#22](https://github.com/deric/puppet-beegfs/pull/22)
- Better client resources ordering [#23](https://github.com/deric/puppet-beegfs/pull/23)

## 2021-08-30 Release 0.7.0

- Adding optional use of  sysAllowUserSetPattern [#19](https://github.com/deric/puppet-beegfs/pull/19)
- Allow newer dependencies
- Support newer distribution releases, drop very old ones (#20)

## 2020-11-18 Release 0.6.0

- Support annomalies in versioning [#16](https://github.com/deric/puppet-beegfs/pull/16)
- Add support for connNetFilterFile [#17](https://github.com/deric/puppet-beegfs/pull/17)
- Extend list of supported distributions (though not all beegfs releases works on all distributions)
- Interfaces configured after setting up client package

## 2019-09-25 Release 0.5.0

### Breaking Changes

- `beegfs::storage_directory` expects an Array instead of just String
- parameter `beegfs::major_version` renamed to `beegfs::release`
- `beegfs::client::client_udp` renamed to `beegfs::client::client_udp_port`

### Changes

- `beegfs::release` can be defined only globally (not for each subclass like `beegfs::meta`,`beegfs::storage`) - we're using shared repository major release can't be different
- add Puppet types [#14](https://github.com/deric/puppet-beegfs/pull/14)
- add BeeGFS 7 support with templates copied from a clean install (to expose all options) [#14](https://github.com/deric/puppet-beegfs/pull/14)
- add support for setting up admon [#14](https://github.com/deric/puppet-beegfs/pull/14)
- add Yum repo and RPM install [#14](https://github.com/deric/puppet-beegfs/pull/14)
- [Full changes to previous release](https://github.com/deric/puppet-beegfs/compare/v0.4.1...v0.5.0)

## 2018-01-16 Release 0.4.1

- Add switch to enable quota support [#12](https://github.com/deric/puppet-beegfs/pull/12)
- Add switch to enable ACL support [#12](https://github.com/deric/puppet-beegfs/pull/12)
- Add switches to set sysAllowNewServers and sysAllowNewTargets [#13](https://github.com/deric/puppet-beegfs/pull/13)
- [Full changes to previous release](https://github.com/deric/puppet-beegfs/compare/v0.4.0...v0.4.1)

## 2017-11-02 Release 0.4.0

- Remove Puppet 3 support
- Upgrade apt module dependency
- Support setting tuneRefreshOnGetAttr [#11](https://github.com/deric/puppet-beegfs/pull/11)

## 2017-08-10 Release 0.3.2

- Use deb9 release for Debian 9 Stretch

## 2017-07-27 Release 0.3.1

- Fixed autobuild dependency ([#10](https://github.com/deric/puppet-beegfs/pull/10))

## 2017-07-10 Release 0.3.0

- Autobuild configuration ([#7](https://github.com/deric/puppet-beegfs/pull/7))
- Support multiple storage directories ([#8](https://github.com/deric/puppet-beegfs/pull/8))
- Allow to set "storeAllowFirstRunInit" for meta, mgmtd and storage.
 ([#9](https://github.com/deric/puppet-beegfs/pull/9))

## 2017-06-29 Release 0.2.0

- Config files for BeeGFS 6
- Concat fix (#2)
- Allow changing log directory (#3)
