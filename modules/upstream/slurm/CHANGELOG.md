Changelog
=========


(unreleased)
------------
- Merge tag 'v1.5.4' into devel. [Mike Massonnet]

  v1.5.4
- Update Gemfile (due to rake version:bump:patch) [Mike Massonnet]


v1.5.4 (2025-10-27)
-------------------
- Merge branch 'release/1.5.4' into production. [Mike Massonnet]
- Bump to version '1.5.4' [Mike Massonnet]
- Update Gemfile (due to rake version:bump:patch) [Mike Massonnet]
- Merge pull request #88 from ULHPC/m8t/minor_fixes. [Mike Massonnet]

  Short cleanup:
  - no need to download pmix sources when not building from source
  - Fix setting key s/AcctGatherInfinibandType/AcctGatherInterconnectType/ (Since Slurm 20)
  - And also its value s/acct_gather_infiniband/acct_gather_interconnect/ (Since Slurm 17.11)
  - Permit customization of slurmdbd listening port
- [templates/slurm.conf] Use preferred setting
  AcctGatherInterconnectType. [Mike Massonnet]

  Starting Slurm 20 the documentation started to refer to the prefered
  setting AcctGatherInterconnectType instead of AcctGatherInfinibandType.

  https://github.com/SchedMD/slurm/commit/d2f1729f1d297ed1b2808bfa850076c5e135aa44

  AcctGatherInfinibandType is still supported for backward compatibility.

  Accepted values are:
  - none
  - acct_gather_interconnect/ofed
  - acct_gather_interconnect/sysfs

  Plugin type acct_gather_interconnect replaces acct_gather_infiniband.
  This has been replaced since Slurm 17.11.
- [templates/slurmdbd.conf] DbdPort setting is customizable. [Mike
  Massonnet]
- [manifests/params] Update comment with acceptable values for
  PrivateData. [Mike Massonnet]

  https://slurm.schedmd.com/slurmdbd.conf.html#OPT_PrivateData
- [templates/slurm.conf] Minor typo (parameters are case insensitive)
  [Mike Massonnet]
- [manifests/pmix] No need to download source when do_build is false.
  [Mike Massonnet]
- [docs] Fix link to RTD management. [Mike Massonnet]
- Update Gemfile. [Hyacinthe Cartiaux]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.5.3' into devel. [Hyacinthe Cartiaux]

  v1.5.3


v1.5.3 (2025-08-26)
-------------------
- Merge branch 'release/1.5.3' into production. [Hyacinthe Cartiaux]
- Bump to version '1.5.3' [Hyacinthe Cartiaux]
- Update ruby environment. [Hyacinthe Cartiaux]
- Merge pull request #87 from uvNikita/rebootprogram. [Hyacinthe
  Cartiaux]

  Add "RebootProgram" parameter
- Add "RebootProgram" parameter. [Nikita Uvarov]
- Merge pull request #86 from ULHPC/dependabot/bundler/thor-1.4.0.
  [Hyacinthe Cartiaux]

  Bump thor from 1.3.2 to 1.4.0
- Bump thor from 1.3.2 to 1.4.0. [dependabot[bot]]

  Bumps [thor](https://github.com/rails/thor) from 1.3.2 to 1.4.0.
  - [Release notes](https://github.com/rails/thor/releases)
  - [Commits](https://github.com/rails/thor/compare/v1.3.2...v1.4.0)

  ---
  updated-dependencies:
  - dependency-name: thor
    dependency-version: 1.4.0
    dependency-type: indirect
  ...
- Merge pull request #84 from uvNikita/accounting/typo. [Hyacinthe
  Cartiaux]

  Fix typo in accounting.pp
- Fix typo in accounting.pp. [Nikita Uvarov]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.5.2' into devel. [Hyacinthe Cartiaux]

  v1.5.2


v1.5.2 (2025-05-05)
-------------------
- Merge branch 'release/1.5.2' into production. [Hyacinthe Cartiaux]
- Bump to version '1.5.2' [Hyacinthe Cartiaux]
- Gemfile.lock - update. [Hyacinthe Cartiaux]
- Metadata.json - new line needed at the end of the file. [Hyacinthe
  Cartiaux]
- Gemfile - fixes for PDK. [Hyacinthe Cartiaux]
- Gemfile.lock - bundle update. [Hyacinthe Cartiaux]
- Merge pull request #82 from Aman1994/fix-package-name. [Hyacinthe
  Cartiaux]

  Changed the package name from libibmad to infiniband-diags since offi…
- Changed the package name from libibmad to infiniband-diags since
  official redhat has done that. [Aman Shah]
- Merge pull request #81 from jorhett/pass_mysql_db_charset. [Hyacinthe
  Cartiaux]

  Add slurmdbd::charset and collate to override mysql module values
- Add slurmdbd::charset and collate to override mysql module values. [Jo
  Rhett]
- Merge pull request #80 from jorhett/commitdelay-broken-by-reference-
  to-dbpausd. [Hyacinthe Cartiaux]

  DBD CommitDelay broken by apparent mistype
- DBD CommitDelay broken by apparent mistype. [Jo Rhett]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge pull request #79 from ULHPC/dependabot/bundler/rexml-3.3.9.
  [Hyacinthe Cartiaux]

  Bump rexml from 3.3.6 to 3.3.9
