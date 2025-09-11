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

## Encrypting/Decrypting Secrets

We using [eyaml.sh](./bin/eyaml.sh) which is a wrapper of heira-eyaml to encrypt/decrypt secrets. You can check their [GitHub repo](https://github.com/voxpupuli/hiera-eyaml) for installation options.
Make sure that you've the public key present in `var/public_key.pkcs7.pem` in this respository. We already ignoring it in [.gitignore](./.gitignore).

### Examples

1. Encrypt some token

```sh
$ echo "ABCDEFGH-1234-1234-1234-ABCDEFGHIJKL" | ./bin/eyaml.sh
ENC[PKCS7,MIIBmQYJKoZIhvcNAQcDoIIBijCCAYYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAtT/+mI32f5VO2oDG7WmGAPmc5Ctt0rmtEsMLD2FAURZfI0m0C6w8ScwzdDEsC/C0ZOdQY6iE1sYgV74/i0mwHw4eqeIYJq4TgIJUXK/shAZSxdRGOdi7K5q0RhqPazss8MTA5vTe2/RQ0zv0sKpfFnzX14juSIVC/sKPo6KxjUDKIS/io+rEvFh1/EOr3RzpYNJT4iPD7r84ZNzwUoaTCcFtKFaxl0njfiVZBrbmgh+TJKSMs/gjI+QUXFrw4jn9zhHaHmRg0KhCc1pTudhCWZGv/6gA4JZWscgLKPspT5tMxo1NSMllCT3WD1HdcDygKPuElQQzxJ/zMLCvdlNQLTBcBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBDfc2XAbH8cZC432CAFko6NgDAo4xjSoC67caMck6rJEQP8f6kw90MFq5+ROXOpjLKbZdm6lZ8AFPdR1/3w4T7Pd1A=]
```
