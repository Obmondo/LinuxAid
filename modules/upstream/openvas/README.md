# OpenVAS Puppet/OpenVox module

## Description

This module manages an OpenVAS (Greenbone Community Edition) deployment using
Docker Compose.

It creates and manages:

- OpenVAS compose directory and compose file
- Docker Compose stack lifecycle (`docker_compose { 'openvas': ... }`)
- Firewall rule for OpenVAS web interface exposure
- Docker engine and Docker Compose plugin (by default)

## Setup

### Setup requirements

- Puppet/OpenVox `>= 7.24 < 9.0.0`
- `puppetlabs/docker`
- `alexharvey/firewall_multi`
- `puppetlabs/firewall`
- `puppetlabs/stdlib`

### Beginning with openvas

```puppet
include openvas
```

## Usage

### Default usage

```puppet
include openvas
```

### Disable Docker management (if handled elsewhere)

```puppet
class { 'openvas':
  manage_docker => false,
}
```

### Install but keep web interface private

```puppet
class { 'openvas':
  install => true,
  expose  => false,
}
```

### Disable and remove managed resources

```puppet
class { 'openvas':
  install => false,
}
```

### Override compose settings

```puppet
class { 'openvas':
  compose_dir          => '/opt/openvas',
  feed_release         => '24.10',
  web_port             => 9392,
}
```

## Limitations

- Built and tested for Ubuntu (22.04, 24.04).
- This module assumes Docker engine and compose plugin are available via the
  dependency stack.

## Development

Run checks with PDK:

```bash
pdk validate
pdk test unit
```
