# KubeAid Role (`role::kubeaid`)

## Overview

The `role::kubeaid` class integrates a LinuxAid-managed node into the
KubeAid Kubernetes platform ecosystem. It provisions the foundational
system baseline, automated monitoring, package repository management,
and system update schedules required for KubeAid host nodes.

## Included Components

When assigned to a host, `role::kubeaid` automatically includes:

- **`common::system`**: Configures core OS defaults, SSH security,
  NTP synchronization, firewall rules, and system update schedules.
- **Monitoring Baseline**: Deploys Prometheus node exporters and
  system health checks.
- **Package Repository Management**: Configures GPG-signed package
  repositories and air-gap mirror settings.

## Usage

Assign the role to a node via Hiera in `agents/<certname>.yaml`:

```yaml
classes:
  - role::kubeaid
```

## Parameters & Configuration

Configurations for the underlying system baseline are customized under
the `common::system` Hiera namespace:

```yaml
common::system::manage_sudo: true
common::system::enable_monitoring: true
```

## Related Documentation

- [KubeAid Documentation](https://github.com/Obmondo/KubeAid)
- [Basic Role](./basic.md)
- [Full Host Management](./full_host_management.md)
