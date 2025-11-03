# Monitoring Role

The Monitoring role is designed for deploying monitoring infrastructure only.

**Characteristics:**
- Deploys **only** monitoring-related components
- Always runs in **Puppet noop mode ONLY**
- `full_host_management` is **disabled and cannot be forced** (hardcoded in the implementation)
- Minimal footprint for dedicated monitoring hosts

**Use Case:** Ideal for hosts that should only run monitoring agents without any other configuration management.
