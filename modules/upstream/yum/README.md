# Yum

[![Build Status](https://github.com/voxpupuli/puppet-yum/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-yum/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-yum/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-yum/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/yum.svg)](https://forge.puppetlabs.com/puppet/yum)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/yum.svg)](https://forge.puppetlabs.com/puppet/yum)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/yum.svg)](https://forge.puppetlabs.com/puppet/yum)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/yum.svg)](https://forge.puppetlabs.com/puppet/yum)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-yum)
[![AGPL v3 License](https://img.shields.io/github/license/voxpupuli/puppet-yum.svg)](LICENSE)

## Module description

This module provides helpful definitions for dealing with *yum*.

### Requirements

Module has been tested on:

* Puppet 4.10.9 and newer
* CentOS 7,8
* Amazon Linux 2017
* RHEL 7
* Fedora 35,36

For the official list of all tested distributions, please take a look at the metadata.json.

## Usage

### Manage global Yum configuration via the primary class

```puppet
class { 'yum':
  keep_kernel_devel => false|true,
  clean_old_kernels => false|true,
  config_options    => {
      my_cachedir => {
        ensure => '/home/waldo/.local/yum/cache',
        key    => 'cachedir',
      },
      gpgcheck    => true,
      debuglevel  => 5,
      assumeyes   => {
        ensure => 'absent',
      },
    },
  },
}
```

NOTE: The `config_options` parameter takes a Hash where keys are the names of
`Yum::Config` resources and the values are either the direct `ensure` value
(`gpgcheck` or `debuglevel` in the example above), or a Hash of the resource's
attributes (`my_cachedir` or `assumeyes` in the example above).  Values may be
Strings, Integers, or Booleans.  Booleans will be converted to either a `1` or
`0`; use a quoted string to get a literal `true` or `false`.

If `installonly_limit` is changed, purging of old kernel packages is triggered
if `clean_old_kernels` is `true`.

### Manage yum.conf entries via defined types

```puppet
yum::config { 'installonly_limit':
  ensure => 2,
}

yum::config { 'debuglevel':
  ensure => absent,
}
```

### Manage COPR repositories

This module also supports managing
COPR ([Cool Other Package Repo](https://fedoraproject.org/wiki/Category:Copr))
repositories via the `yum::copr` resource. The resource title specifies
the COPR repository name, and `ensure` accepts the values `enabled`, `disabled`
or `removed`. Example usage:

```puppet
yum::copr { 'copart/restic':
  ensure => enabled,
}
```

Please note that repositories added this way are not managed via `yumrepo` resources, but enabled and disabled via native package manager commands. As such, they would be purged by a declaration such as:

```puppet
resources { 'yumrepo':
   purge => true,
}
```

However, you can use modules such as [crayfishx-purge](https://forge.puppet.com/modules/crayfishx/purge) to exclude these resources from purging:

```puppet
purge { 'yumrepo':
  unless => [ 'name', '=~', 'copr:.*' ],
}
```

### Manage a custom repo via Hiera data

Using Hiera and automatic parameter lookup (APL), this module can manage
Yumrepos.  The `repos` parameter takes a hash of hashes, where the first-level
keys are the `Yumrepo` resource names and their value hashes contain parameters
and values to feed into the resource definition. **On its own, the `repos`
parameter does nothing.**  The resource names from the hash must be selected via
the `managed_repos` parameter.  This example defines a custom repo.

First, include the class.

```puppet
include 'yum'
```

In Hiera data, add the name of the repo to the `yum::managed_repos` key (an
Array), and define the repo in the `yum::repos` key:

```yaml
---
yum::managed_repos:
    - 'example_repo'
yum::repos:
    example_repo:
        ensure: 'present'
        enabled: true
        descr: 'Example Repo'
        baseurl: 'https://repos.example.com/example/'
        gpgcheck: true
        gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Example'
```

You can include gpgkeys in yaml as well, and if the key filename matches a
gpgkey from a mananged repo, it will be included. For example a gpg key for the
repo above could look like:

```yaml
---
yum::gpgkeys:
    /etc/pki/rpm-gpg/RPM-GPG-KEY-Example:
        content: |
            -----BEGIN PGP PUBLIC KEY BLOCK-----
            Version: GnuPG v1.4.11 (GNU/Linux)

            mQINBFKuaIQBEAC1UphXwMqCAarPUH/ZsOFslabeTVO2pDk5YnO96f+rgZB7xArB
            OSeQk7B90iqSJ85/c72OAn4OXYvT63gfCeXpJs5M7emXkPsNQWWSju99lW+AqSNm
            (SNIP SEVERAL LINES)
            RjsC7FDbL017qxS+ZVA/HGkyfiu4cpgV8VUnbql5eAZ+1Ll6Dw==
            =hdPa
            -----END PGP PUBLIC KEY BLOCK-----
```

... or

```yaml
---
yum::gpgkeys:
    /etc/pki/rpm-gpg/RPM-GPG-KEY-Example:
        source: puppet:///repos/RPM-GPG-KEY-Example
```

### Enable management of one of the pre-defined repos

This module includes several pre-defined Yumrepos for easy management.  This
example enables management of the EPEL repository using its default settings.

**NOTE:** This only works if the data for the repository is included with the
module.  Please see the `/data` directory of this module for a list of available
repos.

```puppet
include 'yum'
```

```yaml
---
yum::managed_repos:
    - 'epel'
```

### Enable management of one of the pre-defined repos AND modify its settings

Here the Extras repository for CentOS is enabled and its settings are modified.
Because the `repos` parameter uses a deep merge strategy when fed via automatic
parameter lookup (APL), only the values requiring modification need be defined.

To clear a value set below (from default repos, or lower in the hierarchy), pass
it the *knockout prefix*, `--`.  This will blank out the value.

```yaml
---
yum::managed_repos:
    - 'extras'
yum::repos:
    extras:
        enabled: true
        baseurl: 'https://myrepo.example.com/extras'
        gpgcheck: false
        gpgkey: '--'
```

The built-in repos by default have data in `mirrorlist`, but `baseurl` is
undefined.  Using the knockout prefix won't work with `mirrorlist`, as it
requires a valid URL or the value `absent`.

In case of Puppet 5, you can find more information in the [Puppet docs][1].
Since Puppet 6, this resource type has been moved to the [puppetlabs/yumrepo_core][2]
module.

```yaml
---
yum::managed_repos:
    - 'extras'
yum::repos:
    extras:
        enabled: true
        baseurl: 'https://mirror.example.com/extras'
        mirrorlist: 'absent'
```

### Enable managemnt of multiple repos

The `managed_repos` parameter uses the `unique` Hiera merge strategy, so it's
possible to define repos to be managed at multiple levels of the hierarchy.  For
example, given the following hierarchy and the following two yaml files, the
module would receive the array `['base', 'extras', 'debug']`.

```yaml
---
hierarchy:
    - name: 'Common'
      paths:
        - "%{trusted.certname}"
        - 'common.yaml'
```

```yaml
---
# node01
yum::managed_repos:
    - 'base'
    - 'debug'
```

```yaml
# common
yum::managed_repos:
    - 'base'
    - 'extras'
```

### Negate previously enabled repos

The `repo_exclusions` parameter is used to *exclude* repos from management.  It
is mainly useful in complex Hiera hierarchies where repos need to be removed
from a baseline.  Here we define a baseline set of repos in `common.yaml`, but
disable one of them for a specific node.

```yaml
---
hierarchy:
    - name: 'Common'
      paths:
        - "%{trusted.certname}"
        - 'common.yaml'
```

```yaml
---
# node01
yum::repo_exclusions:
    - 'updates' #yolo
```

```
---
# common
yum::managed_repos:
    - 'base'
    - 'updates'
    - 'extras'
```

### Enable management of the default OS Yumrepos

This module includes the boolean helper parameter `manage_os_default_repos`
easily select select OS repos.  It uses module data to add the appropriate repos
to the `managed_repos` parameter based on OS facts.  Just like adding them
manually, they can be negated via the `repo_exclusions` parameter.

**NOTE:** This only works for operating systems who's Yumrepos are defined in
the module's data AND who's default repos are defined in the module's data.

On a CentOS 7 machine these two snippets are functionally equivalent.

```puppet
class { 'yum':
  manage_os_default_repos => true,
}
```

```puppet
class { 'yum':
  managed_repos => [
    'base',
    'updates',
    'extras',
    'centosplus',
    'base-source',
    'updates-source',
    'extras-source',
    'base-debuginfo',
    'centos-media',
    'cr',
  ]
}
```

### Add/remove a GPG RPM signing key using an inline key block

```puppet
yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-smoketest1':
  ensure  => present,
  content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
...
-----END PGP PUBLIC KEY BLOCK-----',
}
```

### Add/remove a GPG RPM signing key using a key stored on a Puppet fileserver

```puppet
yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org':
  ensure => present,
  source => 'puppet:///modules/elrepo/RPM-GPG-KEY-elrepo.org',
}
```

### Install or remove *yum* plugin

```puppet
yum::plugin { 'versionlock':
  ensure => present,
}
```

### Lock a package with the *versionlock* plugin
The `versionlock` type changed between CentOS 7 and CentOS 8.

#### CentOS 7 and older
Locks explicitly specified packages from updates. Package name must be precisely
specified in format *`EPOCH:NAME-VERSION-RELEASE.ARCH`*. Wild card in package
name is allowed provided it does not span a field seperator.

```puppet
yum::versionlock { '0:bash-4.1.2-9.el6_2.*':
  ensure => present,
}
```

Use the following command to retrieve a properly-formated string:

```sh
PACKAGE_NAME='bash'
rpm -q "$PACKAGE_NAME" --qf '%|EPOCH?{%{EPOCH}}:{0}|:%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n'
```

To run a `yum clean all` after the versionlock file is updated.

```puppet
class{'yum::plugin::versionlock':
  clean => true,
}
yum::versionlock { '0:bash-4.1.2-9.el6_2.*':
  ensure => present,
}
```

Note the CentOS 8 mechansim can be used if the parameter
`version` is also set to anything other than the default `undef`. This allows
common code to be used on CentOS  7 and 8 if the new style is used.

#### CentOS 8 and newer
Specify some of the version, release, epoch and arch values as parameters.

```puppet
yum::versionlock{'bash':
  ensure => present,
  version => '4.1.2',
  release => '9.el8.2.*',
  epoch   => 0,
  arch    => 'x86_64',
}
```

### Run a post transaction command
Specify a command to run after transactions of packages.

```puppet
yum::post_transaction_action{'touch_file':
  key     => 'openssh-*',
  command => 'touch /tmp/openssh-package-updated',
}
```

### Install or remove *yum* package group

Install yum [package groups][3].  To list groups: `yum group list`. Then use
that name in your puppet manifest. With support for install_options (e.g. enable
repos if disabled by default).

```puppet
yum::group { 'X Window System':
  ensure          => present,
  timeout         => 600,
  install_options => ['--enablerepo=*'];
}
```

### Install or remove packages via `yum install`

This is a workaround for [PUP-3323][4]. It enables the installation of packages
from non-repo sources while still providing dependency resolution. For example,
say there is a package *foo* that requires the package *bar*.  *bar* is in a Yum
repository and *foo* is stored on a stand-alone HTTP server.  Using the standard
providers for the `Package` resource type, `rpm` and `yum`, the `rpm` provider
would be required to install *foo*, because only it can install from a non-repo
source, i.e., a URL.  However, since the `rpm` provider cannot do dependency
resolution, it would fail on its own unless *bar* was already installed.  This
workaround enables *foo* to be installed without having to define its
dependencies in Puppet.

From URL:

```puppet
yum::install { 'package-name':
  ensure => present,
  source => 'http://example.com/path/to/package/filename.rpm',
}
```

From local filesystem:

```puppet
yum::install { 'package-name':
  ensure => present,
  source => 'file:///path/to/package/filename.rpm',
}
```

Reinstall if rpm-verify fails:

```puppet
yum::install { 'package-name':
  ensure => present,
  source => 'file:///path/to/package/filename.rpm',
  require_verify => true,
}
```

Please note that resource name must be same as installed package name.

### Manage DNF modules streams

> When changing from one enabled stream to another one, the provider runs `dnf module switch-to <Stream>`, which replaces all installed profiles from the DNF module. Bear the consequences in mind.

Enable default stream

```puppet
dnf_module_stream { '<Module>':
  stream => default,
}
```

Keep current enabled stream - if there isn't, enable default one

```puppet
dnf_module_stream { '<Module>':
  stream => present,
}
```

Enable a specific stream

```puppet
dnf_module_stream { '<Module>':
  stream => <Stream name>,
}
```

Disable stream (reset module)

```puppet
dnf_module_stream { '<Module>':
  stream => absent,
}
```

#### `dnf_module_stream` resource versus `dnfmodule` provider

[DNF modules](https://dnf.readthedocs.io/en/latest/modularity.html) is a feature from `yum` successor, `dnf`, which allows easier and more robust selections of software versions and collections.

As of Aug 22, 2023, [core Puppet `package` resource `dnfmodule` provider](https://www.puppet.com/docs/puppet/8/types/package.html#package-provider-dnfmodule) has some support for managing streams and profiles, but it has some issues:

1. Setting stream is mandatory when (un)installing profiles - No way of just keeping currently enabled stream
1. It only supports installing a single profile, despite the fact `dnf` supports multi-profile installations and there are use cases for that
1. Managing two things - streams setting and profile (un)installation - in the same resource invocation is inherently messy

One can fix 1 and 2, and add good docs to deal with 3. A compelling reason not to keep 1 and 3 is that a stream is a setting, not something one (un)installs. This makes it unsuitable for the `package` resource which, in principle, should only (un)install stuff.

So, while one fix 2, this custom resource aims to fully and better replace `dnfmodule` provider stream support.

### Puppet tasks

The module has a puppet task that allows to run `yum update` or `yum upgrade`.
This task needs puppet agent installed on the remote.

Please refer to the [Bolt documentation][5]
on how to execute a task.

```bash
$ bolt task show yum

yum - Allows you to perform yum functions

USAGE:
bolt task run --nodes <node-name> yum action=<value> [quiet=<value>]

PARAMETERS:
- action: Enum['update', 'upgrade']
    Action to perform
- quiet: Optional[Boolean]
    Run without output
```

### Fedora partial support

Support for fedora is minimal at this time. The yum class can be included
without error and resources such as `yum::group` can be managed. No repositories
or GPG keys are managed by default. Old kernel cleanup is known not to work, and
plugins may not work due to different package naming. Pull requests for
additional support would be welcomed.

---

This module was donated by CERIT Scientific Cloud, <support@cerit-sc.cz> to Vox Pupuli

[1]: https://puppet.com/docs/puppet/5.5/types/yumrepo.html
[2]: https://github.com/puppetlabs/puppetlabs-yumrepo_core
[3]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-working_with_package_groups
[4]: https://tickets.puppetlabs.com/browse/PUP-3323
[5]: https://puppet.com/docs/bolt/latest/bolt.html
