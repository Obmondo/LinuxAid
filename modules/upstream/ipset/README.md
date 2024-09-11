# puppet-ipset

[![Build Status](https://travis-ci.org/voxpupuli/puppet-ipset.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-ipset)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/ipset.svg)](https://forge.puppetlabs.com/puppet/ipset)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/ipset.svg)](https://forge.puppetlabs.com/puppet/ipset)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/ipset.svg)](https://forge.puppetlabs.com/puppet/ipset)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/ipset.svg)](https://forge.puppetlabs.com/puppet/ipset)

## Table of Contents

* [Overview](#overview)
* [Usage](#usage)
  * [Array](#array)
  * [String](#string)
  * [Module file](#module-file)
  * [Local file](#local-file)
* [Reference](#reference)
* [Limitations](#limitations)
* [Changelog](#changelog)
* [Development and Contribution](#development-and-contribution)
* [Thanks](#thanks)

## Overview

This module manages Linux IP sets.

* Checks for current ipset state, before doing any changes to it.
* Applies ipset every time it drifts from target state,
  not only on config file change.
* Handles type changes.
* Autostart support for RHEL 6 and RHEL 7 family (upstart, systemd).

## Usage

### Array

IP sets can be filled from an array data structure.
Typically passed from Hiera.

```puppet
ipset { 'foo':
  ensure => present,
  set    => ['1.2.3.4', '5.6.7.8'],
  type   => 'hash:ip',
}
```

### String

You can also pass a pre-formatted string directly, using one entry per line
(with ``\n`` as a separator).
This pattern is practical when generating the IP set entries using a template.

```puppet
ipset { 'foo':
  ensure => present,
  set    => "1.2.3.4\n5.6.7.8",
  type   => 'hash:ip',
}
```

### Module file

IP sets content can also be stored in a module file:

```puppet
ipset { 'foo':
  ensure => present,
  set    => "puppet:///modules/${module_name}/foo.ipset",
}
```

### Local file

Or using a plain text file stored on the filesystem:

```puppet
file { '/tmp/bar_set_content':
  ensure  => present,
  content => "1.2.3.0/24\n5.6.7.8/32",
}

ipset { 'bar':
  ensure    => present,
  set       => 'file:///tmp/bar_set_content',
  type      => 'hash:net',
  subscribe => File['/tmp/bar_set_content'],
}
```

## Reference

The module uses puppet-strings for documentation. The result is the
[REFERENCE.md](REFERENCE.md) file.

## Limitations

* Tested on Debian and RedHat-like Linux distributions
* Only **hash** ipsets are supported (this excludes *bitmap* and *list:set*)

## Changelog

See [CHANGELOG](https://github.com/voxpupuli/puppet-ipset/blob/master/CHANGELOG.md)

## Development and Contribution

See [development](https://github.com/voxpupuli/puppet-ipset/blob/master/.github/CONTRIBUTING.md)

## Thanks

This module is a complete rewrite of [sl0m0ZA/ipset](https://github.com/sl0m0ZA/puppet-ipset),
which is a fork of [pmuller/ipset](https://forge.puppet.com/pmuller/ipset),
which was forked from [mighq/ipset](https://github.com/mighq/puppet-ipset),
which was based on [thias/ipset](https://github.com/thias/puppet-ipset).
