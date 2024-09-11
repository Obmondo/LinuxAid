# deric-beegfs Changelog

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
