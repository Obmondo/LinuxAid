# puppet-beegfs

[![Puppet Forge](http://img.shields.io/puppetforge/v/deric/beegfs.svg)](https://forge.puppetlabs.com/deric/beegfs) [![Static & Spec Tests](https://github.com/deric/puppet-beegfs/actions/workflows/spec.yml/badge.svg)](https://github.com/deric/puppet-beegfs/actions/workflows/spec.yml) [![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/deric/beegfs.svg)](https://forge.puppetlabs.com/deric/beegfs/scores)

## Upgrade from `deric-beegfs` version `0.4.x` to `0.5.x`

- `beegfs::storage_directory` expects an Array instead of just String
- parameter `beegfs::major_version` renamed to `beegfs::release`
- `beegfs::client::client_udp` renamed to `beegfs::client::client_udp_port`


## Usage

First of all choose which release to use, by defining:
```yaml
beegfs::release: '6'
```
valid values are:

- `'2015.03'`
- `'6'`
- `'7'`
- `'7.1'`

You'll need one mgmtd server:

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

### Interfaces and networks

For meta and storage nodes you can specify interfaces for communication. The passed argument must be an array.

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

In some cases, interfaces can have multiple ips, and only a subset of them should be used.
In this case, the list of allowed subnets can be passed as the networks parameter. It should be an array if specified.

```puppet
class { 'beegfs::meta':
  mgmtd_host => 192.168.1.1,
  interfaces => ['eth0', 'ib0'],
  networks => ['192.168.1.0/24'],
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

 * Ruby 2.0 or newer
 * at least Puppet 4.9

## License

Apache License, Version 2.0

## Acceptance test

Run specific image using:
```
BEAKER_set=debian9-5.5 rake acceptance
```
debug mode:
```
BEAKER_debug=true rake acceptance
```
preserve Docker container after finising test:
```
$ BEAKER_destroy=no rake acceptance
$ docker exec -it 98aa06308c67 bash
$ /opt/puppetlabs/bin/puppet apply /tmp/apply_manifest.pp.OveoVG
```


## Rubocop

Update rubocop config with given target version:
```
 mry --target=0.70.0 .rubocop.yml
 ```
