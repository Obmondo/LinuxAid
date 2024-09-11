# borg backup puppet module

[![Build Status](https://travis-ci.org/cirrax/puppet-borgbackup.svg?branch=master)](https://travis-ci.org/cirrax/puppet-borgbackup)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cirrax/borgbackup.svg?style=flat-square)](https://forge.puppetlabs.com/cirrax/borgbackup)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/cirrax/borgbackup.svg?style=flat-square)](https://forge.puppet.com/cirrax/borgbackup)
[![Puppet Forge](https://img.shields.io/puppetforge/e/cirrax/borgbackup.svg?style=flat-square)](https://forge.puppet.com/cirrax/borgbackup)
[![Puppet Forge](https://img.shields.io/puppetforge/f/cirrax/borgbackup.svg?style=flat-square)](https://forge.puppet.com/cirrax/borgbackup)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup)


#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Contributing](#contributing)


## Overview

Configure [borg](http://borgbackup.readthedocs.io/en/stable/) backups and gives you the option to store
passphrase and keyfile needed for encrypted backups in a git repository. The content of the git repository is
encrypted with gpg keys (configurable) for security.

## Usage

For typical usage of this module you configure two nodes. One node to backup and another as the target where the
backup should be stored. Below is a minimal configuration.

### the node to backup (node-A)

In the nodes manifest:

    include ::borgbackup

The hiera configuration for the node:

    # the resource to use for ssh key generation and the parameters:
    borgbackup::ssh_key_define: 'file'
    borgbackup::ssh_key_res:
      '/etc/borgbackup/.ssh/id_rsa':
          owner: 'root'
          group: 'root'
          mode: '0700'
          content: 'key_data'

    # specify the target node for the backup:
    borgbackup::default_target: "borgbackup@node-target:/srv/borgbackup/%{::fqdn}"

    # specify the ssh key to access node-target:
    borgbackup::repos_defaults:
      env_vars:
        BORG_RSH: 'ssh -i /etc/borgbackup/.ssh/id_rsa'

To add an archive to the default borg repo (named $::fqdn) use

    ::borgbackup::archive{'my_archive':
      create_includes = ['/etc'],
    }

### the target node (node-target)

    include ::borgbackup::server

The hiera configuration for the node:

    # authorize the key generated on node-A for backup
    borgbackup::server::authorized_keys:
      node-A:
        keys:
           - 'ssh-... .... borg backups'

*Remark:* the initialization of the borg backup repository fails until you configured the ssh key on node-target.

### use a remote git repository 
To store the generated passphrase and the keyfile in a secure and automated manner, you can use a git repository.
Add the following hiera configuration to node-A to fetch and commit to remote gitrepo on node-git:

    # the git repo to clone and commit
    borgbackup::git::gitrepo: 'user@node-git:/path-to-repo'
    # ssh private key to access the git repo. This key should only have  access to this repo !
    borgbackup::git::gitrepo_sshkey: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      ...
      -----END OPENSSH PRIVATE KEY-----
    
    # add pgp public keys of users who should be able to decrypt the passphrase and the keyfile.
    # to export use:
    # gpg --export --armor --export-options no-export-attributes,export-minimal ID
    borgbackup::git::gpg_keys:
      ID-of-user-1: |
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        ...
      ID-of-user-2: |
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        ...

*Remark:* if you add or delete gpg_keys, the repository should automatically reencrypt and push to the git repository.

*Remark:* ID-of-user should point to the main email of the pgp key. If you see runing reencrypt with each puppet run on
the nodes, then the ID-of-user is probably wrong.

## Reference

All classes and defines are documented with all parameters in the corresponding code file.

### classes
* [::borgbackup](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_classes/borgbackup)
* [::borgbackup::git](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_classes/borgbackup_3A_3Agit)
* [::borgbackup::install](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_classes/borgbackup_3A_3Ainstall)
* [::borgbackup::server](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_classes/borgbackup_3A_3Aserver)


### defined typed
* [::borgbackup::addtogit](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_defined_types/borgbackup_3A_3Aaddtogit)
* [::borgbackup::archive](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_defined_types/borgbackup_3A_3Aarchive)
* [::borgbackup::authorized_key](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_defined_types/borgbackup_3A_3Aauthorized_key)
* [::borgbackup::repo](http://www.puppetmodule.info/github/cirrax/puppet-borgbackup/master/puppet_defined_types/borgbackup_3A_3Arepo)

## Contributing

Please report bugs and feature request using GitHub issue tracker.

For pull requests, it is very much appreciated to check your Puppet manifest with puppet-lint
and the available spec tests  in order to follow the recommended Puppet style guidelines
from the Puppet Labs style guide.

### Authors

This module is mainly written by [Cirrax GmbH](https://cirrax.com).

See the [list of contributors](https://github.com/cirrax/puppet-borgbackup/graphs/contributors)
for a list of all contributors.
