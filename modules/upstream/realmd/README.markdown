[![Build Status](https://travis-ci.org/walkamongus/realmd.svg?branch=master)](https://travis-ci.org/walkamongus/realmd)

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

    class { '::realmd':
      domain               => 'example.com',
      domain_join_user     => 'user',
      domain_join_password => 'password',
    }

### Joining with a prepared computer account
1. Create the computer account by running adcli on *any* domain joined machine
  * new computer account: `/usr/sbin/adcli preset-computer --domain example.com`
  * or use an existing account: `/usr/sbin/adcli reset-computer --domain example.com`
2. Configure the realmd class

```
    class { '::realmd':
      domain             => $::domain,
      one_time_password  => 's3cure_pw', #optional, skip if you didn't specify it when running preset-computer# 
      #do not set domain_join_user
      #do not set krb_ticket_join
    }
```

#### Errors when running wio
1. `Error: adcli join ... returned 3 instead of one of [0]`

The account hasn't been prepared properly or the password is wrong

## Usage

Set up Realmd, join an Active Directory domain via a keytab and fully configure SSSD:

    class { '::realmd':
      domain             => $::domain,
      domain_join_user   => 'user',
      krb_ticket_join    => true,
      krb_keytab         => '/tmp/keytab',
      manage_sssd_config => true,
      sssd_config        => {
        'sssd' => {
          'domains'             => $::domain,
          'config_file_version' => '2',
          'services'            => 'nss,pam',
        },
        "domain/${::domain}" => {
          'ad_domain'                      => $::domain,
          'krb5_realm'                     => upcase($::domain),
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

## Reference

### Parameters

Default values are in params.pp.

* `realmd_package_name`: String. The name of the main Realmd package.
* `realmd_config_file`: String. The absolute path of the Realmd configuration file.
* `realmd_config`: Hash. A hash of configuration options structured in an ini-style format.
* `homedir_umask`: String. A string of the umask for the default directory permissions created by mkhomedir with Debian.
* `adcli_package_name`: String. The name of the adcli package
* `krb_client_package_name`: String. The name of the Kerberos client package.
* `sssd_package_name`: String. The name of the main SSSD package.
* `sssd_service_name`: String. The name of the SSSD service.
* `sssd_config_file`: String. The absolute path of the SSSD configuration file.
* `sssd_config`: Hash. A hash of configuration options structured in an ini-style format.
* `manage_sssd_config`: Boolean. Enable or disable management of the SSSD configuration file.
* `required_packages`: Hash. A hash of package resources to manage for any auxilliary functionality.
* `domain`: String. The name of the domain to join.
* `domain_join_user`: String. The account to be used in joining the domain.
* `domain_join_password`: String. The password of the account to be used in joining the domain.
* `one_time_password`: The password of the prepared computeraccount.
* `krb_ticket_join`: Boolean. Enable of disable joining the domain via a Kerberos keytab.
* `krb_keytab`: String. The absolute path to the Kerberos keytab file to be used in joining the domain.
* `krb_config_file`: String. The absolute path to the Kerberos client configuration file.
* `krb_config`: Hash. A hash of configuration options structured in an ini-style format.
* `manage_krb_config`: Boolean. Enable or disable management of the Kerberos client configuration file.

### Classes
* realmd::params
* realmd::istall
* realmd::config
* realmd::join
* realmd::join::password
* realmd::join::keytab
* realmd::join::one_time_password
* realmd::sssd::config
* realmd::sssd::service

## Limitations

This module requires Puppet >= 3.4.0 or Puppet Enterprise >= 3.2 due to it's use of the `contain` function. It has only been tested on RHEL/CentOS 7 and Debian Jessie 8
