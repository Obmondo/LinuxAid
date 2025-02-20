# Puppet Realmd

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with realmd](#setup)
    * [What realmd affects](#what-realmd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with realmd](#beginning-with-realmd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module installs and configures Realmd and joins a domain. It will also optionally control the Kerberos client and SSSD configuration files and the SSSD service.

## Module Description

Realmd is a high-level tool for discovering and joining domains. It provides automatic base configuration of SSSD, nsswitch settings, and PAM configuration changes necessary for a Linux client to participate in an Active Directory domain.

This module will install the necessary Realmd packages and dependencies, configure Realmd, and join an Active Directory domain via one of two methods:

* Username and password
* Kerberos keytab file

It also optionally manages the contents of the Kerberos client configuration and SSSD configuration files.

## Setup

### What realmd affects

* Packages
    * Redhat Family
        * realmd
        * adcli
        * sssd
        * krb5-workstation
        * oddjob
        * oddjob-mkhomedir
    * Debian Family
        * adcli
        * krb5-user
        * sssd
        * sssd-tools
        * samba-common-bin
        * samba
        * libpam-modules
        * libpam-sss
        * libnss-sss
* Files
    * /etc/realmd.conf
    * /etc/sssd/sssd.conf
    * /etc/krb5.conf
    * /usr/share/pam-configs/realmd_mkhomedir (Debian Family)
* Services
    * sssd
* Execs
    * for username and password joins
        * the `realm join` command is run with supplied credentials
    * for keytab joins
        * the kerberos config file (/etc/krb5.conf) will be placed on disk
        * the `kinit` command is run to obtain an initial TGT
        * the `realm join` command is run to join via keytab
    * For Debian Family
        * triggers a pam-auth-update to activate the mkhomedir
    * the SSSD config cache is forcibly removed on each config change to ensure cache is rebuilt

### Setup Requirements

* Keytabs
    * this module does not manage keytabs -- the `krb_keytab` parameter is an absolute path to a keytab deployed in some way outside of this module

### Beginning with realmd

Setup realmd and join an Active Directory domain via username and password:

```pp
class { 'realmd':
  domain               => 'example.com',
  domain_join_user     => 'user',
  domain_join_password => 'password',
}
```

### Joining with a prepared computer account

1. Create the computer account by running adcli on *any* domain joined machine
   * new computer account: `adcli preset-computer --domain example.com`
   * or use an existing account: `adcli reset-computer --domain example.com`
2. Configure the realmd class
   ```pp
   class { 'realmd':
     domain             => $facts['networking']['domain'],
     one_time_password  => 's3cure_pw', # optional, skip if you didn't specify it when running preset-computer
     #do not set domain_join_user
     #do not set krb_ticket_join
   }
   ```

#### Errors when running

1. `Error: adcli join ... returned 3 instead of one of [0]`
    The account hasn't been prepared properly or the password is wrong

## Usage

### Setup Realmd, join an Active Directory domain via a keytab and fully configure SSSD:

```pp
class { 'realmd':
  domain             => $facts['networking']['domain'],
  domain_join_user   => 'user',
  krb_ticket_join    => true,
  krb_keytab         => '/tmp/keytab',
  manage_sssd_config => true,
  sssd_config        => {
    'sssd' => {
      'domains'             => $facts['networking']['domain'],
      'config_file_version' => '2',
      'services'            => 'nss,pam',
    },
    "domain/${facts['networking']['domain']}" => {
      'ad_domain'                      => $facts['networking']['domain'],
      'krb5_realm'                     => upcase($facts['networking']['domain']),
      'realmd_tags'                    => 'manages-system joined-with-adcli',
      'cache_credentials'              => 'True',
      'id_provider'                    => 'ad',
      'access_provider'                => 'ad',
      'krb5_store_password_if_offline' => 'True',
      'default_shell'                  => '/bin/bash',
      'ldap_id_mapping'                => 'True',
      'fallback_homedir'               => '/home/%u',
    },
  },
}
```

## Acknowledgements

This module was forked from [walkamongus-realmd] and _may not be compatible_.

[walkamongus-realmd]: https://github.com/walkamongus/realmd
