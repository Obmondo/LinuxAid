[![License](https://img.shields.io/:license-apache-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/auditd.svg)](https://forge.puppetlabs.com/simp/auditd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/auditd.svg)](https://forge.puppetlabs.com/simp/auditd)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-auditd.svg)](https://travis-ci.org/simp/pupmod-simp-auditd)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
  * [What Auditd Affects](#what-auditd-affects)
* [Usage](#usage)
  * [Basic Usage](#basic-usage)
  * [Disabling Auditd](#disabling-auditd)
  * [Changing Key Values](#changing-key-values)
  * [Understanding Auditd Profiles](#understanding-auditd-profiles)
    * [Stacking Profiles](#stacking-profiles)
    * [The Custom Profile](#the-custom-profile)
      * [Override All Other Profiles](#override-all-other-profiles)
      * [Prepend Before the SIMP Profile](#prepend-before-the-simp-profile)
      * [Append After the SIMP and STIG Profiles](#append-after-the-simp-and-stig-profiles)
  * [Adding One-Off Rules](#adding-one-off-rules)
    * [Adding Regular Filter Rules](#adding-regular-filter-rules)
    * [Prepend and Drop Everything From a User](#prepend-and-drop-everything-from-a-user)
* [Development](#development)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Overview

This module manages the Audit daemon, kernel parameters, and related subsystems.

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but it can be used independently:
* When included within the SIMP ecosystem, security compliance settings will be
  managed from the Puppet server.
* If used independently, all SIMP-managed security subsystems will be disabled by
  default and must be explicitly opted into by administrators.  Please review
  ``simp_options`` for details.

## Module Description

You can use this module for the management of all components of auditd
including configuration, service management, kernel parameters, and custom rule
sets.

By default, a rule set is provided that should meet a reasonable set of
operational goals for most environments.

The `audit` kernel parameter may optionally be managed independently of the
rest of the module using the `::auditd::config::grub` class.

## Setup

### Setup Requirements

If `auditd::syslog` is `true`, you will need to install
[simp/rsyslog](https://forge.puppet.com/simp/rsyslog) as a dependency.

### What Auditd Affects

* The `audit` kernel parameter
  * NOTE: This will be applied to *all* kernels in your standard grub configuration
* The auditd service
* The audid configuration in /etc/auditd.conf
* The auditd rules in /etc/audit/rules.d
* The audispd configuration in /etc/audisp/audispd.conf
* The audispd `syslog` configuration if manage_syslog_plugin is enabled.
     audit version 2 : /etc/audisp/plugins.d/syslog.conf
     audit version 3 : /etc/auditd/plugins.d/syslog.conf

## Usage

### Basic Usage

```puppet
# Set up auditd with the default settings and SIMP default ruleset
# A message will be printed indicating that you need to reboot for this option
# to take full effect at each Puppet run until you reboot your system.

include 'auditd'
```

### Disabling Auditd

To disable auditd at boot, set the following in hieradata:

```yaml
auditd::at_boot: false
```

### Enable/Disable sending audit event to syslog:

This capability is most useful for forwarding audit records to
remote servers as syslog messages, since these records are already
persisted locally in audit logs.  For most sites, however, using
this capability for all audit records can quickly overwhelm host
and/or network resources, especially if the messages are forwarded
to multiple remote syslog servers or persisted
locally. Site-specific, rsyslog actions to implement filtering will
likely be required to reduce this message traffic.

The setting ``auditd::syslog``, defaults to ``false`` or
``syslog_options::syslog`` if you include ``simp_options``.  If you set
``auditd::syslog: false``, it will not necessarily disable auditd logging to
syslog, puppet will just no longer manage the ``syslog.conf`` plugin file.

The settings needed for enabling/disabling sending audit log messages to syslog
are shown below.

To enable:
```yaml
auditd::syslog: true
auditd::config::audisp::syslog::enable: true
auditd::config::audisp::syslog::drop_audit_logs: false
# The setting for drop_audit_logs enabled for backwards compatability
# but should be set to false if you want auditd to log to syslog.
```

To disable:
```yaml
auditd::syslog: true
auditd::config::audisp::syslog::enable: false
```

### Changing Key Values

To override the default values included in the module, you can either
include new values for the keys at the time that the classes are declared,
or set the values in hieradata:

```puppet

class { 'auditd':
  ignore_failures => true,
  log_group       => 'root',
  flush           => 'INCREMENTAL'
}
```

```yaml
auditd::ignore_failures: true
auditd::log_group: 'root'
auditd::flush: 'INCREMENTAL'
```

### Understanding Auditd Profiles

This module supports various configurations both independently and
simultaneously to meet varying end user requirements.

> NOTE: The default behavior of this module is to ignore any invalid rules and
> apply as much of the rule set as possible. This is done so that you end up
> with an effective level of auditing regardless of a simply typo or
> conflicting rule.  Please test your final rule sets to ensure that your
> system is auditing as expected.

The ``auditd::default_audit_profiles`` parameter determines which profiles are
included, and in what order the rules are added to the system.

The ``auditd::default_audit_profiles`` has a default setting of ``[ 'simp' ]``
which applies the optimized SIMP auditing profile which is suitable for meeting
most generally available compliance requirements. It does not, however,
generally appease the scanning utilities since it optimizes the rules for
performance and most scanners cannot handle audit rule optimizations.

There are two other profiles available in the system by default:

* ``stig``   => Applies the rules as defined in the latest covered DISA STIG
* ``custom`` => Allows users to define their own rules easily via Hiera

There are a large number of parameters exposed for each profile that are meant
to be set via Hiera and you should take a look at the REFERENCE.md file to
understand the full capabilities of each profile.

#### Stacking Profiles

In some cases, you may want to combine profiles in different orders. This may
either be done in order to pass a particular scanning engine or to ensure that
items that are not caught by the first profile are caught by the second.

Profiles are included and ordered by passing an Array to the
``auditd::default_audit_profiles`` parameter and are added to auditd in the
order in which they are defined in the Array.

For example, this (the default) would only add the ``simp`` profile:

```yaml
auditd::default_audit_profiles:
  - "simp"
```

Likewise, this would add the ``stig`` rules prior to the ``simp`` profile:

```yaml
auditd::default_audit_profiles:
  - "stig"
  - "simp"
```

#### The Custom Profile

Users may wish to either completely override the default profiles or
prepend/append their own rules to the stack for compliance purposes.

You can easily do this via Hiera as shown in the following example:

```yaml
auditd::config::audit_profiles::custom::rules:
  - '-w /etc/passwd -wa -k passwd_files'
  - '-w /etc/shadow -wa -k passwd_files'
```

To activate the custom profile, you will need to set the
``auditd::default_audit_profiles`` parameter as shown in the following
examples:

##### Override All Other Profiles

```yaml
auditd::default_audit_profiles:
  - "custom"
```

##### Prepend Before the SIMP Profile

```yaml
auditd::default_audit_profiles:
  - "custom"
  - "simp"
```

##### Append After the SIMP and STIG Profiles

```yaml
auditd::default_audit_profiles:
  - "simp"
  - "stig"
  - "custom"
```

### Adding One-Off Rules

Rules are alphanumerically ordered based on file-system globbing. It is
recommended that users use the ``auditd::rule`` defined type for adding rules.

Other options are available with ``auditd::rule`` but these are the most
commonly used.

#### Adding Regular Filter Rules

```puppet

auditd::rule { 'failed_file_creation':
  content => '-a always,exit -F arch=b64 -S creat -F exit=-EACCES -k failed_file_creation'
}
```

```puppet

auditd::rule { 'passwd_file_watches':
  content => [
    '-w /etc/passwd -wa -k passwd_files',
    '-w /etc/shadow -wa -k passwd_files'
  ]
}
```

#### Prepend and Drop Everything From a User

This will make your rule land in the ``00`` set of rules.

```puppet

auditd::rule { 'pre_drop_user_5000':
  content => '-a exit,never -F auid=5000',
  prepend => true
}
```

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/Contribution_Procedure.html)

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle exec rake beaker:suites
```

Some environment variables may be useful:

```shell
BEAKER_debug=true
BEAKER_provision=no
BEAKER_destroy=no
BEAKER_use_fixtures_dir_for_modules=yes
BEAKER_fips=yes
```

* `BEAKER_debug`: show the commands being run on the STU and their output.
* `BEAKER_destroy=no`: prevent the machine destruction after the tests finish so you can inspect the state.
* `BEAKER_provision=no`: prevent the machine from being recreated. This can save a lot of time while you're writing the tests.
* `BEAKER_use_fixtures_dir_for_modules=yes`: cause all module dependencies to be loaded from the `spec/fixtures/modules` directory, based on the contents of `.fixtures.yml`.  The contents of this directory are usually populated by `bundle exec rake spec_prep`.  This can be used to run acceptance tests to run on isolated networks.
* `BEAKER_fips=yes`: enable FIPS-mode on the virtual instances. This can
  take a very long time, because it must enable FIPS in the kernel
  command-line, rebuild the initramfs, then reboot.

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md)
for more information.
