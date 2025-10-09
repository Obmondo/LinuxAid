# Opensearch Puppet Module
[![Build Status](https://github.com/voxpupuli/puppet-opensearch/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-opensearch/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-opensearch/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-opensearch/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/opensearch.svg)](https://forge.puppetlabs.com/puppet/opensearch)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/opensearch.svg)](https://forge.puppetlabs.com/puppet/opensearch)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/opensearch.svg)](https://forge.puppetlabs.com/puppet/opensearch)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/opensearch.svg)](https://forge.puppetlabs.com/puppet/opensearch)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-opensearch)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-opensearch.svg)](LICENSE)

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [The module manages the following](#the-module-manages-the-following)
    * [Requirements](#requirements-requirements)
1. [Usage](#usage)
    * [Basic usage](#Basic-usage)
    * [Use another version](#use-another-version-see-httpsopensearchorgdownloadshtml-for-valid-versions)
    * [Do not use default settings, only my settings](#do-not-use-default-settings-only-my-settings)
    * [Do not restart the service on package or configuration changes](#do-not-restart-the-service-on-package-or-configuration-changes)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This module sets up [Opensearch](https://opensearch.org/).

## Setup

### The module manages the following

* package installation via archive, package, or repository
* configuration file
* service

### Requirements

* modules:
  - [puppet/archive](https://forge.puppetlabs.com/puppet/archive)
  - [puppet/systemd](https://forge.puppetlabs.com/puppet/systemd)
  - [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

## Usage

Some exmaples for the usage of the modules

### Basic usage

```puppet
include opensearch
```

### Use another version (see https://opensearch.org/downloads.html for valid versions)

```puppet
class { 'opensearch':
  version => '2.6.0',
}
```

### Do not use default settings, only my settings

```puppet
class { 'opensearch':
  use_default_settings => false,
  settings             => {
    'valid_opensearch_key' => 'valid_value',
  },
}
```

### Do not restart the service on package or configuration changes

```puppet
class { 'opensearch':
  restart_on_package_changes => false,
  restart_on_config_changes  => false,
}
```

## Reference

Please see the [REFERENCE.md](https://github.com/voxpupuli/puppet-opensearch/blob/master/REFERENCE.md)

## Limitations

This module is built upon and tested against the versions of Puppet listed in the metadata.json file (i.e. the listed compatible versions on the Puppet Forge).

## Development

Please see the [CONTRIBUTING.md](https://github.com/voxpupuli/puppet-opensearch/blob/master/.github/CONTRIBUTING.md) file for instructions regarding development environments and testing.
