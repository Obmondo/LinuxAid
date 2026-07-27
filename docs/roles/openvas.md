# OpenVAS Vulnerability Scanner Role (`role::scanner::openvas`)

## Overview

The `role::scanner::openvas` class deploys and configures the OpenVAS
(Greenbone Vulnerability Manager) vulnerability scanner on LinuxAid-managed
servers. It sets up vulnerability feed synchronization, web interfaces,
and optional HAProxy ingress proxying.

## Included Components

- **OpenVAS / Greenbone Services**: Vulnerability scanner daemon, manager,
  and vulnerability database feed update timers.
- **HAProxy Ingress Integration**: Optional SSL termination and reverse
  proxying for the Greenbone web portal.

## Usage

Assign the role to a node in its Hiera file (`agents/<certname>.yaml`):

```yaml
classes:
  - role::scanner::openvas
```

## Configuration

Customize feed sync and web portal options in Hiera:

```yaml
profile::scanner::openvas::enable_haproxy: true
profile::scanner::openvas::auto_update_feed: true
```

## Related Documentation

- [OpenVAS Setup Guide](../openvas-setup-guide.md)
- [Roles Reference](./README.md)
