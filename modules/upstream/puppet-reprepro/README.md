# reprepro puppet module

[![Build Status](https://travis-ci.org/cirrax/puppet-reprepro.svg?branch=master)](https://travis-ci.org/cirrax/puppet-reprepro)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cirrax/reprepro.svg?style=flat-square)](https://forge.puppetlabs.com/cirrax/reprepro)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/cirrax/reprepro.svg?style=flat-square)](https://forge.puppet.com/cirrax/reprepro)
[![Puppet Forge](https://img.shields.io/puppetforge/e/cirrax/reprepro.svg?style=flat-square)](https://forge.puppet.com/cirrax/reprepro)
[![Puppet Forge](https://img.shields.io/puppetforge/f/cirrax/reprepro.svg?style=flat-square)](https://forge.puppet.com/cirrax/reprepro)

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [PGP signing](#pgp-signing)
1. [Reference](#reference)
1. [Contribuiting](#contributing)
1. [Authors and Credits](#authors-and-credits)

## Overview

This module assists with creating a local apt repository using reprepro.

## Usage

Supports the followin usecases:
* create a local repository for uploading packages with dput
* create a local mirror of a repository (or part of a repository) eg. mirror of puppet packages from Puppetlabs.

### Example usage with hiera

This example creates a private repository and start apache to provide the apt repositories.

```puppet
include reprepro
include apache::vhosts
```

```yaml
reprepro::distributions_defaults:
  architectures: 'amd64 source'
  components: 'main'
  deb_indices: 'Packages Release . .gz .bz2 .xz'
  dsc_indices: 'Sources Release . .gz .bz2 .xz'
  # sign_with: '000000KEYID00000'  # see chapter PGP signing
  install_cron: false
  not_automatic: 'yes'

# create one or more repositories:
reprepro::repositories:
  localpkgs:
    options:
      - 'basedir .'
    distributions:
      local:
        origin: 'my-packages'
        description: 'whatever the description should describe'
        label: 'my-packages'
        suite: 'local'

apache::vhosts::vhosts:
  apt.example.com:
    port: '80'
    servername: apt.example.com
    docroot: '/var/www/apt.example.com'
```

### Example usage as puppet manifest
This example creates a private repository and start apache to provide the apt repositories.

```puppet
# Main reprepro class
class { 'reprepro':
  basedir => $basedir,
}

# Set up a repository
reprepro::repository { 'localpkgs':
  options => ['basedir .'],
}

# Create a distribution within that repository
reprepro::distribution { 'precise':
  repository    => 'localpkgs',
  origin        => 'Foobar',
  label         => 'Foobar',
  suite         => 'precise',
  architectures => 'amd64 i386',
  components    => 'main contrib non-free',
  description   => 'Package repository for local site maintenance',
  # sign_with   => '000000KEYID00000'  # see chapter PGP signing
  not_automatic => 'No',
  install_cron  => false,
}

# Set up apache
class { 'apache': }

# Make your repo publicly accessible
apache::vhost { 'localpkgs':
  port           => '80',
  docroot        => '/var/lib/apt/repo/localpkgs',
  manage_docroot => false,
  servername     => 'apt.example.com',
}
```

## PGP signing
If you like to use PGP (and you should do that !) to let reprepro sign the contents of your repositories you have to create and install
the PGP key to use manually. The following shell commands show howto create a PGP key for reprepro:

```shell
# become the reprepro user:
$ su - reprepro

# Create a pgp key:
$ gpg --gen-key --pinentry-mode loopback
```

Note: if you protect your key with a passphrase, you have to manage packages manually 
      in order to enter the passphrase.

Note2: --pinentry-mode loopback is needed since we used su to become the reprepro user.

By referencing the key ID with the parameter sign\_with of the distribution resources, reprepro will use the key to sign. 

## Reference
All classes and reources are documented in theire respective code file.
For information on classes, types and functions see the [REFERENCE.md](REFERENCE.md)

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.

## Authors and Credits

This module was based off of the existing work done by [saz](https://github.com/saz), [camptocamp](https://github.com/camptocamp)
and [desc](https://github.com/desc).

See the [list of contributors](https://github.com/cirrax/puppet-reprepro/graphs/contributors)
for a list of all contributors.
