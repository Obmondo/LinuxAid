# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`openvmtools`](#openvmtools): Install the Open Virtual Machine Tools.

### Functions

* [`openvmtools::supported`](#openvmtoolssupported): Returns whether the currently loaded OS is supported by the module

## Classes

### <a name="openvmtools"></a>`openvmtools`

Install the Open Virtual Machine Tools.

#### Examples

##### Default usage

```puppet
include openvmtools
```

#### Parameters

The following parameters are available in the `openvmtools` class:

* [`ensure`](#ensure)
* [`autoupgrade`](#autoupgrade)
* [`desktop_package_conflicts`](#desktop_package_conflicts)
* [`desktop_package_name`](#desktop_package_name)
* [`manage_epel`](#manage_epel)
* [`package_name`](#package_name)
* [`service_enable`](#service_enable)
* [`service_ensure`](#service_ensure)
* [`service_hasstatus`](#service_hasstatus)
* [`service_name`](#service_name)
* [`service_pattern`](#service_pattern)
* [`uninstall_vmware_tools`](#uninstall_vmware_tools)
* [`with_desktop`](#with_desktop)
* [`supported`](#supported)

##### <a name="ensure"></a>`ensure`

Data type: `Enum['absent','present']`

Ensure if present or absent.

Default value: `'present'`

##### <a name="autoupgrade"></a>`autoupgrade`

Data type: `Boolean`

Upgrade package automatically, if there is a newer version.

Default value: ``false``

##### <a name="desktop_package_conflicts"></a>`desktop_package_conflicts`

Data type: `Boolean`

Boolean that determines whether the desktop conflicts includes and
conflicts with the base package. Only set this if your platform is not
supported or you know what you are doing.

Default value: ``false``

##### <a name="desktop_package_name"></a>`desktop_package_name`

Data type: `String[1]`

Name of the desktop package.
Only set this if your platform is not supported or you know what you are
doing.

Default value: `'open-vm-tools-desktop'`

##### <a name="manage_epel"></a>`manage_epel`

Data type: `Boolean`

Boolean that determines if puppet-epel is required for packages.
This should only needed for RedHat (EL) 6.

Default value: ``false``

##### <a name="package_name"></a>`package_name`

Data type: `String[1]`

Name of the package.
Only set this if your platform is not supported or you know what you are
doing.

Default value: `'open-vm-tools'`

##### <a name="service_enable"></a>`service_enable`

Data type: `Boolean`

Start service at boot.

Default value: ``true``

##### <a name="service_ensure"></a>`service_ensure`

Data type: `Stdlib::Ensure::Service`

Ensure if service is running or stopped.

Default value: `'running'`

##### <a name="service_hasstatus"></a>`service_hasstatus`

Data type: `Boolean`

Service has status command.
Only set this if your platform is not supported or you know what you are
doing.

Default value: ``true``

##### <a name="service_name"></a>`service_name`

Data type: `Variant[String[1],Array[String[1]]]`

Name of openvmtools service(s).
Only set this if your platform is not supported or you know what you are
doing.

Default value: `['vgauthd', 'vmtoolsd']`

##### <a name="service_pattern"></a>`service_pattern`

Data type: `Optional[String[1]]`

Pattern to look for in the process table to determine if the daemon is
running.
Only set this if your platform is not supported or you know what you are
doing.

Default value: ``undef``

##### <a name="uninstall_vmware_tools"></a>`uninstall_vmware_tools`

Data type: `Boolean`

Boolean that determines whether the conflicting VMWare Tools package should
be uninstalled, if present.

Default value: ``false``

##### <a name="with_desktop"></a>`with_desktop`

Data type: `Boolean`

Whether or not to install the desktop/GUI support.

Default value: ``false``

##### <a name="supported"></a>`supported`

Data type: `Optional[Boolean]`



Default value: ``undef``

## Functions

### <a name="openvmtoolssupported"></a>`openvmtools::supported`

Type: Puppet Language

This function uses the current facts to check if the current Operating System
and its release or major release is supported.

#### Examples

##### Using the Puppet built in global $module_name

```puppet
openvmtools::supported($module_name)
```

#### `openvmtools::supported(String[1] $mod)`

This function uses the current facts to check if the current Operating System
and its release or major release is supported.

Returns: `Boolean` Whether the current OS is supported for the given module

##### Examples

###### Using the Puppet built in global $module_name

```puppet
openvmtools::supported($module_name)
```

##### `mod`

Data type: `String[1]`

The module name to check.

