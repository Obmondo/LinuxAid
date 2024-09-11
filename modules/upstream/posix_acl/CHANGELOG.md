# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v0.1.1](https://github.com/voxpupuli/puppet-posix_acl/tree/v0.1.1) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- modulesync 2.2.0 and allow puppet 6.x [\#53](https://github.com/voxpupuli/puppet-posix_acl/pull/53) ([bastelfreak](https://github.com/bastelfreak))

## [v0.1.0](https://github.com/voxpupuli/puppet-posix_acl/tree/v0.1.0) (2018-07-16)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.5...v0.1.0)

**Implemented enhancements:**

- Move to Vox Pupuli [\#29](https://github.com/voxpupuli/puppet-posix_acl/issues/29)

**Merged pull requests:**

- Remove docker nodesets [\#47](https://github.com/voxpupuli/puppet-posix_acl/pull/47) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#46](https://github.com/voxpupuli/puppet-posix_acl/pull/46) ([bastelfreak](https://github.com/bastelfreak))
- Rubocop: Fix Style/PredicateName [\#42](https://github.com/voxpupuli/puppet-posix_acl/pull/42) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop: Fix Style/GuardClause [\#41](https://github.com/voxpupuli/puppet-posix_acl/pull/41) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop: Fix Lint/UselessAssignment [\#40](https://github.com/voxpupuli/puppet-posix_acl/pull/40) ([alexjfisher](https://github.com/alexjfisher))
- Rubocop auto fixes [\#39](https://github.com/voxpupuli/puppet-posix_acl/pull/39) ([alexjfisher](https://github.com/alexjfisher))
- Fix metadata and add LICENSE file [\#36](https://github.com/voxpupuli/puppet-posix_acl/pull/36) ([alexjfisher](https://github.com/alexjfisher))
- remove ruby 1.9.3 support [\#35](https://github.com/voxpupuli/puppet-posix_acl/pull/35) ([dobbymoodge](https://github.com/dobbymoodge))

## [0.0.5](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.5) (2017-12-12)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.4...0.0.5)

## [0.0.4](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.4) (2017-12-12)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/0.0.3...0.0.4)

**Fixed bugs:**

- module name conflict [\#26](https://github.com/voxpupuli/puppet-posix_acl/issues/26)

**Closed issues:**

- Race condition with non existing file and recursemode =\> deep [\#22](https://github.com/voxpupuli/puppet-posix_acl/issues/22)
- Publish to the forge [\#21](https://github.com/voxpupuli/puppet-posix_acl/issues/21)

**Merged pull requests:**

- Time to deprecate Ruby 1.8.7 support [\#31](https://github.com/voxpupuli/puppet-posix_acl/pull/31) ([dobbymoodge](https://github.com/dobbymoodge))
- Fixes ACL's with spaces [\#30](https://github.com/voxpupuli/puppet-posix_acl/pull/30) ([i1tech](https://github.com/i1tech))
- fix another Ruby error when the file doesn't exist yet [\#28](https://github.com/voxpupuli/puppet-posix_acl/pull/28) ([tequeter](https://github.com/tequeter))
- use inspect instead of join to stringify arrays [\#27](https://github.com/voxpupuli/puppet-posix_acl/pull/27) ([tequeter](https://github.com/tequeter))
- Do not downcase acl group/user names when checking for insync?. [\#25](https://github.com/voxpupuli/puppet-posix_acl/pull/25) ([tdevelioglu](https://github.com/tdevelioglu))
- Check if a path exists before calling getfacl [\#23](https://github.com/voxpupuli/puppet-posix_acl/pull/23) ([roidelapluie](https://github.com/roidelapluie))

## [0.0.3](https://github.com/voxpupuli/puppet-posix_acl/tree/0.0.3) (2016-01-13)

[Full Changelog](https://github.com/voxpupuli/puppet-posix_acl/compare/650e19723054c74baa662d3f1589398550524b33...0.0.3)

**Closed issues:**

- Accept short acls. [\#4](https://github.com/voxpupuli/puppet-posix_acl/issues/4)

**Merged pull requests:**

- Switch from Modulefile to metadata.json [\#20](https://github.com/voxpupuli/puppet-posix_acl/pull/20) ([roidelapluie](https://github.com/roidelapluie))
- Fix defaults: behaviour [\#19](https://github.com/voxpupuli/puppet-posix_acl/pull/19) ([roidelapluie](https://github.com/roidelapluie))
- Add autorequire on parent ACL [\#18](https://github.com/voxpupuli/puppet-posix_acl/pull/18) ([roidelapluie](https://github.com/roidelapluie))
- Fix ruby 1.8.7 quirks [\#17](https://github.com/voxpupuli/puppet-posix_acl/pull/17) ([dobbymoodge](https://github.com/dobbymoodge))
- Better support for 'deep' recursive acls [\#15](https://github.com/voxpupuli/puppet-posix_acl/pull/15) ([roidelapluie](https://github.com/roidelapluie))
- Adds space around operators in ternary expressions [\#14](https://github.com/voxpupuli/puppet-posix_acl/pull/14) ([dobbymoodge](https://github.com/dobbymoodge))
- Add recursemode parameter to apply ACLs recursively [\#13](https://github.com/voxpupuli/puppet-posix_acl/pull/13) ([dobbymoodge](https://github.com/dobbymoodge))
- Add the Puppetlabs Skeleton for testing [\#11](https://github.com/voxpupuli/puppet-posix_acl/pull/11) ([roidelapluie](https://github.com/roidelapluie))
- Drop duplicate ACL's. [\#10](https://github.com/voxpupuli/puppet-posix_acl/pull/10) ([kevincox](https://github.com/kevincox))
- Update sync [\#7](https://github.com/voxpupuli/puppet-posix_acl/pull/7) ([mwoodson](https://github.com/mwoodson))
- Normalize ACL's. [\#5](https://github.com/voxpupuli/puppet-posix_acl/pull/5) ([kevincox](https://github.com/kevincox))
- Make posixacl the default for the redhat family [\#3](https://github.com/voxpupuli/puppet-posix_acl/pull/3) ([nhemingway](https://github.com/nhemingway))
- Add a acl::requirements class [\#2](https://github.com/voxpupuli/puppet-posix_acl/pull/2) ([duritong](https://github.com/duritong))
- Fix typo and make Modulefile validate by puppet module tool [\#1](https://github.com/voxpupuli/puppet-posix_acl/pull/1) ([carlossg](https://github.com/carlossg))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
