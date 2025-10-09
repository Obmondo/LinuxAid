# Change Log

## [v2.4.0](https://github.com/walkamongus/realmd/tree/v2.4.0) (2018-09-16)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v2.3.0...v2.4.0)

**Closed issues:**

- Ubuntu 16.04: Unknown Option --computer-name [\#43](https://github.com/walkamongus/realmd/issues/43)
- join with password, OU prefix [\#39](https://github.com/walkamongus/realmd/issues/39)

**Merged pull requests:**

- Ubuntu - Support realmd without --computer-name [\#53](https://github.com/walkamongus/realmd/pull/53) ([Romiko](https://github.com/Romiko))

## [v2.3.0](https://github.com/walkamongus/realmd/tree/v2.3.0) (2018-09-02)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v2.2.0...v2.3.0)

**Closed issues:**

- Duplicate declaration: Packages adcli and sssd are already declared. [\#49](https://github.com/walkamongus/realmd/issues/49)
- Hiera-eyaml problem in evaluating password \[parameter 'domain\_join\_password' expects a value of type Undef or String, got Struct\] [\#48](https://github.com/walkamongus/realmd/issues/48)
- Realmd is not available on Red Hat family 6 and older [\#47](https://github.com/walkamongus/realmd/issues/47)
- Ubuntu 14.04 and Puppet 3.8 [\#44](https://github.com/walkamongus/realmd/issues/44)
- params.pp is missing in version 2.1.0 [\#34](https://github.com/walkamongus/realmd/issues/34)
- Could not retrieve catalog: undefined method 'ref' for nil:NilClass [\#15](https://github.com/walkamongus/realmd/issues/15)

**Merged pull requests:**

- Gem updates [\#52](https://github.com/walkamongus/realmd/pull/52) ([walkamongus](https://github.com/walkamongus))
- Remove independently managed packages from required\_packages param [\#51](https://github.com/walkamongus/realmd/pull/51) ([walkamongus](https://github.com/walkamongus))
- Increase range of Puppet support [\#45](https://github.com/walkamongus/realmd/pull/45) ([tux-o-matic](https://github.com/tux-o-matic))
- Allow joining without password or on time password [\#42](https://github.com/walkamongus/realmd/pull/42) ([jradmacher](https://github.com/jradmacher))
- Allow user to specify additional options to "realm join" [\#41](https://github.com/walkamongus/realmd/pull/41) ([pjfbashton](https://github.com/pjfbashton))
- Removed OU prefix as distinguished names should already start with OU= [\#40](https://github.com/walkamongus/realmd/pull/40) ([acurus-puppetmaster](https://github.com/acurus-puppetmaster))

## [v2.2.0](https://github.com/walkamongus/realmd/tree/v2.2.0) (2017-10-31)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v2.1.0...v2.2.0)

**Closed issues:**

- Keytab join runs on every Puppet refresh [\#36](https://github.com/walkamongus/realmd/issues/36)
- use\_fully\_qualified\_names [\#33](https://github.com/walkamongus/realmd/issues/33)
- Path /usr/libexec/ doesn't exist on Ubuntu [\#31](https://github.com/walkamongus/realmd/issues/31)

**Merged pull requests:**

- Ensure /usr/libexec exists \(Issue \#31\) [\#38](https://github.com/walkamongus/realmd/pull/38) ([rsynnest](https://github.com/rsynnest))
- Added single quotes to OU to allow for OU structures containing spaces [\#37](https://github.com/walkamongus/realmd/pull/37) ([acurus-puppetmaster](https://github.com/acurus-puppetmaster))

## [v2.1.0](https://github.com/walkamongus/realmd/tree/v2.1.0) (2017-07-27)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v2.0.0...v2.1.0)

**Closed issues:**

- Lint issues and build failing [\#28](https://github.com/walkamongus/realmd/issues/28)
- hiera config [\#18](https://github.com/walkamongus/realmd/issues/18)
- realmd dependencies not installing from module [\#12](https://github.com/walkamongus/realmd/issues/12)

**Merged pull requests:**

- Fixed \_realm\_args and the join command [\#32](https://github.com/walkamongus/realmd/pull/32) ([tspeigner](https://github.com/tspeigner))
- Enable changing of default umask for mkhomedir. [\#30](https://github.com/walkamongus/realmd/pull/30) ([jmswick](https://github.com/jmswick))
- Conceal the AD join password using an ENV var [\#29](https://github.com/walkamongus/realmd/pull/29) ([jeffmccune](https://github.com/jeffmccune))
- Fix lint issues [\#27](https://github.com/walkamongus/realmd/pull/27) ([matonb](https://github.com/matonb))
- added support for ou join paramter, to specify context of the server [\#25](https://github.com/walkamongus/realmd/pull/25) ([MSchietzsch](https://github.com/MSchietzsch))

## [v2.0.0](https://github.com/walkamongus/realmd/tree/v2.0.0) (2017-06-25)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v1.0.0...v2.0.0)

**Closed issues:**

- Please drop a new version to Puppet Forge for Debian-based distros [\#22](https://github.com/walkamongus/realmd/issues/22)

**Merged pull requests:**

- Puppet 4 update [\#24](https://github.com/walkamongus/realmd/pull/24) ([walkamongus](https://github.com/walkamongus))

## [v1.0.0](https://github.com/walkamongus/realmd/tree/v1.0.0) (2017-06-24)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v0.1.3...v1.0.0)

**Closed issues:**

- Module is not idempotent when hostname is longer than 15 characters. [\#7](https://github.com/walkamongus/realmd/issues/7)
- No RHEL6 Support [\#5](https://github.com/walkamongus/realmd/issues/5)
- Package\[krb5-workstation\] is already declared [\#4](https://github.com/walkamongus/realmd/issues/4)
- 'realm\_join\_with\_password' doesnt get called again if domain join failed  [\#2](https://github.com/walkamongus/realmd/issues/2)

**Merged pull requests:**

- Required packages update [\#23](https://github.com/walkamongus/realmd/pull/23) ([walkamongus](https://github.com/walkamongus))
- Fix kinit never being run [\#11](https://github.com/walkamongus/realmd/pull/11) ([dodinh](https://github.com/dodinh))
- For rm commands, supply path instead of hardcoding one location [\#10](https://github.com/walkamongus/realmd/pull/10) ([dodinh](https://github.com/dodinh))
- klist lists the host with a maximum of 15 characters. [\#8](https://github.com/walkamongus/realmd/pull/8) ([as0bu](https://github.com/as0bu))
- Adding Debian Support [\#3](https://github.com/walkamongus/realmd/pull/3) ([andrewwippler](https://github.com/andrewwippler))

## [v0.1.3](https://github.com/walkamongus/realmd/tree/v0.1.3) (2016-05-24)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v0.1.2...v0.1.3)

## [v0.1.2](https://github.com/walkamongus/realmd/tree/v0.1.2) (2016-05-24)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v0.1.1...v0.1.2)

**Closed issues:**

- Uploading the keytab file [\#1](https://github.com/walkamongus/realmd/issues/1)

## [v0.1.1](https://github.com/walkamongus/realmd/tree/v0.1.1) (2015-12-16)
[Full Changelog](https://github.com/walkamongus/realmd/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/walkamongus/realmd/tree/v0.1.0) (2015-12-16)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*