# puppet-beegfs



[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/beegfs.svg)](https://forge.puppetlabs.com/deric/beegfs) [![Build Status](https://travis-ci.org/deric/puppet-beegfs.svg?branch=master)](https://travis-ci.org/deric/puppet-beegfs) [![Puppet Forge
Downloads](http://img.shields.io/puppetforge/dt/deric/beegfs.svg)](https://forge.puppetlabs.com/deric/beegfs/scores)

## Usage

You need one mgmtd server:

```puppet
class { 'beegfs::mgmtd': }
```
in order to accept new storage and meta servers you have to (at least temporarily) enable `allow_new_servers` and `allow_new_targets`.

And probably many storage and meta servers:
```puppet
class { 'beegfs::meta':
  mgmtd_host => 192.168.1.1,
}
class { 'beegfs::storage':
  mgmtd_host => 192.168.1.1,
}
```
It's easier to define shared settings for all servers at one place (Hiera, e.g. `default.yaml`):

```
beegfs::mgmtd_host: '192.168.1.1'
```
so that you don't have to specify `mgmtd_host` for each component.

defining a mount
```puppet
beegfs::mount{ 'mnt-share':
  cfg => '/etc/beegfs/beegfs-client.conf',
  mnt   => '/mnt/share',
  user  => 'beegfs',
  group => 'beegfs',
}
```

### Interfaces

For meta and storage nodes you can specify interfaces for commutication. The passed argument must be an array.

```puppet
class { 'beegfs::meta':
  mgmtd_host => 192.168.1.1,
  interfaces => ['eth0', 'ib0'],
}
class { 'beegfs::storage':
  mgmtd_host => 192.168.1.1,
  interfaces => ['eth0', 'ib0']
}
```

### Initialization

#### mgmtd

If `beegfs::allow_first_run_init` is `true` you may skip this step.

```sh
beegfs-setup-mgmtd -p /mnt/myraid1/beegfs-mgmtd
```

#### meta

If `beegfs::allow_first_run_init` is `true` you may skip this step.

##### Example 1

Initialize metadata storage directory of first metadata server and set
"storage01" as management daemon host in config file:

```sh
beegfs-setup-meta -p /mnt/myraid1/beegfs-meta -s 1 -m storage01
```

## Hiera support

All configuration could be specified in Hiera config files. Some settings
are shared between all components, like:

```yaml
beegfs::mgmtd_host: '192.168.1.1'
beegfs::mgmtd::allow_new_servers: true
beegfs::mgmtd::allow_new_targets: true
beegfs::release: 6
```

version could be also defined exactly, like:
```yaml
beegfs::version: '2015.03.r9.debian7'
```

for module specific setting use correct namespace, e.g.:
```yaml
beegfs::meta::interfaces:
  - 'eth0'
```

Recent releases of Linux Kernel might include "deterministic interfaces naming" (like `enp0s31f6`) that requires specifying which interface should be BeeGFS instances using:

```yaml
beegfs::client::interfaces:
  - "%{facts.networking.primary}"
beegfs::meta::interfaces:
  - "%{facts.networking.primary}"
beegfs::storage::interfaces:
  - "%{facts.networking.primary}"
```

## Requirements

 * Ruby 1.9 or newer
 * at least Puppet 4.0 and < 6.0

## License

Apache License, Version 2.0
