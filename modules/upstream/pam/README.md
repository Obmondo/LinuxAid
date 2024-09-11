# puppet-module-pam

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with pam](#setup)
   * [What pam affects](#what-pam-affects)
   * [Setup requirements](#setup-requirements)
   * [Beginning with pam](#beginning-with-pam)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Module description

This module manages PAM including accesslogin and limits.conf with
functionality to create limits fragments for use in other modules. There
are examples for using this with VAS/QAS.

## Setup

### What pam affects

Manages the packages and files regarding PAM. These vary by platform
though generally include things such as the following.

* `/etc/pam.conf`
* `/etc/pam.d`
* `/etc/security/access.conf`
* `/etc/security/limits.conf`
* `/etc/security/limits.d`

The management of `/etc/security/access.conf` can be controlled by the
`pam::manage_accesslogin` parameter (enabled by default).

The management of `/etc/security/faillock.conf` can be controlled by the
`pam::manage_faillock` parameter (disabled by default).

The management of `/etc/security/pwquality.conf` and `/etc/security/pwquality.conf.d`
can be controlled by the `pam::manage_pwquality` parameter (disabled by default).

### Setup requirements
This module requires `stdlib`. When deployed by default it will require
`nsswitch`. See below for more information.

#### Optional

##### nsswitch

By default this module will include the `nsswitch` class with the
settings `pam::manage_nsswitch`. This module is meant to be used with
the Approved [nsswitch](https://github.com/trlinkin/puppet-nsswitch)
module.

##### SSSD

This module has been deployed in production along with
[sgnl05/sssd](https://github.com/sgnl05/sgnl05-sssd). Please see
`examples/hiera/sssd/RedHat-6.yaml` file for an example with the
additional SSSD entries added via hiera.

### Beginning with pam

Include the main `pam` class.

#### Specifying the allowed users

##### Example using an array

As an array where the origin for each is 'ALL'.

```yaml
pam::allowed_users:
  - root
  - ops
  - devs
```

This would create `/etc/security/access.conf` with the following content.

```
# This file is being maintained by Puppet.
# DO NOT EDIT
#

# allow only the groups listed
+:root:ALL
+:ops:ALL
+:devs:ALL

# default deny
-:ALL:ALL
```

##### Example using a hash

As a hash where the user/group can optionally specify the origin.

```yaml
pam::allowed_users:
  'username':
  'username1':
    - 'cron'
    - 'tty0'
  'username2': 'tty1'
```

This would create `/etc/security/access.conf` with the following content.

```
# This file is being maintained by Puppet.
# DO NOT EDIT
#

#allow only the groups listed
+:username:ALL
+:username1:cron tty0
+:username2:tty1

# default deny
-:ALL:ALL
```

#### Setting limits
##### Example:

```yaml
pam::limits_fragments:
  custom:
    list:
      - '* soft nofile 2048'
      - '* hard nofile 8192'
      - '* soft as 3145728'
      - '* hard as 4194304'
      - '* hard maxlogins 300'
      - '* soft cpu 720'
      - '* hard cpu 1440'
```

This would create `/etc/security/limits.d/custom.conf` with content

```
# This file is being maintained by Puppet.
# DO NOT EDIT
* soft nofile 2048
* hard nofile 8192
* soft as 3145728
* hard as 4194304
* hard maxlogins 300
* soft cpu 720
* hard cpu 1440
```

The parameter `pam::limits_fragments_hiera_merge` can be set to `true` to allow Hiera to define and merge limits from multiple locations.  Example:

```yaml
# data/common.yaml
---
pam::limits_fragments_hiera_merge: true
pam::limits_fragments:
  custom:
    list:
      - '* soft nofile 2048'
      - '* hard nofile 8192'
# data/os/RedHat/8.yaml
---
pam::limits_fragments:
  custom:
    list:
      - '* soft as 3145728'
      - '* hard as 4194304'
```

The contents of `/etc/security/limits.d` can optionally be purged of unmanaged files.

```yaml
pam::limits::purge_limits_d_dir: true
```

Below is an example of ignoring certain files from the limits.d purge:

```yaml
pam::limits::purge_limits_d_dir_ignore: 'ignore*.conf'
```

The ignore can also be an Array of file names

```yaml
pam::limits::purge_limits_d_dir_ignore:
  - custom.conf
  - foo.conf
```

#### Specifying the content of a service
Manage PAM file for specific service.

##### Example:
You can specify a hash to manage the services in Hiera

```yaml
pam::services:
  'sudo':
    content : 'auth     required       pam_unix2.so'
```

#### Manage faillock

Management of faillock and faillock.conf is enabled via `pam::manage_faillock`.

The following example would enable faillock, configure it, and add it to the PAM stack.

```yaml
pam::manage_faillock: true
pam::faillock::deny: 3
pam::pam_auth_lines:
  - 'auth        required      pam_env.so'
  - 'auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900'
  - 'auth        sufficient    pam_unix.so try_first_pass nullok'
  - 'auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900'
  - 'auth        required      pam_deny.so'
pam::pam_account_lines:
  - 'account     required      pam_faillock.so'
  - 'account     required      pam_unix.so'
pam::pam_password_auth_lines:
  - 'auth        required      pam_env.so'
  - 'auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900'
  - 'auth        sufficient    pam_unix.so try_first_pass nullok'
  - 'auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900'
  - 'auth        required      pam_deny.so'
pam::pam_password_account_lines:
  - 'account     required      pam_faillock.so'
  - 'account     required      pam_unix.so'
```

#### Manage pwquality

Management of pwquality and pwquality.conf is enabled via `pam::manage_pwquality`.

The following example would enable pwquality, configure it, and add it to the PAM stack.

```yaml
pam::manage_pwquality: true
pam::pwquality::retry: 3
pam::pwquality::maxclassrepeat: 4
pam::pwquality::maxrepeat: 3
pam::pwquality::minclass: 4
pam::pwquality::difok: 8
pam::pwquality::minlen: 15
pam::pam_password_lines:
  - 'password    requisite     pam_pwquality.so try_first_pass local_users_only difok=3 minlen=15 dcredit= 2 ocredit=2'
  - 'password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow'
  - 'password    required      pam_deny.so'
pam::pam_password_password_lines:
  - 'password    requisite     pam_pwquality.so try_first_pass local_users_only difok=3 minlen=15 dcredit= 2 ocredit=2'
  - 'password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow'
  - 'password    required      pam_deny.so'
```

## Usage

Minimal and normal usage.

```puppet
include pam
```

## Limitations

This module has been tested to work on the following systems with Puppet
versions 7 and 8 with the Ruby version associated with those releases.
Please see `.github/workflows/ci.yaml` for a full matrix of supported versions. This
module aims to support the current and previous major Puppet versions.

 * EL 7
 * EL 8
 * EL 9
 * Amazon Linux 2
 * Debian 10
 * Debian 11
 * Ubuntu 20.04 LTS
 * Ubuntu 22.04 LTS

### May work

These platforms have spec tests and have been verified in the past,
though are not functionally tested and formally supported.

The Hiera data for some of these platforms can be found in `examples/hiera/eol`.

 * EL 5
 * EL 6
 * Solaris 9
 * Solaris 10
 * Solaris 11
 * Suse 9
 * Suse 10
 * Suse 11
 * Suse 12
 * Suse 15
 * OpenSuSE 13.1
 * Debian 7
 * Debian 8
 * Debian 9
 * Ubuntu 12.04 LTS
 * Ubuntu 14.04 LTS
 * Ubuntu 16.04 LTS
 * Ubuntu 18.04 LTS

## Development

See `CONTRIBUTING.md` for information related to the development of this
module.
