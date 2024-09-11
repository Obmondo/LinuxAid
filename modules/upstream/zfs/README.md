# zfs

[![Build Status](https://img.shields.io/github/workflow/status/bodgit/puppet-zfs/Test)](https://github.com/bodgit/puppet-zfs/actions?query=workflow%3ATest)
[![Codecov](https://img.shields.io/codecov/c/github/bodgit/puppet-zfs)](https://codecov.io/gh/bodgit/puppet-zfs)
[![Puppet Forge version](http://img.shields.io/puppetforge/v/bodgit/zfs)](https://forge.puppetlabs.com/bodgit/zfs)
[![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/bodgit/zfs)](https://forge.puppetlabs.com/bodgit/zfs)
[![Puppet Forge - PDK version](https://img.shields.io/puppetforge/pdk-version/bodgit/zfs)](https://forge.puppetlabs.com/bodgit/zfs)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with zfs](#setup)
    * [What zfs affects](#what-zfs-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with zfs](#beginning-with-zfs)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module currently ensures that the ZFS packages available from
[zfsonlinux.org](http://zfsonlinux.org) are installed and configured.

RHEL/CentOS, Ubuntu and Debian are supported using Puppet 5 or later. On
RHEL/CentOS platforms there is support for installing the kABI-tracking kernel
modules as opposed to the default of DKMS-style kernel modules.

## Setup

### What zfs affects

This module will install kernel modules which utilises the DKMS framework to
accomplish this. This means kernel headers, toolchains, etc. will be installed.

### Setup Requirements

You will need pluginsync enabled. On RHEL/CentOS platforms you will need to
have access to the EPEL repository by using
[puppet/epel](https://forge.puppet.com/puppet/epel) or by other means to
use the DKMS-style kernel modules. On Debian you will need to enable
backports using
[puppetlabs/apt](https://forge.puppet.com/puppetlabs/apt) with something like:

```puppet
class { 'apt::backports':
  repos  => 'main contrib',
  pin    => 990,
  before => Class['zfs'],
}
```

### Beginning with zfs

In the very simplest case, you can just include the following:

```puppet
include zfs
```

## Usage

For example on RHEL/CentOS to instead install the kABI-tracking kernel modules
and tune the ARC, you can do:

```puppet
class { 'zfs':
  kmod_type   => 'kabi',
  zfs_arc_max => to_bytes('256 M'),
  zfs_arc_min => to_bytes('128 M'),
}
```

To also install the ZFS Event Daemon (zed):

```puppet
include zfs
include zfs::zed
```

## Reference

The reference documentation is generated with
[puppet-strings](https://github.com/puppetlabs/puppet-strings) and the latest
version of the documentation is hosted at
[https://bodgit.github.io/puppet-zfs/](https://bodgit.github.io/puppet-zfs/)
and available also in the [REFERENCE.md](https://github.com/bodgit/puppet-zfs/blob/main/REFERENCE.md).

## Limitations

This module has been built on and tested against Puppet 5 and higher.

The module has been tested on:

* Red Hat/CentOS Enterprise Linux 6/7/8
* Ubuntu 16.04/18.04/20.04
* Debian 9/10

## Development

The module relies on [PDK](https://puppet.com/docs/pdk/1.x/pdk.html) and has
both [rspec-puppet](http://rspec-puppet.com) and
[Litmus](https://github.com/puppetlabs/puppet_litmus) tests. Run them
with:

```
$ bundle exec rake spec
$ bundle exec rake litmus:*
```

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-zfs).
