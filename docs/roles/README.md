# Puppet Role Management System

## Overview

This document describes the role-based configuration management system that controls how hosts are managed and what settings are applied.

## Role Behavior

### No Role Selected

When no role is selected:
- **0 changes** are performed on the node
- The system operates in a passive state
- No configuration management occurs

### Available Roles

#### 1. **Monitoring Role** (`role::monitoring`)

The Monitoring role is designed for deploying monitoring infrastructure only.

**Characteristics:**
- Deploys **only** monitoring-related components
- Always runs in **Puppet noop mode ONLY**
- `full_host_management` is **disabled and cannot be forced** (hardcoded in the implementation)
- Minimal footprint for dedicated monitoring hosts

**Use Case:** Ideal for hosts that should only run monitoring agents without any other configuration management.

---

#### 2. **Basic Role** (`role::basic`)

The Basic role provides foundational host management with monitoring capabilities.

**Components:**
- `role::monitoring` - Monitoring setup
- Repository management
- System updates
- Custom certificates and system CA certificates

**Characteristics:**
- Runs in **noop mode** by default
- `full_host_management` is **enabled by default**
- Full management settings only take effect when running with `--no-noop` flag

**Use Case:** Suitable for hosts requiring basic system management and monitoring without extensive configuration.

---

#### 3. **Custom Roles** (Any Other Role)

When any custom role is selected, the system applies:
- All settings specific to the selected role
- **Plus** all settings from `role::basic`

This ensures a baseline configuration is always present alongside role-specific settings.

---

## Full Host Management Settings

The `full_host_management` parameter enables comprehensive configuration management across multiple system areas. When enabled and running in no-noop mode, the following settings are applied:

```yaml
common::repo::manage: true                    # Repository management
common::logging::manage: true                 # Logging configuration
common::backup::manage: true                  # Backup management
common::cron::purge_unmanaged: 'root-only'   # Cron job management
common::virtualization::manage: true          # Virtualization settings
common::network::manage: true                 # Network configuration
common::services::manage: true                # Service management
common::storage::manage: false                # Storage management (disabled)
common::system::manage: true                  # System-level configuration
common::security::manage: true                # Security settings
common::monitoring::manage: true              # Monitoring configuration
common::extras::manage: false                 # Extra features (disabled)
common::mail::manage: true                    # Mail configuration
```

### Important Notes

- `full_host_management` can be enabled for **any host**
- When enabled, the system operates in **noop mode** for that host (unless agent is run with --no-noop manually for now)
- Storage and extras management are disabled by default

---

## Monitoring Setup Behavior

### Subscription-Based Activation

- Monitoring infrastructure is **only deployed** when an active subscription exists
- The system will not set up monitoring components without a valid subscription (Open Source is enabled

### Subscription Expiration

When a subscription expires or becomes inactive:

**What Happens:**
- Monitoring setup is **NOT removed** from the host
- The monitoring infrastructure remains in place

**What Changes:**
- **Prometheus is disabled** automatically
- This prevents Obmondo from receiving metrics from the host

**Result:** The monitoring stack remains functional on the host but stops sending data to the central monitoring system.

---

## Usage Examples

### Monitoring-Only Host
```yaml
# Deploys only monitoring, always in noop mode
role: monitoring
```

### Basic Managed Host
```yaml
# Basic management with monitoring
role: basic
full_host_management: true
```

### Custom Role with Full Management
```yaml
# Custom role + basic + full management
role: webserver
full_host_management: true
```

---

## Mode of Operation

| Role | Default Mode | full_host_management | Can Force No-Noop? |
|------|-------------|---------------------|-------------------|
| None | N/A | N/A | N/A |
| `role::monitoring` | noop | Disabled (hardcoded) | No |
| `role::basic` | noop | Enabled | Yes (with `--no-noop`) |
| Custom roles | noop | Configurable | Yes (with `--no-noop`) |

---

## Best Practices

1. **Start with noop mode** - Always test configurations in noop mode before applying changes
2. **Enable full_host_management carefully** - Understand the scope of changes before enabling
3. **Monitor subscription status** - Keep track of subscription expiration to avoid unexpected monitoring disruptions
4. **Role composition** - Remember that custom roles inherit `role::basic` settings
5. **SSSD requirements** - Enable `full_host_management` if SSSD integration is needed

---

## Troubleshooting

### No changes being applied
- Check if a role is assigned to the node
- Verify whether you're running in noop mode
- Confirm `full_host_management` settings if applicable

### Monitoring data not appearing
- Check subscription status (active/expired)
- Verify pushprox is not disabled due to inactive subscription
- Confirm monitoring role or monitoring component is properly configured

---

## Support

For issues or questions regarding role management and configuration, please contact your system administrator or refer to the internal documentation portal.
