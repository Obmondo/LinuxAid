[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/simplib.svg)](https://forge.puppetlabs.com/simp/simplib)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-simplib.svg)](https://travis-ci.org/simp/pupmod-simp-simplib)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Setup](#setup)
  * [What simplib affects](#what-simplib-affects)
  * [Setup Requirements](#setup-requirements)
* [Usage](#usage)
* [Reference](#reference)
  * [Facts](#facts)
  * [Run stages](#run-stages)
  * [Puppet extensions](#puppet-extensions)
    * [**PuppetX::SIMP::Simplib::hostname?**](#puppetxsimpsimplibhostname)
    * [**PuppetX::SIMP::Simplib::hostname_only?**](#puppetxsimpsimplibhostname_only)
    * [**PuppetX::SIMP::Simplib::human_sort**](#puppetxsimpsimplibhuman_sort)
    * [**PuppetX::SIMP::Simplib::split_port**](#puppetxsimpsimplibsplit_port)
* [Development](#development)

<!-- vim-markdown-toc -->

## This is a SIMP module

This module is a component of the
[System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

## Module Description

`simp-simplib` provides a standard library of resources commonly used by SIMP
modules but generally suited for any Puppet environment.

## Setup

### What simplib affects

`simplib` contains data types, custom types and providers, facts, functions,
and a class that expands `puppetlabs-stdlib` stages.

### Setup Requirements

Agents will need to enable `pluginsync`.

## Usage

Please see [reference](#reference) for usage.

## Reference

Items not covered by `puppet strings` are provided below.

See [REFERENCE.md](./REFERENCE.md) for all other reference documentation.

### Facts

  * **acpid_enabled**                 -  Return true if ACPI is available on the system
  * **boot_dir_uuid**                 -  Return the UUID of the partition holding the
                                         boot directory
  * **cmdline**                       -  Returns the contents of `/proc/cmdline` as a
                                         hash
  * **cpuinfo**                       -  Returns the contents of `/proc/cpuinfo` as a
                                         hash
  * **defaultgateway**                -  Return the default gateway of the system
  * **defaultgatewayiface**           -  Return the default gw interface of the system
  * **fips_ciphers**                  -  Returns a list of available OpenSSL ciphers
  * **fips_enabled**                  -  Determine whether FIPS is enabled on this system
  * **fullrun**                       -  Determine whether to do an intensive run
  * **gdm_version**                   -  Return the version of GDM that is installed
  * **grub_version**                  -  Return the grub version installed on the system
  * **init_systems**                  -  Return a list of all init systems present on
                                         the system
  * **ipa**                           -  Return a hash containing the IPA domain and
                                         server to which a host is connected
  * **ipv6_enabled**                  -  Return true if IPv6 is enabled and false if not
  * **login_defs**                    -  Return the contents of `/etc/login.defs` as a
                                         hash with downcased keys
  * **prelink**                       -  Returns a hash containing prelink status
  * **reboot_required**               -  Returns a hash of 'name' => 'reason' entries
  * **root_dir_uuid**                 -  Return the UUID of the partition holding the
                                         `/` directory
  * **runlevel**                      -  Return the current system runlevel
  * **shmall**                        -  Return the value of shmall from sysctl
  * **simplib__efi_enabled**          -  Returns true if the system is using EFI
  * **simplib__secure_boot_enabled**  -  Returns true if the host is using uEFI Secure Boot
  * **simplib__firewalls**            -  Return an array of known firewall commands that
                                         are present on the system.
  * **simplib__mountpoints**          -  Return a hash of mountpoints of particular
                                         interest to SIMP modules.
  * **simplib__numa**                 -  Return hash of numa values about your system.
  * **simplib_sysctl**                -  Return hash of sysctl values that are relevant
                                         to SIMP
  * **simp_puppet_settings**          -  Returns a hash of all Puppet settings on a node
  * **tmp_mounts**                    -  DEPRECATED - use `simplib__mountpoints`
                                         This fact provides information about `/tmp`,
                                         `/var/tmp`, and `/dev/shm` should they be present
                                         on the system
  * **uid_min**                       -  Return the minimum uid allowed

### Run stages

See [REFERENCE.md#simplibstages](./REFERENCE.md#simplibstages)

### Puppet extensions

The following methods are Puppet extensions in the ``PuppetX::SIMP::Simplib``
namespace:

- [hostname?](#puppetxsimpsimplibhostname)
- [hostname\_only?](#puppetxsimpsimplibhostname_only)
- [human\_sort](#puppetxsimpsimplibhuman_sort)
- [split\_port](#puppetxsimpsimplibsplit_port)

#### **PuppetX::SIMP::Simplib::hostname?**

Determine whether the passed value is a valid hostname, optionally
postpended with ':\<number\>' or '/\<number\>'.

*NOTE*:  This returns true for an IPv4 address, as it conforms to
         RFC 1123.

*Arguments*:

* ``obj`` Input to be assessed

*Returns*: `Boolean` ``false`` if ``obj`` is not comprised of ASCII
           letters (upper or lower case), digits, hyphens (except at the
           beginning and end), and dots (except at beginning and end),
           excluding an optional, trailing ':\<number\>' or '/\<number\>'

*Examples*:

```ruby
  # Returns true
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com')
  PuppetX::SIMP::Simplib.hostname?('hostname.me.com:5454')

  # Returns false
  PuppetX::SIMP::Simplib.hostname?('-hostname.me.com')
```

#### **PuppetX::SIMP::Simplib::hostname_only?**

Determine whether the passed value is a valid hostname.

*NOTE*:  This returns true for an IPv4 address, as it conforms to
         RFC 1123.

*Arguments*:

* ``obj`` Input to be assessed

*Returns*: `Boolean` ``false`` if ``obj`` is not comprised of ASCII
           letters (upper or lower case), digits, hyphens (except at the
           beginning and end), and dots (except at beginning and end)

*Examples*:

```ruby
  # Returns true
  PuppetX::SIMP::Simplib.hostname_only?('hostname.me.com')

  # Returns false
  PuppetX::SIMP::Simplib.hostname_only?('-hostname.me.com')
  PuppetX::SIMP::Simplib.hostname_only?('hostname.me.com:5454')
```

#### **PuppetX::SIMP::Simplib::human_sort**

Sort a list of values based on usual human sorting semantics.

*Arguments*:

* ``obj`` Enumerable object to be sorted

*Returns*: Sorted object

#### **PuppetX::SIMP::Simplib::split_port**

Split input string into a [ host, port ] pair

*Arguments*:

* ``host_string`` String to be split into host and port

*Returns*: `Array[ host, port ]` Host and port pair

    * Returns ``[ nil, nil ]`` if ``host_string`` is ``nil`` or
      an empty string
    * Returns ``[ host_string, nil ]`` if ``host_string`` is
      a CIDR address or contains no port
    * Port returned is a string

*Examples*:

```ruby
  PuppetX::SIMP::Simplib.split_port('myhost.name:5656')
  # returns ['myhost.name','5656']

  PuppetX::SIMP::Simplib.split_port['192.165.3.9']
  # returns ['192.165.3.9',nil]

  PuppetX::SIMP::Simplib.split_port['192.165.3.9/24']
  # returns ['192.164.3.9/24',nil]

  PuppetX::SIMP::Simplib.split_port('[2001:0db8:85a3:0000:0000:8a2e:0370]:'))
  # returns ['[2001:0db8:85a3:0000:0000:8a2e:0370]',nil]
```
## Development

Please read our [Contribution
Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

