# Open Virtual Machine Tools

[![CI](https://github.com/voxpupuli/puppet-openvmtools/actions/workflows/ci.yml/badge.svg)](https://github.com/voxpupuli/puppet-openvmtools/actions/workflows/ci.yml)
[![Release](https://github.com/voxpupuli/puppet-openvmtools/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-openvmtools/actions/workflows/release.yml)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-openvmtools/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-openvmtools)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/openvmtools.svg)](https://forge.puppetlabs.com/puppet/openvmtools)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/openvmtools.svg)](https://forge.puppetlabs.com/puppet/openvmtools)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/openvmtools.svg)](https://forge.puppetlabs.com/puppet/openvmtools)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/openvmtools.svg)](https://forge.puppetlabs.com/puppet/openvmtools)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-openvmtools)
[![License](https://img.shields.io/github/license/voxpupuli/puppet-openvmtools.svg)](https://github.com/voxpupuli/puppet-openvmtools/blob/master/LICENSE)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with this module](#setup)
    * [What this module affects](#what-this-module-affects)
    * [What this module requires](#requirements)
    * [Beginning with this module](#beginning-with-this-module)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
    * [OS Support](#os-support)
    * [Notes](#notes)
    * [Issues](#issues)
7. [Changelog](#changelog)
8. [References](#references)
9. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module manages the installation and configuration of the
[Open Virtual Machine Tools](http://open-vm-tools.sourceforge.net/) for VMware.
VMware [recommends using open-vm-tools](http://kb.vmware.com/kb/2073803)
redistributed by operating system vendors.

## Module Description

open-vm-tools is the open source implementation of VMware Tools and consists of
a suite of virtualization utilities that improves the functionality,
administration, and management of virtual machines within a VMware environment.
The primary purpose for open-vm-tools is to enable operating system vendors
and/or communities and virtual appliance vendors to bundle VMware Tools into
their product releases.

The benefits of bundling open-vm-tools are:

* End users get the best out-of-box experience to efficiently deploy virtual
  machines on VMware virtual infrastructure.
* Eliminates the need to separately install VMware Tools when open-vm-tools is
  bundled with the operating system because open-vm-tools is a fully-supported
  open source implementation of VMware Tools.
* Reduces operational expenses and virtual machine downtime because updates to
  open-vm-tools packages are provided with operating system maintenance updates
  and patches. This eliminates separate maintenance cycles for VMware Tools
  updates.
* No compatibility matrix check is required for open-vm-tools. Adhering to the
  VMware Compatibility Matrix for the guest OS release is sufficient.
* open-vm-tools bundled with the operating system provides a compact footprint
  optimized for each OS release.

## Setup

### What this module affects

* Installs the main package open-vm-tools.
* Optionally installs the desktop package open-vm-tools-desktop.
* Starts the vmtoolsd daemon.

### Requirements

You need to be running a virtual machine on the VMware platform and on an
operating system that ships the Open Virtual Machine Tools for this module
to do anything.

### Beginning with this module

It is safe for all nodes to use this declaration.  Any non-VMware or unsupported
system will skip installation of the tools.

```puppet
include openvmtools
```

To include the desktop software, set the following parameter:

```puppet
class { 'openvmtools':
  with_desktop => true,
}
```

## Usage

There is only one class and most usage will simply include the `openvmtools`
class.

## Reference

### Classes

#### Public Classes

* [`openvmtools`](#class-openvmtools): Installs the Open Virtual Machine Tools.

### Class: `openvmtools`

#### Parameters

The following parameters are available in the `::openvmtools` class:

##### `ensure`

Ensure if present or absent.
Default: present

##### `autoupgrade`

Upgrade package automatically, if there is a newer version.
Default: false

##### `desktop_package_conflicts`

Boolean that determines whether the desktop conflicts includes and
conflicts with the base package. Only set this if your platform is not
supported or you know what you are doing.
Default: auto-set, platform specific

##### `desktop_package_name`

Name of the desktop package.  Only set this if your platform is not supported or
you know what you are doing.
Default: auto-set, platform specific

##### `manage_epel`

Boolean that determines if puppet-epel is required for packages.
This should only needed for RedHat (EL) 6.
Default: auto-set, platform specific

##### `package_name`

Name of the package.  Only set this if your platform is not supported or you
know what you are doing.
Default: auto-set, platform specific

##### `service_enable`

Start service at boot.
Default: true

##### `service_ensure`

Ensure if service is running or stopped.
Default: running

##### `service_hasstatus`

Name of openvmtools service.  Only set this if your platform is not supported or
you know what you are doing.
Default: auto-set, platform specific

##### `service_name`

Name of openvmtools service.  Only set this if your platform is not supported or
you know what you are doing.
Default: auto-set, platform specific

##### `service_pattern`

Pattern to look for in the process table to determine if the daemon is running.
Only set this if your platform is not supported or you know what you are doing.
Default: vmtoolsd

##### `supported`

Boolean that overrides the resulte of the supported OS check
Default: undef

##### `uninstall_vmware_tools`

Boolean that determines whether the conflicting VMWare Tools package should
be uninstalled, if present.
Default: false

##### `with_desktop`

Whether or not to install the desktop/GUI support.
Default: false

## Limitations

### OS Support

open-vm-tools is available with these operating systems:

* CentOS 7 and later releases
* Debian 11 and later releases
* Fedora 38 and later releases
* FreeBSD 10 and later releases
* Oracle Linux 7 and later releases
* Red Hat Enterprise Linux 7.0 and later releases
* SUSE Linux Enterprise 12 and later releases
* Ubuntu 20.04 and later LTS releases
* openSUSE 11.x and later releases
* Rocky 8 and later releases
* AlmaLinux 8 and later releases

### Notes

* No other VM tools
  (ie [Operating System Specific Packages](http://packages.vmware.com/)) will be
  supported.  Use
  [voxpupuli/vmwaretools](https://forge.puppetlabs.com/voxpupuli/vmwaretools)
  instead.

### Issues

* None

## Changelog

see [CHANGELOG.md](CHANGELOG.md)

## References

see [REFERENCE.md](REFERENCE.md)

## Development

Please see [CONTRIBUTING.md](.github/CONTRIBUTING.md) for information on how to contribute.

Copyright (C) 2017 Vox Pupuli <voxpupuli@groups.io>

Licensed under the Apache License, Version 2.0.

[voxpupuli/puppet-openvmtools on GitHub](https://github.com/voxpupuli/puppet-openvmtools)

[voxpupuli/openvmtools on Puppet Forge](https://forge.puppetlabs.com/voxpupuli/openvmtools)