- Bump rexml from 3.3.6 to 3.3.9. [dependabot[bot]]

  Bumps [rexml](https://github.com/ruby/rexml) from 3.3.6 to 3.3.9.
  - [Release notes](https://github.com/ruby/rexml/releases)
  - [Changelog](https://github.com/ruby/rexml/blob/master/NEWS.md)
  - [Commits](https://github.com/ruby/rexml/compare/v3.3.6...v3.3.9)

  ---
  updated-dependencies:
  - dependency-name: rexml
    dependency-type: indirect
  ...
- Merge tag 'v1.5.1' into devel. [Hyacinthe Cartiaux]

  v1.5.1


v1.5.1 (2024-09-03)
-------------------
- Merge branch 'release/1.5.1' into production. [Hyacinthe Cartiaux]
- Bump to version '1.5.1' [Hyacinthe Cartiaux]
- Gemfile.lock update. [Hyacinthe Cartiaux]
- Gemfile.lock update. [Hyacinthe Cartiaux]
- Merge pull request #77 from jorhett/fix-slurmd-spooldir. [Hyacinthe
  Cartiaux]

  Fix slurmd spooldir to be consistent/default
- Fix slurmd spooldir to be consistent/default. [Jo Rhett]
- Falkorlib and facter update. [Hyacinthe Cartiaux]
- Lint! [Hyacinthe Cartiaux]
- Syntax clean. [Hyacinthe Cartiaux]
- PDK and Falkorlib update tentative. [Hyacinthe Cartiaux]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.5.0' into devel. [Hyacinthe Cartiaux]

  v1.5.0


v1.5.0 (2024-08-23)
-------------------
- Merge branch 'release/1.5.0' into production. [Hyacinthe Cartiaux]
- Bump to version '1.5.0' [Hyacinthe Cartiaux]
- Bundle update. [Hyacinthe Cartiaux]
- Munge key content can be either a string or binary object. [Hyacinthe
  Cartiaux]
- Merge pull request #71 from jorhett/allow-pure-package-installation.
  [Hyacinthe Cartiaux]

  Apply broken when do_build is false
- Apply broken when do_build is false. [Jo Rhett]
- Merge pull request #70 from jorhett/fix-missing-spool-directory.
  [Hyacinthe Cartiaux]

  Fix missing spool directory, pidfile location, obsoleted specplugin
- Fix missing spool directory, pidfile location, obsoleted specplugin.
  [Jo Rhett]
- Merge pull request #72 from jorhett/replace-validate-legacy-with-data-
  types. [Hyacinthe Cartiaux]

  Replace obsolete validate_legacy with data type tests
- Replace obsolete validate_legacy with data type tests. [Jo Rhett]
- Merge pull request #73 from jorhett/update-mysql-module. [Hyacinthe
  Cartiaux]

  Update mysql dependency to moodern versions, replace legacy password function
- Merge branch 'devel' into update-mysql-module. [Hyacinthe Cartiaux]
- Merge pull request #76 from jorhett/skip-too-long-mysql-hostnames.
  [Hyacinthe Cartiaux]

  Avoid mysql failures with too-long host names
- Avoid mysql failures with too-long host names. [Jo Rhett]
- Update mysql dependency to moodern versions, replace legacy password
  function. [Jo Rhett]
- Update mkdocs.yml - use nav instead of pages. [Hyacinthe Cartiaux]
- Gemfile.lock update - fix dependabot alerts. [Hyacinthe Cartiaux]
- Add missing .readthedocs file. [Hyacinthe Cartiaux]
- Gemfile.lock - update. [Hyacinthe Cartiaux]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.4.10' into devel. [Hyacinthe Cartiaux]

  v1.4.10


v1.4.10 (2024-06-20)
--------------------
- Merge branch 'release/1.4.10' into production. [Hyacinthe Cartiaux]
- Bump to version '1.4.10' [Hyacinthe Cartiaux]
- Lint! Fixed legacy facts. [Hyacinthe Cartiaux]
- Synchronize Changelog with latest commits. [Teddy Rodrigues Valette]
- Merge tag 'v1.4.9' into devel. [Teddy Rodrigues Valette]

  v1.4.9


v1.4.9 (2024-03-13)
-------------------
- Merge branch 'release/1.4.9' into production. [Teddy Rodrigues
  Valette]
- Bump to version '1.4.9' [Teddy Rodrigues Valette]
- Merge pull request #69 from ULHPC/23-11_cgroup_changes. [Teddy
  Rodrigues Valette]

  cgroup.conf - adapt template for v23.11
- Cgroup.conf - adapt template for v23.11     - Removed deprecated
  parameters AllowedKmemSpace, ConstrainKmemSpace, MaxKmemPercent,
  MinKmemSpace for >= 23.11.     - Remove CgroupAutomount= option from
  cgroup.conf for >= 23.11.     - Add "SignalChildrenProcesses=<yes|no>"
  option to cgroup.conf for >= 23.11.     - See
  https://github.com/SchedMD/slurm/blob/slurm-23.11/RELEASE_NOTES.
  [Teddy Rodrigues Valette]
- Metadata.json - update tested dependencies. [Hyacinthe Cartiaux]
- Slurmdbd.conf - fix typo in ArchiveResvs parameter. [Teddy Rodrigues
  Valette]
- Slurm.conf - typo in commented definition of SuspendRate. [Teddy
  Rodrigues Valette]
- Synchronize Changelog with latest commits. [Teddy Valette]
- Merge tag 'v1.4.8' into devel. [Teddy Valette]

  v1.4.8


v1.4.8 (2024-01-10)
-------------------
- Merge branch 'release/1.4.8' into production. [Teddy Valette]
- Bump to version '1.4.8' [Teddy Valette]
- Merge pull request #68 from ULHPC/feature/powersaving. [Teddy
  Rodrigues Valette]

  slurm.conf - add a few parameters for power saving
- Slurm.conf - add a few parameters for power saving     - ReconfigFlags
  - SuspendRate     - SuspendExcStates     - SuspendExcParts. [Teddy
  Valette]
- Merge pull request #66 from uvNikita/slurmdbd/auth-alt-params. [Teddy
  Rodrigues Valette]

  [slurm::slurmdbd] set AuthAltTypes and AuthAltParameters
- [slurm::slurmdbd] set AuthAltTypes and AuthAltParameters. [Nikita
  Uvarov]
- Synchronize Changelog with latest commits. [Teddy Valette]
- Merge tag 'v1.4.7' into devel. [Teddy Valette]

  v1.4.7


v1.4.7 (2023-05-22)
-------------------
- Merge branch 'release/1.4.7' into production. [Teddy Valette]
- Bump to version '1.4.7' [Teddy Valette]
- [slurm::params] add rocky support for munge dependencies. [Teddy
  Valette]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.4.6' into devel. [Hyacinthe Cartiaux]

  v1.4.6


v1.4.6 (2023-02-27)
-------------------
- Merge branch 'release/1.4.6' into production. [Hyacinthe Cartiaux]
- Bump to version '1.4.6' [Hyacinthe Cartiaux]
- Cgroup.conf template - make TaskAffinity optional (removed in 21.08.2
  and default is no) [Hyacinthe Cartiaux]
- Synchronize Changelog with latest commits. [Hyacinthe Cartiaux]
- Merge tag 'v1.4.5' into devel. [Hyacinthe Cartiaux]

  v1.4.5


