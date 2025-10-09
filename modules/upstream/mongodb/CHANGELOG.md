# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v7.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v7.0.0) (2025-06-11)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v6.0.1...v7.0.0)

**Breaking changes:**

- Update default repo version to latest supported by OS [\#779](https://github.com/voxpupuli/puppet-mongodb/pull/779) ([h-haaks](https://github.com/h-haaks))
- remove EOL OSes [\#775](https://github.com/voxpupuli/puppet-mongodb/pull/775) ([h-haaks](https://github.com/h-haaks))

**Implemented enhancements:**

- Add Ubuntu 24.04 support [\#778](https://github.com/voxpupuli/puppet-mongodb/pull/778) ([h-haaks](https://github.com/h-haaks))
- Allow puppetlabs/apt 10.x [\#773](https://github.com/voxpupuli/puppet-mongodb/pull/773) ([smortex](https://github.com/smortex))
- metadata.json: Add OpenVox [\#770](https://github.com/voxpupuli/puppet-mongodb/pull/770) ([jstraw](https://github.com/jstraw))
- allow puppet/systemd 8.x [\#769](https://github.com/voxpupuli/puppet-mongodb/pull/769) ([jay7x](https://github.com/jay7x))

**Fixed bugs:**

- granting roles using role@db syntax does not allow db names containing "-" [\#771](https://github.com/voxpupuli/puppet-mongodb/issues/771)

**Closed issues:**

- Update default mongodb version to 7.x [\#754](https://github.com/voxpupuli/puppet-mongodb/issues/754)

**Merged pull requests:**

- README: fix spacing style [\#780](https://github.com/voxpupuli/puppet-mongodb/pull/780) ([kenyon](https://github.com/kenyon))
- Add MongoDB 8.x to integration tests [\#777](https://github.com/voxpupuli/puppet-mongodb/pull/777) ([h-haaks](https://github.com/h-haaks))
- remove tests on EOL MongoDB 5.x [\#776](https://github.com/voxpupuli/puppet-mongodb/pull/776) ([h-haaks](https://github.com/h-haaks))
- replace legacy facts in unit tests [\#774](https://github.com/voxpupuli/puppet-mongodb/pull/774) ([h-haaks](https://github.com/h-haaks))
- fix regex to allow database names to contain "-" in role@db syntax [\#772](https://github.com/voxpupuli/puppet-mongodb/pull/772) ([dermsd](https://github.com/dermsd))
- Fix secondary users on a replicaset being marked as changed [\#766](https://github.com/voxpupuli/puppet-mongodb/pull/766) ([stevenpost](https://github.com/stevenpost))

## [v6.0.1](https://github.com/voxpupuli/puppet-mongodb/tree/v6.0.1) (2024-05-07)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v6.0.0...v6.0.1)

**Fixed bugs:**

- Wrong "pidFilePath:" setting in `/etc/mongodb.conf` on Debian [\#647](https://github.com/voxpupuli/puppet-mongodb/issues/647)
- Backslashes in a password need to be escaped [\#760](https://github.com/voxpupuli/puppet-mongodb/pull/760) ([stevenpost](https://github.com/stevenpost))

**Closed issues:**

- Roadmap to get this module in better shape [\#696](https://github.com/voxpupuli/puppet-mongodb/issues/696)

## [v6.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v6.0.0) (2024-04-29)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v5.0.0...v6.0.0)

**Breaking changes:**

- Remove nojournal parameter; Cleanup journal management [\#730](https://github.com/voxpupuli/puppet-mongodb/pull/730) ([h-haaks](https://github.com/h-haaks))
- Provider cleanup [\#723](https://github.com/voxpupuli/puppet-mongodb/pull/723) ([stevenpost](https://github.com/stevenpost))
- Set default redhat dbpath to /var/lib/mongo [\#718](https://github.com/voxpupuli/puppet-mongodb/pull/718) ([h-haaks](https://github.com/h-haaks))
- Use keyring for apt repository; update dependency versions [\#713](https://github.com/voxpupuli/puppet-mongodb/pull/713) ([h-haaks](https://github.com/h-haaks))
- Move params to classes and hiera; Align defaults with supported versions [\#712](https://github.com/voxpupuli/puppet-mongodb/pull/712) ([h-haaks](https://github.com/h-haaks))

**Implemented enhancements:**

- update puppet-systemd upper bound to 8.0.0 [\#756](https://github.com/voxpupuli/puppet-mongodb/pull/756) ([TheMeier](https://github.com/TheMeier))
- Add OracleLinux support [\#748](https://github.com/voxpupuli/puppet-mongodb/pull/748) ([bastelfreak](https://github.com/bastelfreak))
- Add Rocky and AlmaLinux support [\#745](https://github.com/voxpupuli/puppet-mongodb/pull/745) ([h-haaks](https://github.com/h-haaks))
- feat: Add tls\_invalid\_certificates argument [\#742](https://github.com/voxpupuli/puppet-mongodb/pull/742) ([jouir](https://github.com/jouir))
- Use proper yaml for the mongod config [\#740](https://github.com/voxpupuli/puppet-mongodb/pull/740) ([h-haaks](https://github.com/h-haaks))
- Add RedHat/CentOS 9 support [\#738](https://github.com/voxpupuli/puppet-mongodb/pull/738) ([h-haaks](https://github.com/h-haaks))
- Add Debian 12 support [\#736](https://github.com/voxpupuli/puppet-mongodb/pull/736) ([h-haaks](https://github.com/h-haaks))
- Add mongodb 6.0 and 7.0 to acceptance testing [\#728](https://github.com/voxpupuli/puppet-mongodb/pull/728) ([h-haaks](https://github.com/h-haaks))
- Use  the mongosh command instead of the old mongo command [\#703](https://github.com/voxpupuli/puppet-mongodb/pull/703) ([stevenpost](https://github.com/stevenpost))
- Add Ubuntu 22.04 support [\#694](https://github.com/voxpupuli/puppet-mongodb/pull/694) ([zilchms](https://github.com/zilchms))

**Fixed bugs:**

- Full support for mongo 5.x on RedHat/CentOS [\#629](https://github.com/voxpupuli/puppet-mongodb/issues/629)
- Fix typo in is\_master fact [\#751](https://github.com/voxpupuli/puppet-mongodb/pull/751) ([h-haaks](https://github.com/h-haaks))
- Fix replset and sharding integration tests [\#743](https://github.com/voxpupuli/puppet-mongodb/pull/743) ([h-haaks](https://github.com/h-haaks))

**Closed issues:**

- Typo in is\_master fact [\#750](https://github.com/voxpupuli/puppet-mongodb/issues/750)
- Subsequent puppet runs fail on unauthenticated replicasets [\#731](https://github.com/voxpupuli/puppet-mongodb/issues/731)
- Default location for database files on RHEL variants is /var/lib/mongo [\#714](https://github.com/voxpupuli/puppet-mongodb/issues/714)
- Puppet 8x compatibility [\#684](https://github.com/voxpupuli/puppet-mongodb/issues/684)
- Stdlib IP Address Variable [\#674](https://github.com/voxpupuli/puppet-mongodb/issues/674)
- removed mongo cli in 6.0 is not compatible with outputs from new mongosh [\#648](https://github.com/voxpupuli/puppet-mongodb/issues/648)
- rs.initiate\(\) fails due to duplicated replicaset alive members  [\#565](https://github.com/voxpupuli/puppet-mongodb/issues/565)

**Merged pull requests:**

- Remove unsupported mongodb 4.4 from test matrix [\#758](https://github.com/voxpupuli/puppet-mongodb/pull/758) ([h-haaks](https://github.com/h-haaks))
- Link metadata for tested Oses [\#755](https://github.com/voxpupuli/puppet-mongodb/pull/755) ([h-haaks](https://github.com/h-haaks))
- Support for pure yaml in is\_master.rb [\#741](https://github.com/voxpupuli/puppet-mongodb/pull/741) ([h-haaks](https://github.com/h-haaks))
- Remove the retry mechanism from the provider [\#739](https://github.com/voxpupuli/puppet-mongodb/pull/739) ([stevenpost](https://github.com/stevenpost))
- Various documentation fixes [\#733](https://github.com/voxpupuli/puppet-mongodb/pull/733) ([stevenpost](https://github.com/stevenpost))
- Use ensure pruned to remove packages in acceptance tests [\#727](https://github.com/voxpupuli/puppet-mongodb/pull/727) ([h-haaks](https://github.com/h-haaks))
- Provider cleanup \(safe part\) [\#726](https://github.com/voxpupuli/puppet-mongodb/pull/726) ([stevenpost](https://github.com/stevenpost))
- Prefer connecting over localhost when possible [\#725](https://github.com/voxpupuli/puppet-mongodb/pull/725) ([stevenpost](https://github.com/stevenpost))
- Remove unused parameter [\#724](https://github.com/voxpupuli/puppet-mongodb/pull/724) ([stevenpost](https://github.com/stevenpost))
- Documentation update [\#722](https://github.com/voxpupuli/puppet-mongodb/pull/722) ([stevenpost](https://github.com/stevenpost))
- Support Suse enterprise repository [\#719](https://github.com/voxpupuli/puppet-mongodb/pull/719) ([h-haaks](https://github.com/h-haaks))
- Test supported repo versions with gha [\#716](https://github.com/voxpupuli/puppet-mongodb/pull/716) ([h-haaks](https://github.com/h-haaks))
- Debian 10 support should not be dropped yet [\#711](https://github.com/voxpupuli/puppet-mongodb/pull/711) ([h-haaks](https://github.com/h-haaks))
- Remove old version from template name [\#710](https://github.com/voxpupuli/puppet-mongodb/pull/710) ([stevenpost](https://github.com/stevenpost))
- Move documentation from README into the manifests [\#709](https://github.com/voxpupuli/puppet-mongodb/pull/709) ([stevenpost](https://github.com/stevenpost))
- Provider cleanup part2 [\#706](https://github.com/voxpupuli/puppet-mongodb/pull/706) ([stevenpost](https://github.com/stevenpost))

## [v5.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v5.0.0) (2024-03-19)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v4.2.0...v5.0.0)

**Breaking changes:**

- Drop Debian 10 support [\#704](https://github.com/voxpupuli/puppet-mongodb/pull/704) ([h-haaks](https://github.com/h-haaks))
- Use mongodb repo by default; require repo version \>= 4.4 [\#699](https://github.com/voxpupuli/puppet-mongodb/pull/699) ([h-haaks](https://github.com/h-haaks))
- Drop Ubuntu 18.04 support [\#693](https://github.com/voxpupuli/puppet-mongodb/pull/693) ([zilchms](https://github.com/zilchms))
- Drop EoL Puppet 6 [\#672](https://github.com/voxpupuli/puppet-mongodb/pull/672) ([traylenator](https://github.com/traylenator))
- Drop EoL Debian 9 [\#671](https://github.com/voxpupuli/puppet-mongodb/pull/671) ([traylenator](https://github.com/traylenator))
- Drop Puppet 6 support [\#669](https://github.com/voxpupuli/puppet-mongodb/pull/669) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- add redhat8, centos8  and debian11 support [\#702](https://github.com/voxpupuli/puppet-mongodb/pull/702) ([h-haaks](https://github.com/h-haaks))
- Provider cleanup [\#701](https://github.com/voxpupuli/puppet-mongodb/pull/701) ([stevenpost](https://github.com/stevenpost))
- Mongos as systemd service [\#698](https://github.com/voxpupuli/puppet-mongodb/pull/698) ([h-haaks](https://github.com/h-haaks))
- puppetlabs/apt: Allow 9.x [\#692](https://github.com/voxpupuli/puppet-mongodb/pull/692) ([zilchms](https://github.com/zilchms))
- bump systemd: \< 7.0.0 [\#687](https://github.com/voxpupuli/puppet-mongodb/pull/687) ([sandwitch](https://github.com/sandwitch))
- Set version defaults with hiera data [\#685](https://github.com/voxpupuli/puppet-mongodb/pull/685) ([traylenator](https://github.com/traylenator))
- Add Puppet 8 support [\#676](https://github.com/voxpupuli/puppet-mongodb/pull/676) ([bastelfreak](https://github.com/bastelfreak))
- puppetlabs/stdlib: Allow 9.x [\#675](https://github.com/voxpupuli/puppet-mongodb/pull/675) ([bastelfreak](https://github.com/bastelfreak))
- bump puppet/systemd to \< 5.0.0 [\#665](https://github.com/voxpupuli/puppet-mongodb/pull/665) ([jhoblitt](https://github.com/jhoblitt))
- New server::admin\_password\_hash parameter [\#659](https://github.com/voxpupuli/puppet-mongodb/pull/659) ([traylenator](https://github.com/traylenator))

**Fixed bugs:**

- Extra json on mongo output causing provider 'mongodb': 783: unexpected token at '{ [\#680](https://github.com/voxpupuli/puppet-mongodb/issues/680)
- add docs, doc stubs and descriptions to fix validate warnings [\#690](https://github.com/voxpupuli/puppet-mongodb/pull/690) ([zilchms](https://github.com/zilchms))
- Remove extra line causing errors: "Started a new thread for the timer service" [\#681](https://github.com/voxpupuli/puppet-mongodb/pull/681) ([xepa](https://github.com/xepa))
- Catch errors on database creation or destroy [\#663](https://github.com/voxpupuli/puppet-mongodb/pull/663) ([JvGinkel](https://github.com/JvGinkel))

## [v4.2.0](https://github.com/voxpupuli/puppet-mongodb/tree/v4.2.0) (2022-12-07)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v4.1.1...v4.2.0)

**Implemented enhancements:**

- Add TLS options [\#645](https://github.com/voxpupuli/puppet-mongodb/pull/645) ([poloz-lab](https://github.com/poloz-lab))
- SCRAM-SHA-256 support [\#643](https://github.com/voxpupuli/puppet-mongodb/pull/643) ([poloz-lab](https://github.com/poloz-lab))

**Fixed bugs:**

- Auth in mongod 3.6 [\#437](https://github.com/voxpupuli/puppet-mongodb/issues/437)
- mongodb\_user ignores `database` parameter when removing a user [\#644](https://github.com/voxpupuli/puppet-mongodb/pull/644) ([SeanHood](https://github.com/SeanHood))
- Fix ReplicaSet with Auth creation \(new error message to handle\) [\#632](https://github.com/voxpupuli/puppet-mongodb/pull/632) ([BDelacour](https://github.com/BDelacour))

## [v4.1.1](https://github.com/voxpupuli/puppet-mongodb/tree/v4.1.1) (2022-03-12)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v4.1.0...v4.1.1)

**Fixed bugs:**

- Do not manage the repository on RedHat when manage\_package\_repo is set to false [\#637](https://github.com/voxpupuli/puppet-mongodb/pull/637) ([fe80](https://github.com/fe80))

**Closed issues:**

- `mongodb::repo` is always include for some family [\#636](https://github.com/voxpupuli/puppet-mongodb/issues/636)

## [v4.1.0](https://github.com/voxpupuli/puppet-mongodb/tree/v4.1.0) (2021-10-28)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Add support for Suse Linux [\#624](https://github.com/voxpupuli/puppet-mongodb/pull/624) ([fbrehm](https://github.com/fbrehm))
- Add mongo 5.0 debian / ubuntu apt key [\#615](https://github.com/voxpupuli/puppet-mongodb/pull/615) ([xepa](https://github.com/xepa))

**Fixed bugs:**

- Run apt update before installing package [\#628](https://github.com/voxpupuli/puppet-mongodb/pull/628) ([malcyon](https://github.com/malcyon))

**Closed issues:**

- Fails to install on Ubuntu 20.04 [\#627](https://github.com/voxpupuli/puppet-mongodb/issues/627)
- Missing key for Apt for installing 5.0 mongo [\#614](https://github.com/voxpupuli/puppet-mongodb/issues/614)
- Error: Could not prefetch mongodb\_replset provider 'mongo': 765: unexpected token at 'WARNING: \) is deprecated and may be removed in the next major release. Please use secondaryOk\(\) [\#612](https://github.com/voxpupuli/puppet-mongodb/issues/612)
- 4.x version. Initialization of replset and user creation problem. [\#583](https://github.com/voxpupuli/puppet-mongodb/issues/583)

## [v4.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v4.0.0) (2021-09-03)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v3.1.0...v4.0.0)

**Breaking changes:**

- Drop Puppet 5/Add puppet 7 support [\#617](https://github.com/voxpupuli/puppet-mongodb/pull/617) ([root-expert](https://github.com/root-expert))
- Drop Ubuntu 16/Add Ubuntu 20 support [\#616](https://github.com/voxpupuli/puppet-mongodb/pull/616) ([root-expert](https://github.com/root-expert))

**Implemented enhancements:**

- Support managing selinux [\#413](https://github.com/voxpupuli/puppet-mongodb/issues/413)
- Add Debian 10 support [\#619](https://github.com/voxpupuli/puppet-mongodb/pull/619) ([root-expert](https://github.com/root-expert))
- Use Puppet-Datatype Sensitive for Passwords [\#611](https://github.com/voxpupuli/puppet-mongodb/pull/611) ([cocker-cc](https://github.com/cocker-cc))
- Change set\_parameter to be an array of strings [\#595](https://github.com/voxpupuli/puppet-mongodb/pull/595) ([ZloeSabo](https://github.com/ZloeSabo))
- Use rs.secondaryOk on versions that deprecated rs.slaveOk [\#594](https://github.com/voxpupuli/puppet-mongodb/pull/594) ([svenbs](https://github.com/svenbs))
- Add MongoDB 4.4 repository signing key. [\#592](https://github.com/voxpupuli/puppet-mongodb/pull/592) ([dhs-rec](https://github.com/dhs-rec))

**Fixed bugs:**

- Existence of /root/.mongorc.js triggers mongod restart [\#449](https://github.com/voxpupuli/puppet-mongodb/issues/449)
- Fix MongoDB installation on RedHat family [\#606](https://github.com/voxpupuli/puppet-mongodb/pull/606) ([hdep](https://github.com/hdep))
- Update mongodb-shard.conf.erb [\#591](https://github.com/voxpupuli/puppet-mongodb/pull/591) ([andreish](https://github.com/andreish))
- Fix mongorc.js file when authentication is not enabled. [\#590](https://github.com/voxpupuli/puppet-mongodb/pull/590) ([vladpetrus](https://github.com/vladpetrus))
- Fix digestPassword typo mongodb.rb [\#589](https://github.com/voxpupuli/puppet-mongodb/pull/589) ([covidium](https://github.com/covidium))

**Closed issues:**

- MongoDB 4.2.10 starts to emit warnings about slaveOk\(\) being deprecated, which breaks the module [\#596](https://github.com/voxpupuli/puppet-mongodb/issues/596)
- Can't use mongodb repository on debian 9 [\#529](https://github.com/voxpupuli/puppet-mongodb/issues/529)

**Merged pull requests:**

- puppet-lint: fix top\_scope\_facts warnings [\#621](https://github.com/voxpupuli/puppet-mongodb/pull/621) ([bastelfreak](https://github.com/bastelfreak))
- Allow stdlib 8.x and apt 8.x [\#620](https://github.com/voxpupuli/puppet-mongodb/pull/620) ([smortex](https://github.com/smortex))
- modulesync 3.0.0 & puppet-lint updates [\#586](https://github.com/voxpupuli/puppet-mongodb/pull/586) ([bastelfreak](https://github.com/bastelfreak))
- Describe disabling logpath to make syslog work [\#585](https://github.com/voxpupuli/puppet-mongodb/pull/585) ([lennartkoopmann](https://github.com/lennartkoopmann))
- Use voxpupuli-acceptance [\#580](https://github.com/voxpupuli/puppet-mongodb/pull/580) ([ekohl](https://github.com/ekohl))

## [v3.1.0](https://github.com/voxpupuli/puppet-mongodb/tree/v3.1.0) (2020-02-11)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- restrict opsmanager conf file permissions for better security [\#563](https://github.com/voxpupuli/puppet-mongodb/pull/563) ([FLiPp3r90](https://github.com/FLiPp3r90))
- rebased PR\#308 to allow other databases in the format 'role@db' for mongodb\_user [\#432](https://github.com/voxpupuli/puppet-mongodb/pull/432) ([pecharmin](https://github.com/pecharmin))

**Fixed bugs:**

- Wrong APT-key [\#546](https://github.com/voxpupuli/puppet-mongodb/issues/546)
- Mongo 4.0.x: unable to create user [\#525](https://github.com/voxpupuli/puppet-mongodb/issues/525)
- user creation idempotency issues [\#412](https://github.com/voxpupuli/puppet-mongodb/issues/412)
- fix\(is\_master-fact\): use --ssl if --sslPEMKeyFile or --sslCAFile is s… [\#573](https://github.com/voxpupuli/puppet-mongodb/pull/573) ([buchstabensalat](https://github.com/buchstabensalat))
- Fixed the problem: the user was not created for Mongodb 4.x [\#561](https://github.com/voxpupuli/puppet-mongodb/pull/561) ([identw](https://github.com/identw))
- Only create database and user when mongodb\_is\_master [\#558](https://github.com/voxpupuli/puppet-mongodb/pull/558) ([JvGinkel](https://github.com/JvGinkel))

**Closed issues:**

- mongo 3.x replicaset init failed  [\#554](https://github.com/voxpupuli/puppet-mongodb/issues/554)

**Merged pull requests:**

- Added keys for MongoDB 4.0 and 4.2. [\#557](https://github.com/voxpupuli/puppet-mongodb/pull/557) ([jgrancell](https://github.com/jgrancell))
- Refactor opsmanager handling [\#521](https://github.com/voxpupuli/puppet-mongodb/pull/521) ([ekohl](https://github.com/ekohl))

## [v3.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v3.0.0) (2019-05-21)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.4.1...v3.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#533](https://github.com/voxpupuli/puppet-mongodb/pull/533) ([bastelfreak](https://github.com/bastelfreak))
- Refactor client handling [\#520](https://github.com/voxpupuli/puppet-mongodb/pull/520) ([ekohl](https://github.com/ekohl))
- Refactor mongos handling [\#509](https://github.com/voxpupuli/puppet-mongodb/pull/509) ([ekohl](https://github.com/ekohl))
- Drop support for mongodb versions before 2.6 [\#504](https://github.com/voxpupuli/puppet-mongodb/pull/504) ([ekohl](https://github.com/ekohl))
- Drop EL6 support [\#503](https://github.com/voxpupuli/puppet-mongodb/pull/503) ([ekohl](https://github.com/ekohl))
- Remove 10gen repository support [\#497](https://github.com/voxpupuli/puppet-mongodb/pull/497) ([ekohl](https://github.com/ekohl))
- Move to Debian 9 and Ubuntu 16.04/18.04 [\#494](https://github.com/voxpupuli/puppet-mongodb/pull/494) ([ekohl](https://github.com/ekohl))
- Remove init.pp [\#493](https://github.com/voxpupuli/puppet-mongodb/pull/493) ([ekohl](https://github.com/ekohl))

**Implemented enhancements:**

- Deprecate \(and then remove\) 10gen requirement/pieces [\#416](https://github.com/voxpupuli/puppet-mongodb/issues/416)
- support percona mongodb version output [\#530](https://github.com/voxpupuli/puppet-mongodb/pull/530) ([h0tw1r3](https://github.com/h0tw1r3))
- Add aptkey\_options parameter to mongodb::repo class [\#524](https://github.com/voxpupuli/puppet-mongodb/pull/524) ([JvGinkel](https://github.com/JvGinkel))
- Set database permissions to 0750 [\#511](https://github.com/voxpupuli/puppet-mongodb/pull/511) ([ekohl](https://github.com/ekohl))
- Convert mongodb\_password into a Puppet 4 function [\#502](https://github.com/voxpupuli/puppet-mongodb/pull/502) ([ekohl](https://github.com/ekohl))
- Add new classes for installing Ops Manager on a target machine. [\#500](https://github.com/voxpupuli/puppet-mongodb/pull/500) ([claycogg](https://github.com/claycogg))

**Fixed bugs:**

- Fix undefined local variable or method `n' [\#537](https://github.com/voxpupuli/puppet-mongodb/pull/537) ([FunFR](https://github.com/FunFR))
- Fix for MongoDB v4 Replica Set initialization [\#535](https://github.com/voxpupuli/puppet-mongodb/pull/535) ([radupantiru](https://github.com/radupantiru))
- Fix a dependency cycle caused by Apt::Source from puppetlabs-apt 6.3.0 [\#528](https://github.com/voxpupuli/puppet-mongodb/pull/528) ([thaiphv](https://github.com/thaiphv))

**Merged pull requests:**

- Allow `puppetlabs/stdlib` 6.x [\#538](https://github.com/voxpupuli/puppet-mongodb/pull/538) ([alexjfisher](https://github.com/alexjfisher))
- Allow puppetlabs/apt 7.x [\#536](https://github.com/voxpupuli/puppet-mongodb/pull/536) ([dhoppe](https://github.com/dhoppe))
- \#512: Current 'sharding.pp' example typo [\#513](https://github.com/voxpupuli/puppet-mongodb/pull/513) ([jeff1evesque](https://github.com/jeff1evesque))
- Remove old nodesets [\#510](https://github.com/voxpupuli/puppet-mongodb/pull/510) ([ekohl](https://github.com/ekohl))
- Refactor mongos handling [\#508](https://github.com/voxpupuli/puppet-mongodb/pull/508) ([ekohl](https://github.com/ekohl))
- Deduplicate & update params.pp [\#506](https://github.com/voxpupuli/puppet-mongodb/pull/506) ([ekohl](https://github.com/ekohl))
- Clean up coding styles [\#505](https://github.com/voxpupuli/puppet-mongodb/pull/505) ([ekohl](https://github.com/ekohl))
- Rewrite mocking and stubbing to only rspec [\#496](https://github.com/voxpupuli/puppet-mongodb/pull/496) ([ekohl](https://github.com/ekohl))
- Refactor spec testing to not test private classes [\#495](https://github.com/voxpupuli/puppet-mongodb/pull/495) ([ekohl](https://github.com/ekohl))
- Major cleanup to get the acceptance tests working [\#491](https://github.com/voxpupuli/puppet-mongodb/pull/491) ([ekohl](https://github.com/ekohl))

## [v2.4.1](https://github.com/voxpupuli/puppet-mongodb/tree/v2.4.1) (2018-10-08)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.4.0...v2.4.1)

**Fixed bugs:**

- Revert "Fallback to monogb version from fact if no explicit version got provided" [\#498](https://github.com/voxpupuli/puppet-mongodb/pull/498) ([ekohl](https://github.com/ekohl))
- Also autorequire mongod service in types [\#492](https://github.com/voxpupuli/puppet-mongodb/pull/492) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- invalid byte sequence in US-ASCII [\#426](https://github.com/voxpupuli/puppet-mongodb/issues/426)

## [v2.4.0](https://github.com/voxpupuli/puppet-mongodb/tree/v2.4.0) (2018-10-05)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.3.0...v2.4.0)

**Fixed bugs:**

- Fallback to monogb version from fact if no explicit version got provided [\#485](https://github.com/voxpupuli/puppet-mongodb/pull/485) ([fbrehm](https://github.com/fbrehm))

**Merged pull requests:**

- modulesync 2.1.0, allow puppet 6.x and puppetlabs/apt 6.x [\#490](https://github.com/voxpupuli/puppet-mongodb/pull/490) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#484](https://github.com/voxpupuli/puppet-mongodb/pull/484) ([bastelfreak](https://github.com/bastelfreak))
- add gsub to replace invalid json values with a 1 [\#468](https://github.com/voxpupuli/puppet-mongodb/pull/468) ([TomRitserveldt](https://github.com/TomRitserveldt))
- add rs.slaveOk to run before the getDBs call [\#446](https://github.com/voxpupuli/puppet-mongodb/pull/446) ([TomRitserveldt](https://github.com/TomRitserveldt))

## [v2.3.0](https://github.com/voxpupuli/puppet-mongodb/tree/v2.3.0) (2018-08-20)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.2.2...v2.3.0)

**Implemented enhancements:**

- Add advanced replica set configuration [\#478](https://github.com/voxpupuli/puppet-mongodb/pull/478) ([DeathBorn](https://github.com/DeathBorn))

**Merged pull requests:**

- allow puppetlabs/apt 5.x [\#481](https://github.com/voxpupuli/puppet-mongodb/pull/481) ([bastelfreak](https://github.com/bastelfreak))

## [v2.2.2](https://github.com/voxpupuli/puppet-mongodb/tree/v2.2.2) (2018-07-16)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.2.1...v2.2.2)

**Fixed bugs:**

- Could not find scope for mongodb::params [\#428](https://github.com/voxpupuli/puppet-mongodb/issues/428)
- Fix a circular loading issue with mongodb::repo [\#474](https://github.com/voxpupuli/puppet-mongodb/pull/474) ([ekohl](https://github.com/ekohl))

## [v2.2.1](https://github.com/voxpupuli/puppet-mongodb/tree/v2.2.1) (2018-06-25)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.2.0...v2.2.1)

**Fixed bugs:**

- Undefined method 'get\_config\_options' in is\_master.rb [\#471](https://github.com/voxpupuli/puppet-mongodb/issues/471)
- Use the correct function in is\_master fact [\#472](https://github.com/voxpupuli/puppet-mongodb/pull/472) ([ekohl](https://github.com/ekohl))

## [v2.2.0](https://github.com/voxpupuli/puppet-mongodb/tree/v2.2.0) (2018-06-16)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.1.2...v2.2.0)

**Implemented enhancements:**

- Repo for version 3.6 is using wrong key. [\#465](https://github.com/voxpupuli/puppet-mongodb/issues/465)
- This will add the correct apt key for version 3.6. [\#466](https://github.com/voxpupuli/puppet-mongodb/pull/466) ([noni73](https://github.com/noni73))

**Fixed bugs:**

- Handle non-existing config file [\#469](https://github.com/voxpupuli/puppet-mongodb/pull/469) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- Remove docker nodesets [\#463](https://github.com/voxpupuli/puppet-mongodb/pull/463) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#462](https://github.com/voxpupuli/puppet-mongodb/pull/462) ([bastelfreak](https://github.com/bastelfreak))

## [v2.1.2](https://github.com/voxpupuli/puppet-mongodb/tree/v2.1.2) (2018-03-28)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.1.1...v2.1.2)

**Fixed bugs:**

- Notice on every run for password\_hash [\#425](https://github.com/voxpupuli/puppet-mongodb/issues/425)
- Add check if scram credentials are insync with hash [\#455](https://github.com/voxpupuli/puppet-mongodb/pull/455) ([ctrox](https://github.com/ctrox))

## [v2.1.1](https://github.com/voxpupuli/puppet-mongodb/tree/v2.1.1) (2018-03-27)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.1.0...v2.1.1)

**Fixed bugs:**

- Bump stdlib 4.4.0-\>4.13.0 [\#450](https://github.com/voxpupuli/puppet-mongodb/pull/450) ([dupgit](https://github.com/dupgit))

**Closed issues:**

- Fact "mongodb\_is\_master" fails on mongodb clients [\#441](https://github.com/voxpupuli/puppet-mongodb/issues/441)

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#452](https://github.com/voxpupuli/puppet-mongodb/pull/452) ([bastelfreak](https://github.com/bastelfreak))

## [v2.1.0](https://github.com/voxpupuli/puppet-mongodb/tree/v2.1.0) (2018-02-27)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- Allow setting of net.ssl.mode [\#300](https://github.com/voxpupuli/puppet-mongodb/pull/300) ([bond-os](https://github.com/bond-os))

**Fixed bugs:**

- Fixed changing user password with MongoDB 2.6 [\#442](https://github.com/voxpupuli/puppet-mongodb/pull/442) ([webcompas](https://github.com/webcompas))
- Fix password changing issue voxpupuli/puppet-mongodb\#438  [\#440](https://github.com/voxpupuli/puppet-mongodb/pull/440) ([webcompas](https://github.com/webcompas))
- Add a retry block when hosts are added to replset [\#436](https://github.com/voxpupuli/puppet-mongodb/pull/436) ([pkilambi](https://github.com/pkilambi))

**Closed issues:**

- Changing a user's password doesn't work [\#438](https://github.com/voxpupuli/puppet-mongodb/issues/438)

## [v2.0.0](https://github.com/voxpupuli/puppet-mongodb/tree/v2.0.0) (2018-01-04)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/v1.1.0...v2.0.0)

**Breaking changes:**

- Add Data Types and remove deprecated parameters [\#406](https://github.com/voxpupuli/puppet-mongodb/pull/406) ([wyardley](https://github.com/wyardley))

**Implemented enhancements:**

- Replace anchors with contain [\#420](https://github.com/voxpupuli/puppet-mongodb/pull/420) ([ekohl](https://github.com/ekohl))
- Simplify the client class [\#419](https://github.com/voxpupuli/puppet-mongodb/pull/419) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- apt-transport-https required on Ubuntu when installing version \>= 3.0.0. [\#417](https://github.com/voxpupuli/puppet-mongodb/issues/417)
- Fix compilation failures on RHEL when `manage_package => true` [\#431](https://github.com/voxpupuli/puppet-mongodb/pull/431) ([fatmcgav](https://github.com/fatmcgav))

**Closed issues:**

- "Unknown variable 'mongodb::params::journal'" error when 'manage\_package =\> true' [\#430](https://github.com/voxpupuli/puppet-mongodb/issues/430)
- package version override broken with yum [\#415](https://github.com/voxpupuli/puppet-mongodb/issues/415)
- create admin and repl set fail with password [\#414](https://github.com/voxpupuli/puppet-mongodb/issues/414)
- 10gen repo handling doesn't work [\#101](https://github.com/voxpupuli/puppet-mongodb/issues/101)

**Merged pull requests:**

- Set types for mongodb::db [\#421](https://github.com/voxpupuli/puppet-mongodb/pull/421) ([ekohl](https://github.com/ekohl))
- Allow bind\_ip to be an IP or array of IPs. Add data types for a coupl… [\#411](https://github.com/voxpupuli/puppet-mongodb/pull/411) ([wyardley](https://github.com/wyardley))
- Some minor initial fixes for acceptance tests [\#409](https://github.com/voxpupuli/puppet-mongodb/pull/409) ([wyardley](https://github.com/wyardley))
- Use raise Puppet::Error instead of Puppet.fail\(\) [\#408](https://github.com/voxpupuli/puppet-mongodb/pull/408) ([wyardley](https://github.com/wyardley))
- fix for rubocop issues introduced in 9e2c [\#407](https://github.com/voxpupuli/puppet-mongodb/pull/407) ([wyardley](https://github.com/wyardley))
- Autorequire mongodb\_database for mongodb\_user [\#394](https://github.com/voxpupuli/puppet-mongodb/pull/394) ([ekohl](https://github.com/ekohl))
- Set dbpath\_fix to false by default [\#347](https://github.com/voxpupuli/puppet-mongodb/pull/347) ([mwhahaha](https://github.com/mwhahaha))
- Fixed: create database admin only if service\_ensure is true. [\#240](https://github.com/voxpupuli/puppet-mongodb/pull/240) ([pcheliniy](https://github.com/pcheliniy))

## [v1.1.0](https://github.com/voxpupuli/puppet-mongodb/tree/v1.1.0) (2017-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-mongodb/compare/1.0.0...v1.1.0)

**Implemented enhancements:**

- Allow user-supplied configuration data [\#389](https://github.com/voxpupuli/puppet-mongodb/pull/389) ([blackophelia](https://github.com/blackophelia))
- MODULES-5483: Auth and FQDN certs =\> Fail [\#369](https://github.com/voxpupuli/puppet-mongodb/pull/369) ([ThoTischner](https://github.com/ThoTischner))

**Fixed bugs:**

- Fix password on admin db [\#393](https://github.com/voxpupuli/puppet-mongodb/pull/393) ([benohara](https://github.com/benohara))
- fix issue MODULES-5545 [\#390](https://github.com/voxpupuli/puppet-mongodb/pull/390) ([bovy89](https://github.com/bovy89))
- mongodb no longer provides the stable link [\#361](https://github.com/voxpupuli/puppet-mongodb/pull/361) ([attachmentgenie](https://github.com/attachmentgenie))

**Closed issues:**

- Can't change dbpath on Debian Stretch / Puppet5 with Hiera [\#398](https://github.com/voxpupuli/puppet-mongodb/issues/398)

**Merged pull requests:**

- Release 1.1.0 [\#403](https://github.com/voxpupuli/puppet-mongodb/pull/403) ([wyardley](https://github.com/wyardley))
- correct spelling mistake [\#395](https://github.com/voxpupuli/puppet-mongodb/pull/395) ([EdwardBetts](https://github.com/EdwardBetts))
- \(maint\) modulesync 915cde70e20 [\#388](https://github.com/voxpupuli/puppet-mongodb/pull/388) ([glennsarti](https://github.com/glennsarti))
- \(MODULES-5187\) mysnc puppet 5 and ruby 2.4 [\#387](https://github.com/voxpupuli/puppet-mongodb/pull/387) ([eputnam](https://github.com/eputnam))
- Update README.md [\#386](https://github.com/voxpupuli/puppet-mongodb/pull/386) ([LasseRafn](https://github.com/LasseRafn))
- Release 1.0.0 mergeback [\#384](https://github.com/voxpupuli/puppet-mongodb/pull/384) ([eputnam](https://github.com/eputnam))
- Only check if master if mongod installed [\#314](https://github.com/voxpupuli/puppet-mongodb/pull/314) ([benohara](https://github.com/benohara))

## 1.0.0 (2017-06-30)
### Summary
Major release removing Puppet 3 support.

#### Added
- `ssl_weak_cert` param in `mongodb::server` type
- `system_logrotate` param in `mongodb`, `mongodb::server`, and `mongodb::server::config`
- `handle_creds` to handle credentials outside of Puppet ([MODULES-1754](https://tickets.puppet.com/browse/MODULES-1754))
- `sslMode` when SSL is used
- ability to use unencrypted passwords

#### Changed
- **lower bound of Puppet requirement to 4.7.0**
- use of `sslMode` to `sslOnNormalPorts` to determine if SSL is enabled

#### Fixed
- `database` property in `mongodb_user` to allow hyphens ([MODULES-4444](https://tickets.puppet.com/browse/MODULES-4444))
- gsub pattern for `is_master` fact
- `mongodb_version` fact
- selinux dbpath contexts in `mongodb::server::config`
- Debian-based repo paths
- `$pidfilepath` for Debian
- syntax error in net.ipv6 configuration option
- spec failure caused by Puppet 5
- is_master in mongodb provider

## Unsupported Release [0.17.0]
### Summary
Adding features to improve spec testing, and added ability to manage pidfile creation

#### Fixed
- gettext and spec.opts
- msync Gemfile for 1.0 frozen strings ([MODULES-3631](https://tickets.puppet.com/browse/MODULES-3631))
- MongoDB 3.12 creates pid file and checks in init script ([MODULES-3956](https://tickets.puppet.com/browse/MODULES-3956))
- gemfile template to be identical ([MODULES-3704](https://tickets.puppet.com/browse/MODULES-3704))
- deprecation errors

## Unsupported Release [0.16.0]
### Summary
We fixed a critical bug where we lost idempotency in 0.15.0. The patch that fix
this problem will be part of this release.

#### Fixed
- Recursively manage only user/group for dbpath

## Unsupported Release [0.15.0]
### Summary
The addition of several new functional features which will help with management and multiple bug fixes.

#### Added
- Added ability to set PID file mode.
- Recursively manage the contents of dbpath directory.
- Now alllows custom templates.
- Addition of mongo listen port before creating facter.

#### Fixed
- Now allows hyphens in database names.
- Now converts MongoDB ObjectID objects to generic JSON.
- Use the same regex that the mongodb provider does when correcting for ObjectID values in the isMaster response.
- Fixes to ensure that the auth property for config is parsed correctly.
- Now checks if mongo is up before evaluating is_master fact.

## Unsupported Release [0.14.0]
### Summary
This breaking release increases the lower bound of the puppetlabs-apt dependency to the 2.x series of apt and puppetlabs-stdlib to >= 4.4.0. The operating system metadata is also updated to reflect modern systems.

#### Added
- Add `mongodb_is_master` fact
- Add `mongodb::db::db_name` parameter for exported resource deduplication
- Add Debian 8 compatibility
- Add Ubuntu 14.04 compatibility
- Add Ubuntu 16.04 compatibility
- Add puppet 3.x 4.x compatibility metadata

#### Changed
- Increase apt lower dependency to >= 2.1.0
- Increase stdlib lower dependency to >= 4.4.0
- Drop RHEL & Centos 5
- Drop Debian 6
- Drop Ubuntu 10.04

#### Fixed
- Catch unconfigured replset configuration queries
- Fix timestamp and other javascript object removal
- Correct permissions on .mongorc.js to 600

## Unsupported Release [0.13.0]
### Summary
Adds several new large features, including the support of mongodb 3.x. Also applies numerous bugfixes, mainly around fixing errors being thrown and syntax issues.

#### Added
- Adds mongodb_version fact.
- Add mongodb 3.x.
- Update to current msync configs.
- Now ensures that the pidfile exists and is writable.
- Simplified configuration parsing.
- Made argument handling more extensible.
- Added SSL support.
- Made ssl_ca optional when using SSL.
- Added $maxconns to mongodb::server::config.
- Added Suse to operating systems.

#### Fixed
- Removes empty lines between doc and definition.
- Fix when using admin params : catalog: Found 1 dependency cycle: issue.
- Some syntax error fixes.
- Cleaned up provider formatting.
- Parse NumberLong data type from mongodb outputs to generate valid json.
- Checks if $version is defined before versioncmp.
- Fixed deprecation warning for use of configtimeout.

## Unsupported Release [0.12.0]
### Summary
There are a number of bugfixes and features added in this release including, mongo db 3 engine support, ipv6 support and repo and yum improvements.

#### Added
- Distinguish between repo and package mgmt
- Immplement retries for MongoDB shell commands
- Initiate replica set creation from localhost if auth is enabled
- Added specific service provider for Debian
- mongo db 3 engine selection support
- added an option to set a custom repository location
- Improve support for MongoDB authentication and replicaset
- Add yum proxy options
- Enable IPv6 in mongodb provider

#### Fixed
- Fix mongodb_user username => name
- ensure that the client install does not start before the repo setup
- Fix replset not working on mongo 3.x
- Prealloc setting needs to be negated
- Add mongoDB >=3.x new yum repo location
- Add pidfilepath to globals when used in params
- Normalize spacing in template
- Switch to comparing current roles value with @property
- Fix versioncmp when version is undef
- Do not add blank parameter in ipv4
- Apply module sync

## Unsupported Release [0.11.0]
### Summary

#### Added
- arbiter support to to `mongodb_replset`
- `mongod_service_manage`, `mongos_service_manage`, and `ipv6` to `mongodb::globals`
- `service_manage`, `unitxsocketprefix`, `pidfilepath`, `logpath`, `fork`, `bind_ip`, `port`, and `restart` to `mongodb::mongos` class
- `key`, `ipv6`, `service_manage`, and `restart` to `mongodb::server` class
- Allow mongodb\_conn\_validator to take an array of nodes via composite namevar

#### Fixed
- Update to long apt repo key and bump compatibility to include apt 2
- Fix `nohttpinterface` on >= 2.6
- Fix connection validation when bind\_ip is 0.0.0.0
- Fix mongodb\_conn\_validator to use default port in shard mode

## Unsupported Release [0.10.0]
### Summary

This release adds a number of significant features and several bug fixes.

#### Added
- Adds support for sharding
- Adds support for RHEL 7
- Adds rudimentary support for SSL configuration
- Adds support for the enterprise repository

#### Fixed
- Fixes support for running on non-default ports
- Fixes the idempotency of password setting (for mongo 2.6)

## Unsupported Release [0.9.0]
### Summary

This release has a number of new parameters, support for 2.6, improved providers, and several bugfixes.

#### Added
- New parameters: `mongodb::globals`
  - `$service_ensure`
  - `$service_enable`
- New parameters: `mongodb`
  - `$quiet`
- New parameters: `mongodb::server`
  - `$service_ensure`
  - `$service_enable`
  - `$quiet`
  - `$config_content`
- Support for mongodb 2.6
- Reimplement `mongodb_user` and `mongodb_database` provider
- Added `mongodb_conn_validator` type

#### Fixed
- Use hkp for the apt keyserver
- Fix mongodb database existence check
- Fix `$server_package_name` problem (MODULES-690)
- Make sure `pidfilepath` doesn't have any spaces
- Providers need the client command before they can work (MODULES-1285)

## Unsupported Release [0.8.0]
### Summary

This feature features a rewritten mongodb_replset{} provider, includes several
important bugfixes, ruby 1.8 support, and two new features.

#### Added
- Rewritten mongodb_replset{}, featuring puppet resource support, prefetching,
and flushing.
- Add Ruby 1.8 compatibility.
- Adds `syslog`, allowing you to configure mongodb to send all logging to the hosts syslog.
- Add mongodb::replset, a wrapper class for hiera users.
- Improved testing!

#### Fixed
- Fixes the package names to work since 10gen renamed them again.
- Fix provider name in the README.
- Disallow `nojournal` and `journal` to be set at the same time.
- Changed - to = for versioned install on Ubuntu.

## Unsupported Release [0.7.0]
### Summary

Added Replica Set Type and Provider

## Unsupported Release [0.6.0]
### Summary

Added support for installing MongoDB client on
RHEL family systems.

## Unsupported Release [0.5.0]
### Summary

Added types for providers for Mongo users and databases.

## Unsupported Release [0.4.0]

Major refactoring of the MongoDB module. Includes a new 'mongodb::globals'
that consolidates many shared parameters into one location. This is an
API-breaking release in anticipation of a 1.0 release.

## Unsupported Release [0.3.0]
### Summary

Adds a number of parameters and fixes some platform
specific bugs in module deployment.

## Unsupported Release [0.2.0]
### Summary

This release fixes a duplicate parameter.

#### Fixed
- Fix a duplicated parameter.

## Unsupported Release [0.1.0]
- Add support for RHEL/CentOS
- Change default mongodb install location to OS repo

## Unsupported Release [0.0.2]
- Fix Modulefile typo.
- Remove repo pin.
- Update spec tests and add travis support.

## Unsupported Release [0.0.1]
- Initial Release.

[1.0.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.17.0...1.0.0
[0.17.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.16.0...0.17.0
[0.16.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.15.0...0.16.0
[0.15.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.14.0...0.15.0
[0.14.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.13.0...0.14.0
[0.13.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.12.0...0.13.0
[0.12.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.11.0...0.12.0
[0.11.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.10.0...0.11.0
[0.10.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.9.0...0.10.0
[0.9.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.8.0...0.9.0
[0.8.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.0.2...0.1.0
[0.0.2]: https://github.com/puppetlabs/puppetlabs-mongodb/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/puppetlabs/puppetlabs-mongodb/tree/0.0.1


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
