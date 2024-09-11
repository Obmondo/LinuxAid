# reboot
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-reboot.png?branch=main)](https://travis-ci.org/puppetlabs/puppetlabs-reboot)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the reboot module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with reboot](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with reboot](#beginning-with-reboot)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

This module adds a type, and both Windows and generic POSIX providers, for managing target reboots.

## Module Description

Some packages require a reboot of the target to complete their installation. Until that reboot is completed, the package might not be fully functional, and other installs might fail. This module provides a resource type to let Puppet perform that reboot, and providers to support Windows and POSIX systems. HP-UX is not supported.

By default, this module only reboots a target in response to another resource being applied --- e.g., after a package install. On Windows targets, you can also have Puppet check for pending reboots and complete them *before* applying the next resource in the catalog, by specifying `when => pending`.

## Setup

### Setup Requirements

On Windows targets, the 'shutdown.exe' command must be in the `PATH`.

On Windows 2003 (non-R2) x64 targets, [KB942589](http://support.microsoft.com/kb/942589) must be installed.

### Beginning with reboot

The reboot module should work right out of the box. To test it, install a package (in this case 'SomePackage') and set up the module to reboot as follows:

    package { 'SomePackage':
      ensure          => installed,
      source          => '\\server\share\some_installer.exe',
      install_options => ['/Passive', '/NoRestart'],
    }
    reboot { 'after':
      subscribe       => Package['SomePackage'],
    }

## Usage

### Complete any pending reboots before installing a package

    reboot { 'before':
      when            => pending,
    }
    package { 'SomePackage':
      ensure          => installed,
      source          => '\\server\share\some_installer.exe',
      install_options => ['/Passive', '/NoRestart'],
      require         => Reboot['before'],
    }

### Install multiple packages before rebooting

By default, when this module triggers a reboot, it skips any resources in the catalog that have not yet been applied. To apply the entire catalog before rebooting, specify `apply => finished`. For example, if you have several packages that all require reboots, but will not block each other:

    package { 'Microsoft .NET Framework 4.5':
      ensure => installed,
      ...
      notify => Reboot['after_run'],
    }
    package { 'Microsoft Windows SDK for Windows 7 (7.0)':
      ensure => installed,
      ...
      notify => Reboot['after_run'],
    }
    reboot { 'after_run':
      apply  => finished,
    }

### Reboot when certain conditions are met

This usage applies to Windows only. 

When using `when => pending`, use `onlyif` or `unless` to specify the reasons for which to reboot.

    reboot { 'reboot on file renames':
      when   => 'pending',
      onlyif => 'pending_file_rename_operations'
    }

The possible reasons for rebooting are:

* reboot_required: A reboot has manually been requested through the provider.
* component_based_servicing: A new component has been installed.
* windows_auto_update: An automatic update requested a reboot.
* pending_file_rename_operations: There are files that need to be renamed at the next reboot.
* package_installer: A software update requested a reboot.
* package_installer_syswow64: A software update requested a reboot.
* pending_computer_rename: The computer needs to be renamed.
* pending_dsc_reboot: DSC has requested a reboot.
* pending_ccm_reboot: CCM has requested a reboot.
* pending_domain_join: System has joined domain and is pending a reboot.

## Reference

### Type: reboot

The main type of the module, responsible for all its functionality.

#### Providers

* `windows`: Default for :operatingsystem => :windows
* `linux`: Deprecated. Use `posix` instead.
* `posix`: Default for :feature => :posix

#### Features

* `manages_reboot_pending`: Detects whether a reboot is pending due to a prior change. If so, reboot the target. (Available with the `windows` provider.)

#### Parameters

##### `apply`

*Optional.* Specifies when to apply the reboot. If set to 'immediately', the provider stops applying additional resources and performs the reboot as soon as Puppet finishes syncing. If set to 'finished', it continues applying resources and then performs the reboot at the end of the run. Valid options: 'immediately' and 'finished'. Default value: 'immediately'.

**Note:** With the default setting of 'immediately', resources further down in the catalog are skipped and recorded as such. (In Puppet versions prior to 3.3.0, they're left out of the report entirely.) The next time Puppet runs, it processes the skipped resources normally, and they might trigger additional reboots.

##### `message`

*Optional.* Provides a message to log when the reboot is performed. Valid options: a string. Default value: undefined.

##### `name`

*Required.* Sets the name of the reboot resource. Valid options: a string.

##### `timeout`

*Optional.* Sets the number of seconds to wait after the Puppet run completes for the reboot to happen. If the timeout is exceeded, the provider cancels the reboot. Valid options: any positive integer. Default value: '60'.

**Note:** POSIX systems (with the exception of Solaris) only support specifying the timeout as minutes. As such, the value of `timeout` must be a multiple of 60. Other values will be rounded up to the nearest minute and a warning will be issued.

##### `when`

*Optional.* Specifies how reboots are triggered. If set to 'refreshed', the provider only reboots the target in response to a refresh event from another resource, e.g., installing a package. If set to 'pending', Puppet checks for signs of any pending reboots and completes them before applying the next resource in the catalog. Valid options: 'refreshed' and 'pending'. Default value: 'refreshed'.

**Note:** For `when => pending` reboots, Puppet can normally detect a pending reboot based on some specific system conditions (such as the existence of the PendingFileRenameOperations registry key). However, if those conditions aren't resolved after the target reboots, Puppet triggers another reboot. This can lead to a reboot loop.

#### `onlyif`

*Optional.* Applies a pending reboot only for the specified reasons.
This can take a single reason or an array of reasons.

See the [Reboot when certain conditions are met](#reboot-when-certain-conditions-are-met) section for reasons why you might reboot.

#### `unless`

*Optional.* Ignores the specified reasons when checking for a pending reboot.
This can take a single reason or an array of reasons.

See the [Reboot when certain conditions are met](#reboot-when-certain-conditions-are-met) section for reasons why you might reboot.

### Plan: `reboot`

This plan is intended to be used as part of other [plans](https://puppet.com/docs/bolt/latest/writing_plans.html) and allows Bolt to wait for a server to reboot before continuing. It requires Bolt 1.0+ and/or PE 2019.0+. 

**NOTE**: The `nodes` parameters is deprecated in Bolt 2.0, and has been updated here to `targets`.
This breaks plans or workflows that explicitly call the `nodes` parameter, however this module is
still compatible with Bolt 1.x specifying the `targets` parameter instead.

Here is an example of using this module to reboot servers, wait for them to come back, then check the status of a service:

```puppet
plan myapp::patch (
  TargetSpec $servers,
  TargetSpec $version,
) {
  # Upgrade the application
  run_task('myapp::upgrade', $servers, { 'version' => $version })

  # Reboot the servers. This app is slow to shut down so give them 5 minutes to reboot.
  run_plan('reboot', $servers, reconnect_timeout => 300)

  # Check the status of the service
  return run_task('service', $servers, {
    'name'   => 'myapp',
    'action' => 'status',
  })
}
```

#### Return value

The `reboot` plan returns a ResultSet on success. It also returns a ResultSet if `fail_plan_on_errors` is false.

The plan may raise an Error if any targets fail to reboot and `fail_plan_on_errors` is set to true. In that circumstance, the error raised will contain the ResultSet in its details key.

```
$plan_result = run_plan('reboot', targets => $targets)
$results = case $plan_result {
  Error:   { $plan_result.details['result_set'] }
  default: { $plan_result }
}

$results.ok_set.targets    # Targets that successfully rebooted
$results.error_set.targets # Targets that did not successfully reboot
```

#### Parameters

##### `targets`

A `TargetSpec` object containing all targets to wait for.

##### `message`

An optional message to log when rebooting.

##### `reboot_delay`

How long (in seconds) to wait before shutting down. Defaults to 0, shutdown immediately.

##### `disconnect_wait`

How long (in seconds) to wait before checking whether the server has rebooted. Defaults to 1.

##### `reconnect_timeout`

How long (in seconds) to attempt to reconnect before giving up. Defaults to 180.

##### `retry_interval`

How long (in seconds) to wait between retries. Defaults to 1.

##### `fail_plan_on_errors`

Whether or not to raise an exception if any targets fail to reboot. Defaults to true.

Setting this value to false allows the return value of a plan to be treated the same way a task return value with `_catch_errors => true` would be treated.

```puppet
plan myapp::patch (
  TargetSpec $targets,
  String     $version,
) {
  $target_objects = get_targets($targets)

  # Upgrade the application
  $step1_results = run_task('myapp::upgrade', $target_objects,
    version       => $version,
    _catch_errors => true,
  )

  # Reboot the servers. This app is slow to shut down so give them 5 minutes to reboot.
  $step2_results = run_plan('reboot', targets => $step1_results.ok_set.targets,
    reconnect_timeout   => 300
    fail_plan_on_errors => false,
  )

  # Check the status of the service
  $step3_results = run_task('service', $step2_results.ok_set.targets,
    name          => 'myapp',
    action        => 'status',
    _catch_errors => true,
  )

  return({
    'errored-at-step1' => $step1_results.error_set.names,
    'errored-at-step2' => $step2_results.error_set.names,
    'errored-at-step3' => $step3_results.error_set.names,
    'succeeded'        => $step3_results.ok_set.names,
  }.filter |$_, $names| { ! $names.empty })
}
```

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-reboot/blob/main/metadata.json)

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppet.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-reboot/graphs/contributors)
