# LinuxAid

## Setup Hiera for users

* Clone your [linuxaid-config](https://github.com/Obmondo/linuxaid-config-template.git)
to get the customerid, you will have to be a registered on obmondo.com

```sh
git clone https://github.com/Obmondo/linuxaid-config-template.git <customerid>
```

* Create the symlink under data/customers/\<customerid\>

```sh
ln -s  <customerid> data/customers/<customerid>
```

## Puppet roles logic

No role selected, 0 changes performed on the node

`full_host_management` settings can be enabled for any host, which will be setup in no-noop mode

```yaml
common::repo::manage: true
common::logging::manage: true
common::backup::manage: true
common::cron::purge_unmanaged: 'root-only'
common::virtualization::manage: true
common::network::manage: true
common::services::manage: true
common::storage::manage: false
common::system::manage: true
common::security::manage: true
common::monitoring::manage: true
common::extras::manage: false
common::mail::manage: true
```

* NOTE: if full_host_management is set to false and one enable sssd (we wont enable sssd, WHY ? cause sssd might need more things, which user might have not enabled and it might fail)

Monitoring(role::monitoring) role selected, only deploy monitoring related stuff (in puppet noop mode ONLY). no full_host_management and you can't even force this (since its hardcoded in the code)

Basic(role::basic) is mix of \[role::monitoring + repo management + system update + custom cert and system ca certs\] (noop mode) - full_host_management is enabled by default (but will only do anything in --no-noop)

Any role selected, we need to manage all the settings for the selected role + role::basic

Monitoring setup wont be setup, unless a subscription is added and after the subsription is expired/in-active, the monitoring setup won't be removed, but only it will disable pushprox (so obmondo does not receive metrics)

** Server Update logic
Pin OS Upgrade for RHEL/SUSE/Ubuntu

Which means RHEL 8.6 should be update within 8.6 repo and not with 8.7 repos and same goes for SUSE as well

Ubuntu stays on same release always - unless explicitly set for os_upgrade (ie. we point to f.ex 24.04 - and its currently running 22.04 - it'll change repos - and then next upgrade - will upgrade it to 24.04)

## Status

[Puppetboard](http://localhost:8000)
