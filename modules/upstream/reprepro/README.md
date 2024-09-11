puppet reprepro module
======================

### Warning

This module is no longer actively maintained. If you'd like to take over maintenance, please let me know. Patches may continue to be merged for the time being, but will take longer than usual.


This module assists with creating a local apt repository.

The only use-case it has been tested with has been to create a repository of pre-built packages. For example, I create a local repository of Puppet 2.7.x packages by downloading them from the official Puppet repository and then adding them to my local repo.

A Full Example
--------------
Using Puppet to create GPG keys is a bit complicated -- for example, the Puppet run could time out before the key is actually made. Because of this, I recommend creating the key manually:

```shell
$ su - reprepro
$ gpg --gen-key

# Configure as necessary.
# Note that you will have to maintain reprepro manually if you
# choose to use a passphrase.

$ gpg --export --armor foo@bar.com > /etc/puppet/modules/reprepro/files/localpkgs.gpg

# Alternatively, you can run the above commands as root and then later
# copy them to the reprepro user's home directory. This is a way to get
# around the chicken-and-egg scenario of having to create a key owned
# by a user that won't exist until after using the reprepro module.
```

The following is a full-stack example. This will create a reprepro-based repository, configure apache to allow access to the repository via http, and install the repository to your local apt configuration.

Once this is all set up, you can then add packages to `${basedir}/${repository}/tmp/${name}`. reprepro will install packages left in that directory into the repository every 5 minutes via cron.

```puppet
# Base Directory shortcut
$basedir = '/var/lib/apt/repo'

# Main reprepro class
class { 'reprepro':
  basedir => $basedir,
}

# Set up a repository
reprepro::repository { 'localpkgs':
  ensure  => present,
  basedir => $basedir,
  options => ['basedir .'],
}

# Create a distribution within that repository
reprepro::distribution { 'precise':
  basedir       => $basedir,
  repository    => 'localpkgs',
  origin        => 'Foobar',
  label         => 'Foobar',
  suite         => 'precise',
  architectures => 'amd64 i386',
  components    => 'main contrib non-free',
  description   => 'Package repository for local site maintenance',
  sign_with     => 'F4D5DAA8',
  not_automatic => 'No',
}

# Set up apache
class { 'apache': }

# Make your repo publicly accessible
apache::vhost { 'localpkgs':
  port           => '80',
  docroot        => '/var/lib/apt/repo/localpkgs',
  manage_docroot => false,
  servername     => 'apt.example.com',
  require        => Reprepro::Distribution['precise'],
}

# Ensure your public key is accessible to download
file { '/var/lib/apt/repo/localpkgs/localpkgs.gpg':
  ensure  => present,
  owner   => 'www-data',
  group   => 'reprepro',
  mode    => '0644',
  source  => 'puppet:///modules/reprepro/localpkgs.gpg',
  require => Apache::Vhost['localpkgs'],
}

# Set up an apt repo
apt::source { 'localpkgs':
  location    => 'http://apt.example.com',
  release     => 'precise',
  repos       => 'main contrib non-free',
  key         => 'F4D5DAA8',
  key_source  => 'http://apt.example.com/localpkgs.gpg',
  require     => File['/var/lib/apt/repo/localpkgs/localpkgs.gpg'],
  include_src => false,
}
```
Credits
-------
This module was based off of the existing work done by [saz](https://github.com/saz) and [camptocamp](https://github.com/camptocamp).
