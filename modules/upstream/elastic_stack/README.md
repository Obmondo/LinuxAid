# elastic_stack

[![Build Status](https://github.com/voxpupuli/puppet-elastic_stack/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-elastic_stack/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-elastic_stack/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-elastic_stack/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/elastic_stack.svg)](https://forge.puppetlabs.com/puppet/elastic_stack)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/elastic_stack.svg)](https://forge.puppetlabs.com/puppet/elastic_stack)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/elastic_stack.svg)](https://forge.puppetlabs.com/puppet/elastic_stack)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/elastic_stack.svg)](https://forge.puppetlabs.com/puppet/elastic_stack)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-elastic_stack)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-elastic_stack.svg)](LICENSE)
[![Donated by Elastic](https://img.shields.io/badge/donated%20by-Elastic-fb7047.svg)](#transfer-notice)

This module contains shared code for various modules to manage Elastic
products, like puppet-elasticsearch, puppet-logstash etc.

Version 8 and newer of this module are released by Vox Pupuli. They now follow
semantic versioning. Previously the module was maintained by Elastic.

## Setting up the Elastic package repository

This module can configure package repositories for Elastic Stack components.

Example:

```puppet
include elastic_stack::repo
```

You may wish to specify a major version, since each has its own repository:

```puppet
class { 'elastic_stack::repo':
  version => 5,
}
```

To access prerelease versions, such as release candidates, set `prerelease` to `true`.

```puppet
class { 'elastic_stack::repo':
  version    => 6,
  prerelease => true,
}
```

To access the repository for OSS-only packages, set `oss` to `true`.

```puppet
class { 'elastic_stack::repo':
  oss => true,
}
```

To use a custom package repository, set `base_repo_url`, like this:

```puppet
class { 'elastic_stack::repo':
  base_repo_url => 'https://mymirror.example.org/elastic-artifacts/packages',
}
```

## Transfer Notice

This module was originally authored by [Elastic](https://www.elastic.co).
The maintainer preferred that Vox Pupuli take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Elastic.