v1.4.5 (2023-02-07)
-------------------
- Merge branch 'release/1.4.5' into production. [Hyacinthe Cartiaux]
- Bump to version '1.4.5' [Hyacinthe Cartiaux]
- Install python3-devel to build pmix. [Hyacinthe Cartiaux]
- Bundle update. [Hyacinthe Cartiaux]
- Merge pull request #63 from uvNikita/accounting-store-flags.
  [Sebastien Varrette]

  Add AccountingStoreFlags, remove AccountingStoreJobComment
- Remove AccountingStoreJobComment. [Nikita Uvarov]

  Option was removed in 21.08
- Add AccountingStoreFlags. [Nikita Uvarov]
- Revert "New parameter slurm::build_pmix_install_path" [Sebastien
  Varrette]

  This reverts commit 9a74180471f109c907e997829029ea0721784eaa.
- Merge pull request #62 from uvNikita/patch-6. [Sebastien Varrette]

  Allow slurmdport and slurmctldport to be Strings
- Allow slurmdport and slurmctldport to be Strings. [Nikita Uvarov]

  As per https://slurm.schedmd.com/slurm.conf.html,
  port parameters can be port ranges.
- Merge branch 'feature/pdk-update' into devel. [Sebastien Varrette]
- Pdk validate. [Sebastien Varrette]
- Devecontainer. [Sebastien Varrette]
- PDK update. [Sebastien Varrette]
- Update rubocop. [Sebastien Varrette]
- [Gemfile] metadata-json-lint. [Sebastien Varrette]
- [Gemfile] restore puppetlabs_spec_helper. [Sebastien Varrette]
- Update gemspec. [Sebastien Varrette]
- Merge tag 'v1.4.4' into devel. [Hyacinthe Cartiaux]

  v1.4.4


v1.4.4 (2022-06-20)
-------------------
- Merge branch 'release/1.4.4' into production. [Hyacinthe Cartiaux]
- Bump to version '1.4.4' [Hyacinthe Cartiaux]
- New parameter slurm::build_pmix_install_path. [Hyacinthe Cartiaux]
- Merge pull request #61 from uvNikita/auth-alt. [Sebastien Varrette]

  Add AuthAltTypes and AuthAltParameters
- Add AuthAltTypes and AuthAltParameters. [Nikita Uvarov]

  These two parameters can be used in the new slurmrestd service.
- Puppet update. [Sebastien Varrette]
- Merge pull request #59 from uvNikita/patch-5. [Sebastien Varrette]

  Uncomment JobContainerType in slurm.conf.erb
- Uncomment JobContainerType in slurm.conf.erb. [Nikita Uvarov]
- Merge pull request #58 from uvNikita/patch-5. [Sebastien Varrette]

  Remove redundant checkif from acct::mgr
- Remove redundant checkif from acct::mgr. [Nikita Uvarov]

  `unless` parameter should be enough
- Merge pull request #57 from uvNikita/patch-5. [Sebastien Varrette]

  Fix typo in slurm.conf template
  Thanks!
- Fix typo in slurm.conf template. [Nikita Uvarov]

  slurmdparameters -> slurmctldparameters
- [pmix::build] pmix-devel package mandatory. [Sebastien Varrette]
- [slurm::params] enable slurmrestd build by default. [Sebastien
  Varrette]
- [slurm::params] pre-requisite packages to build slurmrestd. [Sebastien
  Varrette]
- [slurm::pmix::install] pmix-devel. [Sebastien Varrette]
- Disable cray_shasta. [Sebastien Varrette]
- [slurm::pmix::install] install pmix-devel. [Sebastien Varrette]
- Synchronize Changelog with latest commits. [Sebastien Varrette]
- Merge tag 'v1.4.3' into devel. [Sebastien Varrette]

  Support for new slurm.conf parameters introduced in 20.x


v1.4.3 (2021-03-31)
-------------------
- Merge branch 'release/1.4.3' into production. [Sebastien Varrette]
- Bump to version '1.4.3' [Sebastien Varrette]
- Support for new configuration parameter AccountingStorageExternalHost.
  [Sebastien Varrette]
- Syntax fix. [Sebastien Varrette]
- Support for new configuration parameter DependencyParameters.
  [Sebastien Varrette]
- [rake] bump dependencies enhancement. [Sebastien Varrette]
- Synchronize Changelog with latest commits. [Sebastien Varrette]
- [rake] gitchanelog and pdk:validate tasks. [Sebastien Varrette]
- Merge tag 'v1.4.2' into devel. [Sebastien Varrette]

  Meaningful Changelog with gitchangelog


v1.4.2 (2021-03-30)
-------------------
- Merge branch 'release/1.4.2' into production. [Sebastien Varrette]
- Bump to version '1.4.2' [Sebastien Varrette]
- Updated Changelog. [Sebastien Varrette]
- Merge tag 'v1.4.1' into devel. [Sebastien Varrette]

  PDK validate


v1.4.1 (2021-03-30)
-------------------
- Merge branch 'release/1.4.1' into production. [Sebastien Varrette]
- Bump to version '1.4.1' [Sebastien Varrette]
- [slurm::slurm{d,ctld,dbd}] type casting to string for firewall ports.
  [Sebastien Varrette]
- [slurm::firewall] support for integer port parameter. [Sebastien
  Varrette]
- Fix for pdk validate. [Sebastien Varrette]
- Merge tag 'v1.4.0' into devel. [Sebastien Varrette]

  Slurm 20.11.3 as default


v1.4.0 (2021-03-30)
-------------------
- Merge branch 'release/1.4.0' into production. [Sebastien Varrette]
- Bump to version '1.4.0' [Sebastien Varrette]
- Merge branch 'feature/slurm-20.11.3' into devel. [Sebastien Varrette]
- Copyright date. [Sebastien Varrette]
- Erb bugfix. [Sebastien Varrette]
- Fix #48: now rely on saz/limits instead of svarrette/ulimits.
  [Sebastien Varrette]
- [slurm::pmix] optionnal build and install processes. [Sebastien
  Varrette]
- [slurm] New recommanded settings for TaskPlugin and TaskPluginParams.
  [Sebastien Varrette]
- [ERB] slurm.conf: deprecated AccountingStorageLoc. [Sebastien
  Varrette]
- [slurm] deprecated FastSchedule parameter. [Sebastien Varrette]
- [slurm::params] upgrade to 20.11.3 as default. [Sebastien Varrette]
- [bugfix] slurm{ctld,dbd} string port range. [Sebastien Varrette]
- [bugfix] slurmd string port range. [Sebastien Varrette]
- Revert "test" [Sebastien Varrette]

  This reverts commit 29c6ea26f12f712d7d14d5ba4e93f2242eed3321.
