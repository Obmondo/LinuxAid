# OpenSearch Dashboards Puppet Module
[![Build Status](https://github.com/voxpupuli/puppet-opensearch_dashboards/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-opensearch_dashboards/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-opensearch_dashboards/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-opensearch_dashboards/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/opensearch_dashboards.svg)](https://forge.puppetlabs.com/puppet/opensearch_dashboards)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/opensearch_dashboards.svg)](https://forge.puppetlabs.com/puppet/opensearch_dashboards)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/opensearch_dashboards.svg)](https://forge.puppetlabs.com/puppet/opensearch_dashboards)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/opensearch_dashboards.svg)](https://forge.puppetlabs.com/puppet/opensearch_dashboards)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-opensearch_dashboards)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-opensearch_dashboards.svg)](LICENSE)

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [The module manages the following](#the-module-manages-the-following)
1. [Usage](#usage)
    * [Basic usage](#Basic-usage)
    * [Use another version](#use-another-version-see-httpsopensearchorgdownloadshtml-for-valid-versions)
    * [Do not use default settings, only my settings](#do-not-use-default-settings-only-my-settings)
    * [Do not restart the service on package or configuration changes](#do-not-restart-the-service-on-package-or-configuration-changes)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This module sets up [OpenSearch Dashboards](https://opensearch.org/docs/latest/dashboards/index/).

## Setup

### The module manages the following

* package installation via archive, package, or repository
* configuration file
* service

## Usage

Some examples for the usage of the modules

### Basic usage

```puppet
class { 'opensearch_dashboards':
}
```

### Use another version (see https://opensearch.org/downloads.html for valid versions)

```puppet
class { 'opensearch_dashboards':
  version => '2.6.0',
}
```

### Customize settings

```puppet
class { 'opensearch_dashboards':
  settings => {
    'opensearch.hosts' => [
      'https://opensearch.example.com:9200',
    ],
  },
}
```

### Do not restart the service on package or configuration changes

```puppet
class { 'opensearch_dashboards':
  restart_on_package_changes => false,
  restart_on_config_changes  => false,
}
```

## Reference

Please see the [REFERENCE.md](https://github.com/voxpupuli/puppet-opensearch_dashboards/blob/master/REFERENCE.md)

## Limitations

This module is built upon and tested against the versions of Puppet listed in the metadata.json file (i.e. the listed compatible versions on the Puppet Forge).

## Development

Please see the [CONTRIBUTING.md](https://github.com/voxpupuli/puppet-opensearch_dashboards/blob/master/.github/CONTRIBUTING.md) file for instructions regarding development environments and testing.
