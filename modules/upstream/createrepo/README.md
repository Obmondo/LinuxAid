# createrepo

[![Puppet Forge](http://img.shields.io/puppetforge/v/palli/createrepo.svg)](https://forge.puppetlabs.com/palli/createrepo)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/palli/createrepo.svg)](https://forge.puppetlabs.com/palli/createrepo)
[![Build Status](https://travis-ci.org/pall-valmundsson/puppet-createrepo.png)](https://travis-ci.org/pall-valmundsson/puppet-createrepo)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with createrepo](#setup)
    * [What createrepo affects](#what-createrepo-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with createrepo](#beginning-with-createrepo)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Regarding checksums](#regarding-checksums)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [Running tests](#running-tests)
7. [Issues](#issues)


## Overview

The createrepo module allows you to create and update yum repositories.

*Breaking changes*: Version 3.0.0 changes the `enable_cron` setting. If set to `false` the cron job will not be created and an update _will not be performed on agent runs_. An option to update on agent runs `enable_update` is introduced to re-enable this functionality. If you were setting `enable_cron` to `false` then you need to set `enable_update` to `true` to maintain the same functionality.

## Module Description

Yum repositories are a distribution method for RPM packages usually served via HTTP. The createrepo module creates yum repositories and it's metadata caches.
It also provides mechanisms to update the repositories with an optional cron job and an update script, which is useful for post hooks in CI environments.

It does not manage the directory tree up to the root of the repository and does neither make any attempt to manage a HTTP server for repository clients.

## Setup

### What createrepo affects

* repository and cache directories
* createrepo package
* cron jobs for repo updates (optional)
* an update script, placed in /usr/local/bin by default

### Beginning with createrepo

Basic example:

```puppet
    createrepo { 'yumrepo':
        repository_dir => '/var/yumrepos/yumrepo',
        repo_cache_dir => '/var/cache/yumrepos/yumrepo'
    }
```

## Usage

The module provides a single `define` so as many repositories can be created as needed, usually at least stable and testing repos are created.

### Regarding checksums

Older versions of yum do not support some later default checksum types. From the `createrepo` man page:

    Choose  the  checksum  type used in repomd.xml and for packages in the metadata.  The default is now
    "sha256" (if python has hashlib). The older default was "sha", which is actually "sha1", however explicitly
    using "sha1" doesn’t work on older (3.0.x) versions of yum, you need to specify "sha".

`createrepo` provides a checksum_type parameter to change the checksum type.

### Parameters

#### `repository_dir`

The path to the base directory of the repository. Here, or in subdirectories
you store the .rpm files

- *Default*: `/var/yumrepos/${name}`

#### `repo_cache_dir`

Path to a checksum directory. Makes updates to repository much faster.

- *Default*: `/var/cache/yumrepos/${name}`

#### `repo_owner`

Owner of the repository directory.

- *Default*: `root`

#### `repo_group`

Group of the repository directory.

- *Default*: `root`

#### `repo_mode`

Mode of the repository directory.

- *Default*: '0775'

#### `repo_recurse`

Enable recursive managing of the repository directory.

- *Default*: false

#### `repo_ignore`

Ignore-list for recursive managing of the repository directory.

- *Default*: undef

#### `repo_seltype`
Set the SELinux type for the repository directory.

- *Default*: `httpd_sys_content_t`

#### `enable_cron`

Enable regular repository updates via cron.

- *Default*: `true`

#### `enable_update`

Enable automatic repository updates during the puppet run.

- *Default*: `false`

#### `cron_minute`

Minute parameter for cron metadata update job.

- *Default*: `*/10`

#### `cron_hour`

Hour parameter for cron metadata update job.

- *Default*: `*`

#### `changelog_limit`

Number of changelog entries to import into metadata.

- *Default*: `5`

#### `checksum_type`

Sets the checksum type for repomd.xml. This needs to be set to `sha` if `createrepo` is defined on a RHEL/CentOS 6 host and is accessed by RHEL/CentOS 5 or earlier clients.

- *Default*: `undef`

#### `update_file_path`

Location of the repository update script file.

- *Default*: `/usr/local/bin/createrepo-update-${name}`

#### `suppress_cron_stdout`

Redirect stdout output from cron to /dev/null.

- *Default*: `false`

#### `suppress_cron_stderr`

Redirect stderr output from cron to /dev/null.

- *Default*: `false`

#### `workers`

Number of workers to spawn to read RPMs.

- *Default*: `undef`

#### `groupfile`

Yum repository groupfile. Creates the repository metadata with supplied group information.

- *Default*: `undef`

#### `timeout`

Exec timeout for createrepo commands. Can be useful when repositories are huge. Can even be set to 0 to disable timeouts.

- *Default*: `300`

#### `manage_repo_dirs`
Manage the repository directory. If false the repository and cache directories must be created manually/externally.

- *Default*: `true`

#### `cleanup`
Should the cron/script clean up old rpm versions for each rpm?

- *Default*: `false`

#### `cleanup_keep`
Set how many versions of each rpm to keep.

- *Default*: `2`

### `use_lockfile`
Prevents corruption of the repodata, when multiple createrepo processes
start building repodata at the same time. (eg in combination with incrond)

- *Default*: `false`

### `lockfile`
full path/name of the lockfile

- *Default*: `/tmp/createrepo-update-${name}.lock`

### `createrepo_package`
Name of the `createrepo` package and command to use. Can be used to use `/usr/bin/createrepo_c` instead of
`/usr/bin/createrepo`.

- *Default*: `createrepo`

### `createrepo_cmd`
The path of the createrepo binary to use. Allows, combined with setting
`createrepo_package`, to select `/usr/bin/createrepo_c` instead of `/usr/bin/createrepo`.

- *Default*: `/usr/bin/createrepo`

## Reference

See [Usage](#usage)

## Limitations

createrepo is rspec tested on Puppet 3.8-4.x latest and beaker tested on CentOS 6, 7 and Ubuntu 14.04 with Puppet latest.

## Development

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and
   it's great to know that you have a clean slate

3. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

4. Make the test pass.

5. Push to your fork and submit a pull request.

### Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information please see their respective documentation.

Quickstart:

    gem install bundler
    bundle install
    bundle exec rake spec
    bundle exec rspec spec/acceptance
    BEAKER_debug=yes bundle exec rspec spec/acceptance
    BEAKER_set=centos-70-x64 bundle exec rspec spec/acceptance
    BEAKER_set=debian-78-x64 bundle exec rspec spec/acceptance

## Issues

Please log tickets and issues in the createrepo [GitHub issue tracker](https://github.com/pall-valmundsson/puppet-createrepo/issues)
