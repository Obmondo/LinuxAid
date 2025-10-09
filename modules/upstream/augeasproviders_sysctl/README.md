[![Build Status](https://github.com/voxpupuli/puppet-augeasproviders_sysctl/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_sysctl/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-augeasproviders_sysctl/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_sysctl/actions/workflows/release.yml)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-augeasproviders_sysctl/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-augeasproviders_sysctl)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/augeasproviders_sysctl.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_sysctl)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/augeasproviders_sysctl.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_sysctl)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/augeasproviders_sysctl.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_sysctl)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/augeasproviders_sysctl.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_sysctl)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-augeasproviders_sysctl)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-augeasproviders_sysctl.svg)](LICENSE)


# sysctl: type/provider for sysctl for Puppet

This module provides a new type/provider for Puppet to read and modify sysctl
config files using the Augeas configuration library.

The advantage of using Augeas over the default Puppet `parsedfile`
implementations is that Augeas will go to great lengths to preserve file
formatting and comments, while also failing safely when needed.

This provider will hide *all* of the Augeas commands etc., you don't need to
know anything about Augeas to make use of it.

## Requirements

Ensure both Augeas and ruby-augeas 0.3.0+ bindings are installed and working as
normal.

See [Puppet/Augeas pre-requisites](http://docs.puppetlabs.com/guides/augeas.html#pre-requisites).

## Documentation and examples

Type documentation can be generated with `puppet doc -r type` or viewed on the
[Puppet Forge page](http://forge.puppetlabs.com/puppet/augeasproviders_sysctl).


### manage simple entry

    sysctl { "net.ipv4.ip_forward":
      ensure => present,
      value  => "1",
    }

### manage entry with comment

    sysctl { "net.ipv4.ip_forward":
      ensure  => present,
      value   => "1",
      comment => "test",
    }

### delete entry

    sysctl { "kernel.sysrq":
      ensure => absent,
    }

### remove comment from entry

    sysctl { "kernel.sysrq":
      ensure  => present,
      comment => "",
    }

### manage entry in another sysctl.conf location

    sysctl { "net.ipv4.ip_forward":
      ensure => present,
      value  => "1",
      target => "/etc/sysctl.d/forwarding.conf",
    }

### do not update value with the `sysctl` command

    sysctl { "net.ipv4.ip_forward":
      ensure => present,
      value  => "1",
      apply  => false,
    }

### only update the value with the `sysctl` command, do not persist to disk

    sysctl { "net.ipv4.ip_forward":
      ensure  => present,
      value   => "1",
      persist => false,
    }

### ignore the application of a yet to be activated sysctl value

    sysctl { "net.ipv6.conf.all.autoconf":
      ensure => present,
      value  => "1",
      silent => true
    }

## Issues

Please file any issues or suggestions [on GitHub](https://github.com/voxpupuli/puppet-augeasproviders_sysctl/issues).

## Transfer Notice

This plugin was originally authored by [hercules-team](http://augeasproviders.com).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of hercules-team.

Previously: https://github.com/hercules-team/augeasproviders_sysctl
