# rngd

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-rngd.svg?branch=master)](https://travis-ci.org/bodgit/puppet-rngd)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-rngd/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-rngd?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/rngd.svg)](https://forge.puppetlabs.com/bodgit/rngd)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-rngd.svg)](https://gemnasium.com/bodgit/puppet-rngd)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with rngd](#setup)
    * [Beginning with rngd](#beginning-with-rngd)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module manages rngd.

The module basically makes sure the rngd daemon is installed and started,
that's pretty much it. The rngd daemon does a good job at working out where
the source of hardware entropy is so there's little configuration required.

RHEL/CentOS, Ubuntu and Debian are supported using Puppet 4.4.0 or later.

## Setup

### Beginning with rngd

In the very simplest case, you can just include the following:

```puppet
include ::rngd
```

## Usage

For example to configure rngd to use `/dev/urandom` for random number input:

```puppet
class { '::rngd':
  hwrng_device => '/dev/urandom',
}
```

If you want to use something else to manage the rngd daemon, you can do:

```puppet
class { '::rngd':
  service_manage => false,
}
```

## Reference

The reference documentation is generated with
[puppet-strings](https://github.com/puppetlabs/puppet-strings) and the latest
version of the documentation is hosted at
[https://bodgit.github.io/puppet-rngd/](https://bodgit.github.io/puppet-rngd/).

## Limitations

This module has been built on and tested against Puppet 4.4.0 and higher.

The module has been tested on:

* RedHat Enterprise Linux 5/6/7
* Ubuntu 12.04/14.04/16.04
* Debian 6/7/8/9

## Development

The module has both [rspec-puppet](http://rspec-puppet.com) and
[beaker-rspec](https://github.com/puppetlabs/beaker-rspec) tests. Run them
with:

```
$ bundle exec rake test
$ PUPPET_INSTALL_TYPE=agent PUPPET_INSTALL_VERSION=x.y.z bundle exec rake beaker:<nodeset>
```

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-rngd).
