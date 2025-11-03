## Full Management Host.

# Full Host Management Configuration

## Overview

Full host management in LinuxAid provides comprehensive control over Linux servers through Puppet. This document outlines what components are managed in **noop mode** (simulation only) versus **no-noop mode** (active changes applied).

## Configuration Matrix

### Management Status Table

| Component | Parameter | Enabled | Mode | What Gets Managed |
|-----------|-----------|---------|------|-------------------|
| **Repository Management** | `common::repo::manage` | ✅ Yes | No-noop | YUM/DNF/APT repositories, GPG keys, package sources, repository priorities |
| **Logging** | `common::logging::manage` | ✅ Yes | No-noop | Rsyslog/syslog forwarding, log rotation, journald settings, centralized logging |
| **Backup** | `common::backup::manage` | ✅ Yes | No-noop | Backup schedules, retention policies, backup scripts, storage locations |
| **Cron Jobs** | `common::cron::purge_unmanaged` | ⚙️ root-only | No-noop | Root user cron jobs (unmanaged jobs will be purged) |
| **Virtualization** | `common::virtualization::manage` | ✅ Yes | No-noop | KVM/QEMU settings, VMware Tools, VirtIO drivers, guest tools |
| **Network** | `common::network::manage` | ✅ Yes | No-noop | Network interfaces, routing tables, firewall rules, DNS settings |
| **Services** | `common::services::manage` | ✅ Yes | No-noop | System services (start/stop/enable), service dependencies, init scripts |
| **Storage** | `common::storage::manage` | ❌ No | Disabled | File systems, LVM, disk partitioning, mount points |
| **System** | `common::system::manage` | ✅ Yes | No-noop | Hostname, timezone, kernel parameters, system packages, OS settings |
| **Security** | `common::security::manage` | ✅ Yes | No-noop | Firewall, SELinux/AppArmor, SSH configuration, sudo rules, user accounts |
| **Monitoring** | `common::monitoring::manage` | ✅ Yes | No-noop | Monitoring agents, health checks, metrics collection, alerting |
| **Extra Features** | `common::extras::manage` | ❌ No | Disabled | Additional optional features and integrations |
| **Mail** | `common::mail::manage` | ✅ Yes | No-noop | Mail transfer agent (MTA), relay configuration, mail routing |

## Mode Definitions

### 🟢 No-noop Mode (Active Management)
When a component is enabled, Puppet **actively applies** all configuration changes to the host. Changes are immediately enforced and the system is brought into compliance with the desired state.

### 🔵 Noop Mode (Simulation)
Puppet only **simulates** changes and reports what would be changed without actually applying them. Useful for testing and validation.

### 🔴 Disabled
Component is not managed by Puppet at all. Manual configuration or other tools must be used.

## Detailed Component Breakdown

### 1. Repository Management
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Package repositories, GPG keys, mirror configurations |
| **Impact** | Controls where packages are installed from |
| **Risk Level** | Medium - can affect package availability |
| **Rollback** | Can revert repository configs via Puppet |

**Manages:**
- YUM/DNF repositories (RHEL/CentOS/Fedora/SLES)
- APT repositories (Debian/Ubuntu)
- Repository priorities and exclusions
- GPG key imports and validation

---

### 2. Logging Configuration
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Syslog, rsyslog, journald, log rotation |
| **Impact** | Controls log collection and forwarding |
| **Risk Level** | Low - doesn't affect application functionality |
| **Rollback** | Easy via Puppet configuration changes |

**Manages:**
- Centralized logging destinations
- Log retention and rotation policies
- Log format and filtering rules
- Remote syslog forwarding

---

### 3. Backup Management
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Backup jobs, schedules, retention |
| **Impact** | Ensures data protection compliance |
| **Risk Level** | Low - backup failures don't affect production |
| **Rollback** | Can adjust schedules and policies |

**Manages:**
- Backup tool installation and configuration
- Backup schedules (cron jobs)
- Retention policies
- Backup destination configuration

---