- Test. [Sebastien Varrette]
- [docs] overview. [Sebastien Varrette]
- Symlink removal. [Sebastien Varrette]
- Merge tag 'v1.3.0' into devel. [Sebastien Varrette]

  Bugfix, support for PDK and updated Vagrant config


v1.3.0 (2020-10-21)
-------------------
- Merge branch 'release/1.3.0' into production. [Sebastien Varrette]
- Update 2020. [Sebastien Varrette]
- Bump to version '1.3.0' [Sebastien Varrette]
- [vagrant] Update puppet bootstrap. [Sebastien Varrette]
- Merge pull request #44 from Zicrom08/windows_plugin. [Sebastien
  Varrette]

  Adding the necessary plugins for Windows users
- Adding the necessary plugins for Windows users. [Zicrom]
- Merge pull request #54 from ULHPC/dependabot/bundler/json-2.3.0.
  [Sebastien Varrette]

  Bump json from 2.1.0 to 2.3.0
- Bump json from 2.1.0 to 2.3.0. [dependabot[bot]]

  Bumps [json](https://github.com/flori/json) from 2.1.0 to 2.3.0.
  - [Release notes](https://github.com/flori/json/releases)
  - [Changelog](https://github.com/flori/json/blob/master/CHANGES.md)
  - [Commits](https://github.com/flori/json/compare/v2.1.0...v2.3.0)
- Merge branch 'feature/pdk' into devel. [Sebastien Varrette]
- Merge branch 'devel' into feature/pdk. [Sebastien Varrette]
- Fix do_build behavior. [Hyacinthe Cartiaux]
- Merge pull request #53 from uvNikita/fix-install-deps. [Hyacinthe
  Cartiaux]

  Specify slurm::common -> slurm::install dependency
- Specify slurm::common -> slurm::install dependency. [Nikita Uvarov]

  Otherwise, packages from common class are installed after (failed) build
  sometimes.
- Merge pull request #47 from danifr/patch-3. [Hyacinthe Cartiaux]

  Replace stahnma/epel by puppet-epel
- Add puppet-epel as a dependency. [Daniel Fernández]
- Replace stahnma/epel by puppet/epel. [Daniel Fernández]
- PDK compliance. [Sebastien Varrette]
- [pmix::install] prepare for yum install instead of rpm. [Sebastien
  Varrette]
- Update gemfile/rakefile. [Sebastien Varrette]
- Bootstrap pdk. [Sebastien Varrette]
- Security fix. [Sebastien Varrette]
- Revert "Fix a strange bug with concat and empty arrays" [Hyacinthe
  Cartiaux]

  This reverts commit 55c60dd3e16c5418f1d448925027a698a9576b0f.
- Fix a strange bug with concat and empty arrays. [Hyacinthe Cartiaux]
- Merge pull request #38 from runejuhl/fix-circular-dependency.
  [Sebastien Varrette]

  Optionally install build dependencies and MySQL (previously #20), fix circular dependency
- Fix circular dependency introduced in e37dec3 and 2fd2e6d. [Rune Juhl
  Jacobsen]

  Commit e37dec3 and 2fd2e6d uses the variable `$::slurm::do_build` in
  `::slurm::params` to set the variables
  `$::slurm::params::pre_requisite_packages` and
  `$::slurm::params::munge_extra_packages`. Because `$::slurm::do_build` is
  defined in `::slurm` this introduces a circular dependency.

  If running Puppetserver with the setting `strict_variables = true` this results
  in a failure:

  ~~~
  Error: Could not retrieve catalog from remote server: Error 500 on SERVER: Server Error: Evaluation Error: Unknown variable: 'slurm::do_build'. at /etc/puppetlabs/code/environments/production/modules/slurm/manifests/params.pp:29:6 on node whata.name
  ~~~
- Instal Development tools only if building slurm. [gustavo panizzo]
- Install $munge_extra_packages only if we are building slurm. [gustavo
  panizzo]
- Install build dependencies only if building slurm on the node.
  [gustavo panizzo]
- Make MySQL bootstrapping optional. [gustavo panizzo]
- Merge pull request #46 from danifr/patch-2. [Sebastien Varrette]

  Fix typo
- Fix typo. [Daniel Fernández]
- Merge pull request #45 from danifr/patch-1. [Sebastien Varrette]

  Only set :is_vagrant if :is_virtual is present
- Only set :is_vagrant if :is_virtual is present. [Daniel Fernández]
- Merge branch 'feature/slurm-19.05.3-2' into devel. [Sebastien
  Varrette]
- [slurm::install] scope on defined(Class[...]) [Sebastien Varrette]
- SPANK interface doc. [Sebastien Varrette]
- Install ruby 2.3 in the CentOS 7 vagrant box. [Sebastien Varrette]
- Target cannot be an empty string. [Trent Anderson]
- Recent example. [Sebastien Varrette]
- [travis] upgrade tested ruby version. [Sebastien Varrette]
- Notice. [Sebastien Varrette]
- Privatedata. [Sebastien Varrette]
- [slurm::slurmdbd] privatedata default comment. [Sebastien Varrette]
- [slurm::config::plugstack] [Sebastien Varrette]
- [slurm::config] bugfix seltype. [Sebastien Varrette]
- [slurm::config] seltype. [Sebastien Varrette]
- [slurm::config] takes care of $slurm::plugins. [Sebastien Varrette]
- Update README. [Sebastien Varrette]
- [metadata] tag pmix. [Sebastien Varrette]
- [slurm::config] new bahavior for slurm::pluginsdir_target. [Sebastien
  Varrette]
- Cosmetics in header. [Sebastien Varrette]
- Hotfix 'if' statement has no effect. [Sebastien Varrette]
- Cgroup_allowed_devices_file.conf is no longer required. [Sebastien
  Varrette]
- [hiera][slurm] ResumeFailProgram. [Sebastien Varrette]
- [slurm] support for X11Parameters. [Sebastien Varrette]
- [slurm] support for LaunchParameters. [Sebastien Varrette]
- Slurm[ctl]ddebugsyslog -> slurm[ctl]dsyslogdebug and new
  slurm[ctl]dparameters. [Sebastien Varrette]
- [slurm] consistent variable names acct* [Sebastien Varrette]
- [slurm::slurmdbd] create $slurm::jobcomploc if needed. [Sebastien
  Varrette]
- [slurm] slurmctld{host,addr} instead of deprecated
  control{machine,addr} and backup{controller,addr} [Sebastien Varrette]
- [slurm::build] verbose less. [Sebastien Varrette]
- Update CheckpointType. [Sebastien Varrette]
- Cryptotype -> credtype. [Sebastien Varrette]
- Simplify acct_gather_profile parameter. [Sebastien Varrette]
- [slurm::slurmdbd] reenable innodb_log_file_size. [Sebastien Varrette]
- Simplify class to slurm::pmix class. [Sebastien Varrette]
- [ERB] slurm.conf: sanitize useless newline. [Sebastien Varrette]
- [slurm::slurmdbd] check for innodb_* settings. [Sebastien Varrette]
- [slurm::params] reindent. [Sebastien Varrette]
- [slurm::build] abstract pmix install path. [Sebastien Varrette]
- Lint checks. [Sebastien Varrette]
- Cosmetics. [Sebastien Varrette]
- Merge branch 'devel' into feature/slurm-19.05.3-2. [Sebastien
  Varrette]
- Merge pull request #23 from gfa/PR-4. [Sebastien Varrette]

  Add support for acct gather profiles
- Add support for acct gather profiles. [gustavo panizzo]
- Merge pull request #32 from Rovanion/deploy-config-for-other-modules-
  too. [Sebastien Varrette]

  Removed if-statement hindering slurm.conf being deployed when needed
- Removed if-statement hindering slurm.conf being deployed when needed.
  [Rovanion Luckey]

  It was needed by acct::mgr to manage accounting and is reasonably needed by other operations too. Every module which requires config should now get it.
- Merge pull request #15 from uvNikita/add-params. [Sebastien Varrette]

  Add MaxArraySize and MaxJobCount params
- Add MaxArraySize and MaxJobCount params. [Nikita Uvarov]
- Merge branch 'devel' into feature/slurm-19.05.3-2. [Sebastien
  Varrette]
- Merge pull request #30 from Rovanion/slurmctl-require-config.
  [Sebastien Varrette]

  Make the slurmctl class require that the config is present
- Make the slurmctl class require that the config is present. [Rovanion
  Luckey]
- Merge pull request #31 from Rovanion/accounting-require-config.
  [Sebastien Varrette]

  Make the accounting tasks require that the config is present
- Make the accounting tasks require that the config is present.
  [Rovanion Luckey]
- Merge pull request #33 from Rovanion/no-default-partition-job_submit-
  fix. [Sebastien Varrette]

  Ensure that the partition given over to slurm is a string and not something else
- Ensure that the partition given over to slurm is a string and not
  something else. [Rovanion Luckey]

  If it was something else, for example nil, slurm will crash with a
  unknown error. If we instead force the value into its string
  representation slurm can give the error 'Partition nil does not
  exist.' which is understandable to the user.
- Add support for (separated) PMIx upon slurm build. [Sebastien
  Varrette]
- [tests] --modulepath info within vagrant. [Sebastien Varrette]
- [slurm::pmix*] consistent parameter prefix for checksum* ->
  src_checksum* [Sebastien Varrette]
- Fix #26. [Sebastien Varrette]
- [slurm::pmix] simple wrapper for slurm::pmix::{download,build,install}
  [Sebastien Varrette]
- [slurm::pmix::install] [Sebastien Varrette]
- Cosmetics. [Sebastien Varrette]
- [slurm::pmix::build] allow for extra --define options to rpmbuild.
  [Sebastien Varrette]
- [slurm::pmix::build] [Sebastien Varrette]
- [slurm::pmix::download] consider extraction of the archive for .spec
  access. [Sebastien Varrette]
- Slurm::pmix::download. [Sebastien Varrette]
- Merge branch 'feature/security-alert' into devel. [Sebastien Varrette]
- Security Alerts - CVE-2019-5477 - "nokogiri", ">= 1.10.4" [Sebastien
  Varrette]
- Update to ruby 2.6. [Sebastien Varrette]
- Merge pull request #24 from gfa/PR-5. [Sebastien Varrette]

  Add support to define (Max|Default)Time on a partition
- Add support to define DefaultTime on a partition. [gustavo panizzo]
- Add support to define MaxTime on a partition. [gustavo panizzo]
- Potential security vulnerability for yard. [Sebastien Varrette]
- Merge pull request #34 from Rovanion/remove-archived. [Sebastien
  Varrette]

  Correct base download URL to download.schedmd.com
- Correct base download URL to download.schedmd.com. [Rovanion Luckey]

  The two different archives of `latest` and `archived` no longer exist
  on schedmd.com. Now they only have what was previously called
  latest. This commit removes the argument "archived" from the public
  interface of the module and correctl the base url to reflect this
  change.
- Merge pull request #36 from runejuhl/el6. [Sebastien Varrette]

  Add el6 support
- Add CentOS6 and RedHat6 to metadata.json. [Rune Juhl Jacobsen]
- Set `USER` for munged to avoid failing on el6. [Rune Juhl Jacobsen]

  The init script provided with munge-0.5.10-1.el6 sets the `USER=daemon`
  environment variable and subsequently loads the variables in sysconfig so we can
  use this to userride the default value.
- Change default cgroup path for el6. [Rune Juhl Jacobsen]
- Merge pull request #25 from gfa/PR-6. [Sebastien Varrette]

  Add support to configure UnkillableStepTimeout in slurm.conf
- Add support to configure UnkillableStepTimeout in slurm.conf. [gustavo
  panizzo]
- Merge pull request #28 from Rovanion/readme-url-fix. [Sebastien
  Varrette]

  Fixed a simple one letter misspelling in README.md
- Fixed a simple one letter misspelling in README.md. [Rovanion Luckey]
- Merge pull request #22 from gfa/PR-3. [Sebastien Varrette]

  Enable support for power management
- Enable support for power management. [gustavo panizzo]
- Merge pull request #21 from gfa/PR-2. [Sebastien Varrette]

  Optionally send slurmd, slurmctld and slurmdbd  logs to syslog
- Optionally send slurmd, slurmctld and slurmdbd  logs to syslog.
  [gustavo panizzo]
- Ignore vagrant setup from the puppet built package. [Sebastien
  Varrette]
- Merge tag 'v1.2.0' into devel. [Sebastien Varrette]

  TRES, scheduler parameters and custom content management

  - Bugfix #2: slurmdbd on separate host bug
  - Bugfix #7: slurm-login nodes without daemons
  - Bugfix #12: slurm-17.11.3 install fails bug
  - Bugfix #13: Add SchedulerParameters to slurm.conf.erb template
  - Bugfix #14: Prevent improper use of SchedMD resources
  - Bugfix #16: Allow for TRESBillingWeights enhancement
  - Bugfix #17: Consolidate vagrant setup for module validation on a virtual cluster enhancement
  - Bugfix #18: Allow for custom content enhancement


v1.2.0 (2019-02-03)
-------------------
- Merge branch 'release/1.2.0' into production. [Sebastien Varrette]
- Bump to version '1.2.0' [Sebastien Varrette]
- Bugfix #14 add new general parameter src_checksum_type to slurm class.
  [Sebastien Varrette]
- Bugfix #14 Prevent improper use of SchedMD resources. [Sebastien
  Varrette]
- Cosmetics. [Sebastien Varrette]
- Lint compliance++ [Sebastien Varrette]
- Lint compliance: {accountingstorage,priorityweight}TRES ->
  {accountingstorage,priorityweight}tres. [Sebastien Varrette]
- Update rubocop settings. [Sebastien Varrette]
- Travis ruby update. [Sebastien Varrette]
- Rework mkdocs/readthedocs settings. [Sebastien Varrette]
- Allow for SchedulerParameters directives. [Sebastien Varrette]

  - Bugfix #13
- Allow for custom content. [Sebastien Varrette]

  - Bugfix #18
- Allow for TRESBillingWeights. [Sebastien Varrette]

  - See Issue #16
- Remove automatic addition of 127.0.1.1 in /etc/hosts. [Sebastien
  Varrette]

  - conflicts with 'sacctmgr show cluster' reported adress
- Install ifconfig. [Sebastien Varrette]
- Update logger / falkorlib. [Sebastien Varrette]
- Security fix CVE-2018-14404. [Sebastien Varrette]
- Add stress by default. [Sebastien Varrette]
- Fix. [Sebastien Varrette]
- Complete README with profile info. [Sebastien Varrette]
- Possibility to set AccountingStorageHost. [Sebastien Varrette]

  - Bugfix #2
- Rework Vagrant setup to allow for flexible cluster deployment.
  [Sebastien Varrette]

  - Bugfix #17
  - config.yaml can overwrite default settings
  - role-based deployment
  - By default, deployment of:
      * 1 Slurm controller (including the Slurm accounting DB)
      * 1 login node (no daemon -- see #7)
      * 2 compute nodes
- Merge branch 'feature/17.11.12' into devel. [Sebastien Varrette]
- Ensure slurm package are properly install in slurm::login. [Sebastien
  Varrette]

  - Bugfix #7
- Attempt to detect slurm login node configurayion in slurm::config.
  [Sebastien Varrette]
- New 'slurm::login' helper class for setting up a Login node.
  [Sebastien Varrette]

  - Bugfix #7
  - Sample/simple profile::slurm::login used on vagrant deployment
- Sample (and simple) profile::slurm[::slurm{d,ctld,dbd}] [Sebastien
  Varrette]
- Prepare hiera layout for flexible profile-based setup. [Sebastien
  Varrette]
- Prepare script for vagrant shell provisioning. [Sebastien Varrette]
- Rework vagrant puppet provisionning structure. [Sebastien Varrette]
- Verbose. [Sebastien Varrette]
- Increase allowed timeout upon rpmbuild. [Sebastien Varrette]
- Complete default package installed upon shell provisionning.
  [Sebastien Varrette]
- Review package list per installation type. [Sebastien Varrette]
- Separate list of officials RPMs requested depending on daemons.
  [Sebastien Varrette]
- Rework individual tests for each daemon. [Sebastien Varrette]
- Fix screen title in vagrant bootstrap. [Sebastien Varrette]
- Template slurm.conf with Trackable RESources (TRES) policies.
  [Sebastien Varrette]
- $TRESbillingweights -> $tresbillingweights to conform to naming rules.
  [Sebastien Varrette]
- Trackable RESources (TRES) parameters. [Sebastien Varrette]
- Update default slurm version to 17.11.12. [Sebastien Varrette]
- [vagrant] remove config.trigger. [Sebastien Varrette]
- Upgrade modele deps. [Sebastien Varrette]
- Update slurm version to 17.11.9-2. [Sebastien Varrette]
- Merge branch 'devel' into feature/17.11.7. [Sebastien Varrette]
- Bundle update. [Sebastien Varrette]
- Update default version to 17.11.7. [Sebastien Varrette]
- Merge tag 'v1.1.4' into devel. [Sebastien Varrette]

  Completion file update


v1.1.4 (2018-04-23)
-------------------
- Merge branch 'release/1.1.4' into production. [Sebastien Varrette]
- Bump to version '1.1.4' [Sebastien Varrette]
- Merge branch 'devel' of github.com:ULHPC/puppet-slurm into devel.
  [Sebastien Varrette]
- Update SLURM to latest stable 17.11.5, solves our
  https://bugs.schedmd.com/show_bug.cgi?id=4769. [Valentin Plugaru]
- Update bash completion file from 17.11.5. [Sebastien Varrette]
- Attempt to resolve issues #10 and #11. [Sebastien Varrette]
- Merge tag 'v1.1.3' into devel. [Sebastien Varrette]

  Jobrequeue


v1.1.3 (2018-02-15)
-------------------
- Merge branch 'release/1.1.3' into production. [Sebastien Varrette]
- Bump to version '1.1.3' [Sebastien Varrette]
- Jobrequeue. [Sebastien Varrette]
- Merge tag 'v1.1.2' into devel. [Sebastien Varrette]

  missing deps packages


v1.1.2 (2018-02-12)
-------------------
- Merge branch 'release/1.1.2' into production. [Sebastien Varrette]
- Bump to version '1.1.2' [Sebastien Varrette]
- Complete required packages. [Sebastien Varrette]
- Merge tag 'v1.1.1' into devel. [Sebastien Varrette]

  deps update


v1.1.1 (2018-02-08)
-------------------
- Merge branch 'release/1.1.1' into production. [Sebastien Varrette]
- Bump to version '1.1.1' [Sebastien Varrette]
- Remove useless dependency. [Sebastien Varrette]
- Merge tag 'v1.1.0' into devel. [Sebastien Varrette]

  17.11 release


v1.1.0 (2018-02-08)
-------------------
- Merge branch 'release/1.1.0' into production. [Sebastien Varrette]
- Bump to version '1.1.0' [Sebastien Varrette]
- Merge branch 'devel' of github.com:ULHPC/puppet-slurm into devel.
  [Sebastien Varrette]
- Metadata.json: remove the unused inifile dependency. [Hyacinthe
  Cartiaux]
- Yard 0.9.12 in Gemfile.lock. [Valentin Plugaru]
- Merge tag 'v1.0.4' into devel. [Valentin Plugaru]

  v1.0.4
- Update. [Sebastien Varrette]
- Update version. [Sebastien Varrette]


v1.0.4 (2018-01-22)
-------------------
- Merge branch 'release/1.0.4' into production. [Valentin Plugaru]
- Bump to version '1.0.4' [Valentin Plugaru]
- Lint. [Valentin Plugaru]
- Use mysql override settings instead of ini_setting for bind address.
  [Valentin Plugaru]
- Travis badge. [Sebastien Varrette]
- 'rake validate' fail on travis. [Sebastien Varrette]
- Symplify matrix. [Sebastien Varrette]
- Complete travis checks. [Sebastien Varrette]
- Support for travis. [Sebastien Varrette]
- Support for rubocop. [Sebastien Varrette]
- Merge pull request #6 from uvNikita/patch-5. [Sebastien Varrette]

  Add memory per node limits to slurm.conf
- Add memory per node limits to slurm.conf. [Nikita Uvarov]

  Previously `defmempernode` and `maxmempernode` parameters
  were ignored by the module.
- Upgrade Rubocop deps as low severity security vulnerability in version
  range < 0.48.1. [Sebastien Varrette]
- Merge pull request #3 from uvNikita/patch-2. [Sebastien Varrette]

  Fix typos in readme documentation for slurmd
- Fix typos in readme documentation for slurmd. [Nikita Uvarov]
- Merge pull request #5 from uvNikita/patch-4. [Sebastien Varrette]

  Fix startup error when acct enforce list is empty
- Fix startup error when acct enforce list is empty. [Nikita Uvarov]

  An empty value in AccountingStorageEnforce parameter causes
  slurm daemon to fail on start. If no enforcement is desired,
  this parameter should be commented out.
- Merge pull request #1 from uvNikita/patch-1. [Sebastien Varrette]

  Include firewalld only if manage_firewall is true
- Include firewalld only if manage_firewall is true. [Nikita Uvarov]
- Merge tag 'v1.0.3' into devel. [Sebastien Varrette]

  syntax correction


v1.0.3 (2017-10-20)
-------------------
- Merge branch 'release/1.0.3' into production. [Sebastien Varrette]
- Rake up. [Sebastien Varrette]
- Bump to version '1.0.3' [Sebastien Varrette]
- Minor correction. [Sebastien Varrette]
- Merge tag 'v1.0.2' into devel. [Hyacinthe Cartiaux]

  v1.0.2


v1.0.2 (2017-10-16)
-------------------
- Merge branch 'release/1.0.2' into production. [Hyacinthe Cartiaux]
- Bump to version '1.0.2' [Hyacinthe Cartiaux]
- Unlint... (integer to string conversion required) [Hyacinthe Cartiaux]
- Merge tag 'v1.0.1' into devel. [Hyacinthe Cartiaux]

  v1.0.1


v1.0.1 (2017-10-16)
-------------------
- Merge branch 'release/1.0.1' into production. [Hyacinthe Cartiaux]
- Bump to version '1.0.1' [Hyacinthe Cartiaux]
- Lint ! [Hyacinthe Cartiaux]
- Add slurm::priorityflags as configurable parameter. [Valentin Plugaru]
- Fail... [Sebastien Varrette]
- Syntax correction. [Sebastien Varrette]
- Attempt to correct mysql ini. [Sebastien Varrette]
- Merge tag 'v1.0.0' into devel. [Sebastien Varrette]

  Module used in Production on iris cluster

  (part of UL HPC facility)


v1.0.0 (2017-10-05)
-------------------
- Merge branch 'release/1.0.0' into production. [Sebastien Varrette]
- Bump to version '1.0.0' [Sebastien Varrette]
- Firewall circumvent. [Sebastien Varrette]
- Lint. [Sebastien Varrette]
- No more need for ghoneycutt-pam. [Sebastien Varrette]
- Correct slurm::pam to use svarrette/ulimit module. [Sebastien
  Varrette]
- Slurm::slurmdbd correct qos normal creation. [Sebastien Varrette]
- Correct slurm::firewall. [Sebastien Varrette]
- Correction on slurm::firewall. [Sebastien Varrette]
- Firewall management. [Sebastien Varrette]
- Slurm::firewall. [Sebastien Varrette]
- Pam correction. [Sebastien Varrette]
- Complete selinux and firewalld deps. [Sebastien Varrette]
- Bugfix statesavelocation. [Sebastien Varrette]
- Handle savestateloc. [Sebastien Varrette]
- Up timeout. [Sebastien Varrette]
- Bash completion. [Sebastien Varrette]
- Doc. [Sebastien Varrette]
- Bash completion file. [Sebastien Varrette]
- Support for deported plugstack.conf.d files. [Sebastien Varrette]
- Correct. [Sebastien Varrette]
- Git config set fro slurm user on slurm::repo. [Sebastien Varrette]
- Lint + slurm::repo::syncto. [Sebastien Varrette]
- Resumetimeout. [Sebastien Varrette]
- Correct cwddir. [Sebastien Varrette]
- Slurm::install::package with pkgdir. [Sebastien Varrette]
- [slurm::repo] ensure creation parent directory for slurm rights.
  [Sebastien Varrette]
- Slurm::repo force. [Sebastien Varrette]
- Bugfix ensure==latest. [Sebastien Varrette]
- Bugfix support ensure = latest. [Sebastien Varrette]
- Support for link_subdir in slurm::repo. [Sebastien Varrette]
- Separate management of services. [Sebastien Varrette]
- Correct slurm::acct::{mgr,qos} to support string/array/hash.
  [Sebastien Varrette]
- Rework accounting classes. [Sebastien Varrette]
- Slurm::acct::{mgr,qos,cluster} [Sebastien Varrette]
- Bugfix erb. [Sebastien Varrette]
- Bugfix erb. [Sebastien Varrette]
- Up slurm.conf.erb. [Sebastien Varrette]
- Test slurmctld class without service management. [Sebastien Varrette]
- Update slurm.conf. [Sebastien Varrette]
- Mode flexible partition generation in slurm.conf from hiera.
  [Sebastien Varrette]
- Prepare qos. [Sebastien Varrette]
- Allow link dir within slurm::repo. [Sebastien Varrette]
- Better absent on slurm::repo. [Sebastien Varrette]
- Safeguard on file creation. [Sebastien Varrette]
- Chown check. [Sebastien Varrette]
- Slurm::repo. [Sebastien Varrette]
- Slurm::repo class. [Sebastien Varrette]
- Install munge extra packages even if manage_munge is false. [Sebastien
  Varrette]
- Bugfix service_manage. [Sebastien Varrette]
- Bugfix package deps. [Sebastien Varrette]
- Service_manage. [Sebastien Varrette]
- Merge tag 'v0.4.0' into devel. [Sebastien Varrette]

  tests consolidation + slurm::acct::cluster


v0.4.0 (2017-09-04)
-------------------
- Merge branch 'release/0.4.0' into production. [Sebastien Varrette]
- Update urls for readthedocs and forge readme rendering. [Sebastien
  Varrette]
- Bump to version '0.4.0' [Sebastien Varrette]
- Lint. [Sebastien Varrette]
- Slurm::acct::cluster. [Sebastien Varrette]
- Update README warning. [Sebastien Varrette]
- Check order for ensure==absent. [Sebastien Varrette]
- Merge tag 'v0.3.0' into devel. [Sebastien Varrette]

  readthedocs integration


v0.3.0 (2017-09-01)
-------------------
- Merge branch 'release/0.3.0' into production. [Sebastien Varrette]
- Bump to version '0.3.0' [Sebastien Varrette]
- Update README. [Sebastien Varrette]
- Merge tag 'v0.2.0' into devel. [Sebastien Varrette]

  Succesful tests for all daemons within vagrant


v0.2.0 (2017-09-01)
-------------------
- Merge branch 'release/0.2.0' into production. [Sebastien Varrette]
- Bump to version '0.2.0' [Sebastien Varrette]
- Update main doc. [Sebastien Varrette]
- Advanced tests. [Sebastien Varrette]
- Correct behaviour upon ensure == 'absent' [Sebastien Varrette]
- Add manage_* parameters. [Sebastien Varrette]
- Complete basic tests for puppet apply. [Sebastien Varrette]
- Cleanup and correct code in case of regular includes. [Sebastien
  Varrette]
- Slurm::slurmdbd operational. [Sebastien Varrette]
- Slurdbd. [Sebastien Varrette]
- Slurm::slurmdbd. [Sebastien Varrette]
- Start slurm::slurmdbd. [Sebastien Varrette]
- Rework code organization. [Sebastien Varrette]
- Modular install. [Sebastien Varrette]
- Specialized classes slurm::slurm[ctl]d. [Sebastien Varrette]
- Correct daemon service. [Sebastien Varrette]
- Lint + alignment. [Sebastien Varrette]
- Slurm.conf generation from ERB. [Sebastien Varrette]
- End doc init.pp with all slurm config options. [Sebastien Varrette]
- Params. [Sebastien Varrette]
- Complete default params for slurm.conf (ouf!) [Sebastien Varrette]
- Params slurm.conf. [Sebastien Varrette]
- Slurm::config::gres. [Sebastien Varrette]
- Slurm::config::cgroup. [Sebastien Varrette]
- Slurm::config[::topology] [Sebastien Varrette]
- Lint. [Sebastien Varrette]
- Simplify code for slurm::common::debian. [Sebastien Varrette]
- Slurm::install. [Sebastien Varrette]
- No slurm::install. [Sebastien Varrette]
- Support ensure=absent in slurm::build. [Sebastien Varrette]
- Cosmetic. [Sebastien Varrette]
- Clean slurm::build. [Sebastien Varrette]
- Update Rakefile. [Sebastien Varrette]
- Upgrade FalkorLib to the latest version. [Sebastien Varrette]
- Cosmetic. [Sebastien Varrette]
- Install slurm builds. [Sebastien Varrette]
- Transform slurm::build into a definition. [Sebastien Varrette]
- Doc slurm::build. [Sebastien Varrette]
- Slurm::build. [Sebastien Varrette]
- Add testing manifest for slurm::download. [Sebastien Varrette]
- Document slurm::download. [Sebastien Varrette]
- Lint pass. [Sebastien Varrette]
- Add slurm::download definition. [Sebastien Varrette]
- Complete params for slurm::{pam,munge} [Sebastien Varrette]
- Yaml custom config doc. [Sebastien Varrette]
- Yaml custom config doc. [Sebastien Varrette]
- Update vagrant doc. [Sebastien Varrette]
- Merge tag 'v0.1.0' into devel. [Sebastien Varrette]

  Bootstrap slurm module repository


v0.1.0 (2017-08-21)
-------------------
- Merge branch 'release/0.1.0' into production. [Sebastien Varrette]
- Bump to version '0.1.0' [Sebastien Varrette]
- Rake git tasks. [Sebastien Varrette]
- Support for Munge daemon_args. [Sebastien Varrette]
- Lint. [Sebastien Varrette]
- Bundle lock. [Sebastien Varrette]
- Slurm::munge. [Sebastien Varrette]
- Bootstrap slurm::munge. [Sebastien Varrette]
- Bootstrap main class. [Sebastien Varrette]
- Lint slurm::pam. [Sebastien Varrette]
- Correct Vagrant env. [Sebastien Varrette]
- Slurm::pam. [Sebastien Varrette]
- Rework vagrant provisionning layout. [Sebastien Varrette]
- Merge branch 'feature/bootstrapping' into devel. [Sebastien Varrette]
- Slurm::pam. [Sebastien Varrette]
- Update & review Vagrant infra. [Sebastien Varrette]
- Review basic README and metadata. [Sebastien Varrette]
- Add 'Vagrantfile' [Sebastien Varrette]
- Add 'Rakefile' [Sebastien Varrette]
- Add '.vagrant_init.rb' [Sebastien Varrette]
- Add 'Gemfile' [Sebastien Varrette]
- Add '.ruby-gemset' [Sebastien Varrette]
- Add '.ruby-version' [Sebastien Varrette]
- Add '.pmtignore' [Sebastien Varrette]
- Add '.gitignore' [Sebastien Varrette]
- Add 'LICENSE' [Sebastien Varrette]
- Add 'mkdocs.yml' [Sebastien Varrette]
- Add 'docs' [Sebastien Varrette]
- Add 'metadata.json' [Sebastien Varrette]
- Initiate the repository with a 'README.md' file. [Sebastien Varrette]