### 4. Cron Job Management
**Status:** ⚙️ Root-only purge (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Root user's crontab |
| **Impact** | Removes unauthorized scheduled tasks |
| **Risk Level** | Medium - can remove manually added cron jobs |
| **Rollback** | Must re-add via Puppet or restore from backup |

**Behavior:**
- Purges unmanaged cron jobs for root user only
- Other users' cron jobs are left untouched
- Ensures only Puppet-managed tasks run

---

### 5. Virtualization Settings
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Hypervisor tools, guest agents |
| **Impact** | Optimizes VM performance and integration |
| **Risk Level** | Low - improves VM functionality |
| **Rollback** | Can remove or update tools |

**Manages:**
- VMware Tools / open-vm-tools
- VirtIO drivers
- QEMU guest agent
- Hypervisor-specific optimizations

---

### 6. Network Configuration
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Network interfaces, routing, firewall |
| **Impact** | Controls network connectivity |
| **Risk Level** | **High** - can cause network outages |
| **Rollback** | May require console access if misconfigured |

**Manages:**
- Network interface configuration (IP, gateway, DNS)
- Static routes
- Firewall rules (iptables/firewalld/nftables)
- Network bonding and VLANs

**⚠️ WARNING:** Network changes can cause loss of connectivity. Test thoroughly before production deployment.

---

### 7. Service Management
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | System services (systemd/init) |
| **Impact** | Controls which services run |
| **Risk Level** | Medium-High - can stop critical services |
| **Rollback** | Can restart services via Puppet |

**Manages:**
- Service enable/disable state
- Service start/stop/restart
- Service dependencies
- Init scripts and systemd units

---

### 8. Storage Management
**Status:** ❌ Disabled

| Aspect | Details |
|--------|---------|
| **What's Managed** | Nothing - disabled |
| **Impact** | No automated storage management |
| **Risk Level** | N/A |
| **Manual Required** | Yes - manage manually or via other tools |

**NOT Managed:**
- Disk partitioning
- LVM configuration
- File system creation
- Mount points
- RAID configuration

**Managed:**
- ZFS scrub
- NFS mount
- Samba setup
- Filesystem Quota setup

**Reason for Disabling:** Storage changes are high-risk and typically require manual intervention.

---

### 9. System Configuration
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Hostname, timezone, kernel parameters |
| **Impact** | Core system settings |
| **Risk Level** | Medium - some changes require reboot |
| **Rollback** | Can revert via Puppet |

**Manages:**
- Hostname and domain name
- Timezone configuration
- Kernel parameters (sysctl)
- System packages
- OS-level settings

---

### 10. Security Settings
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Firewall, SELinux, SSH, sudo, users |
| **Impact** | Controls system access and security |
| **Risk Level** | **High** - can lock out users |
| **Rollback** | May require console access if misconfigured |

**Manages:**
- Firewall rules and policies
- SELinux/AppArmor policies
- SSH daemon configuration
- Sudo rules and policies
- User and group accounts
- Password policies

**⚠️ WARNING:** Security changes can lock you out. Always test with a backup access method.

---

### 11. Monitoring Configuration
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Monitoring agents and checks |
| **Impact** | Observability and alerting |
| **Risk Level** | Low - doesn't affect production workloads |
| **Rollback** | Easy via Puppet |

**Manages:**
- Monitoring agent installation (Nagios, Prometheus, etc.)
- Health check configuration
- Metrics collection
- Alert configuration

---

### 12. Extra Features
**Status:** ❌ Disabled

| Aspect | Details |
|--------|---------|
| **What's Managed** | Nothing - disabled |
| **Impact** | No additional features managed |
| **Risk Level** | N/A |
| **Manual Required** | Enable if needed |

**Purpose:** Placeholder for optional integrations and features not required for standard host management.

---

### 13. Mail Configuration
**Status:** ✅ Enabled (No-noop)

| Aspect | Details |
|--------|---------|
| **What's Managed** | Mail transfer agent (MTA) |
| **Impact** | System email delivery |
| **Risk Level** | Low - usually only affects system notifications |
| **Rollback** | Can reconfigure via Puppet |

**Manages:**
- MTA installation (Postfix, Exim, etc.)
- Mail relay configuration
- Mail routing rules
- SMTP authentication

---

## Risk Assessment Summary

### High Risk Components (Require Careful Testing)

| Component | Risk | Why |
|-----------|------|-----|
| **Network** | 🔴 High | Can cause complete loss of connectivity |
| **Security** | 🔴 High | Can lock out administrative access |
| **Services** | 🟡 Medium-High | Can stop critical applications |

### Medium Risk Components

| Component | Risk | Why |
|-----------|------|-----|
| **Cron** | 🟡 Medium | May remove manually added scheduled tasks |
| **System** | 🟡 Medium | Some changes may require reboot |
| **Repository** | 🟡 Medium | Can affect package availability |

### Low Risk Components

| Component | Risk | Why |
|-----------|------|-----|
| **Logging** | 🟢 Low | Doesn't affect application functionality |
| **Backup** | 🟢 Low | Failures don't impact production |
| **Monitoring** | 🟢 Low | Only affects observability |
| **Mail** | 🟢 Low | Only affects system notifications |
| **Virtualization** | 🟢 Low | Improves performance, minimal risk |

---

## Best Practices

### Before Enabling Full Host Management

1. **Test in Development First**
   - Deploy to test/dev environment
   - Validate all changes in noop mode
   - Monitor for issues

2. **Have Rollback Plan**
   - Document current configuration
   - Ensure console/OOB access available
   - Keep backup of critical configs

3. **Staged Rollout**
   - Start with low-risk components
   - Enable high-risk components last
   - Monitor each stage before proceeding

4. **Communication**
   - Notify stakeholders of changes
   - Schedule maintenance windows for risky changes
   - Document expected changes

## Configuration Example

```yaml
# Full host management with safe defaults
common::repo::manage: true
common::logging::manage: true
common::backup::manage: true
common::cron::purge_unmanaged: 'root-only'
common::virtualization::manage: true
common::network::manage: true                # ⚠️ TEST CAREFULLY
common::services::manage: true
common::storage::manage: false               # Disabled by default (high risk)
common::system::manage: true
common::security::manage: true               # ⚠️ TEST CAREFULLY
common::monitoring::manage: true
common::extras::manage: false                # Disabled by default (not needed)
common::mail::manage: true
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Lost network connectivity | Network config error | Use console access to revert changes |
| Locked out of SSH | Security policy too strict | Use console to adjust SSH/firewall rules |
| Services not starting | Service dependency issue | Check Puppet logs and service status |
| Cron jobs disappeared | Purged by Puppet | Add jobs to Puppet configuration |

### Recovery Steps

1. **Access via Console**: Use out-of-band management (iLO, iDRAC, KVM)
2. **Check Puppet Logs**: journalctl -u run-puppet
3. **Run Puppet Manually**: `puppet agent -t --noop` to see what would change
4. **Disable Puppet Agent**: `puppet agent --disable` to prevent further changes
5. **Revert Configuration**: Update Hiera and re-run Puppet

---

## Summary

Full host management provides comprehensive control but requires careful planning. Start with low-risk components, test thoroughly, and always maintain a rollback plan. The configuration matrix above helps you understand what will be actively managed when full host management is enabled.
