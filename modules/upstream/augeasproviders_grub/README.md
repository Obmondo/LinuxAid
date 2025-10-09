# grub: type/provider for grub files for Puppet

[![Build Status](https://github.com/voxpupuli/puppet-augeasproviders_grub/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_grub/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-augeasproviders_grub/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-augeasproviders_grub/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/augeasproviders_grub.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_grub)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/augeasproviders_grub.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_grub)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/augeasproviders_grub.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_grub)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/augeasproviders_grub.svg)](https://forge.puppetlabs.com/puppet/augeasproviders_grub)
[![puppetmodule.info docs](https://www.puppetmodule.info/images/badge.svg)](https://www.puppetmodule.info/m/puppet-augeasproviders_grub)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-augeasproviders_grub.svg)](LICENSE)
[![Donated by Herculesteam](https://img.shields.io/badge/donated%20by-herculesteam-fb7047.svg)](#transfer-notice)

This module provides a new type/provider for Puppet to read and modify grub
config files using the Augeas configuration library.

The advantage of using Augeas over the default Puppet `parsedfile`
implementations is that Augeas will go to great lengths to preserve file
formatting and comments, while also failing safely when needed.

This provider will hide *all* of the Augeas commands etc., you don't need to
know anything about Augeas to make use of it.

## Requirements

Ensure both Augeas and ruby-augeas 0.3.0+ bindings are installed and working as
normal.

See [Puppet/Augeas pre-requisites](http://docs.puppetlabs.com/guides/augeas.html#pre-requisites).

**WARNING** Your system must be able to run the grub mkconfig scripts with BLS
support if you are on a systen that uses BLS!

## Installing

On Puppet 2.7.14+, the module can be installed easily ([documentation](http://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)):

    puppet module install puppet/augeasproviders_grub

You may see an error similar to this on Puppet 2.x ([#13858](http://projects.puppetlabs.com/issues/13858)):

    Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type `kernel_parameter` at ...

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Compatibility

### Puppet versions

Minimum of Puppet 2.7.

### Augeas versions

Augeas Versions           | 0.10.0  | 1.0.0   | 1.1.0   | 1.2.0   |
:-------------------------|:-------:|:-------:|:-------:|:-------:|
**PROVIDERS**             |
kernel\_parameter (grub)  | **yes** | **yes** | **yes** | **yes** |
kernel\_parameter (grub2) | **yes** | **yes** | **yes** | **yes** |
grub\_config (grub)       | **yes** | **yes** | **yes** | **yes** |
grub\_config (grub2)      | **yes** | **yes** | **yes** | **yes** |
grub\_menuentry (grub)    | **yes** | **yes** | **yes** | **yes** |
grub\_menuentry (grub2)   |   N/A   |   N/A   |   N/A   |   N/A   |
grub\_user (grub2)        |   N/A   |   N/A   |   N/A   |   N/A   |

**Note**: grub\_menuentry and grub\_user for GRUB2 do not use Augeas at this
time due to lack of available lenses.

## Documentation and examples

Type documentation can be generated with `puppet doc -r type` or viewed on the
[Puppet Forge page](http://forge.puppetlabs.com/puppet/augeasproviders_grub).


### kernel_parameter provider

This is a custom type and provider supplied by `augeasproviders`.  It supports
both GRUB Legacy (0.9x) and GRUB 2 configurations.

#### manage parameter without value

    kernel_parameter { "quiet":
      ensure => present,
    }

#### manage parameter with value

    kernel_parameter { "elevator":
      ensure  => present,
      value   => "deadline",
    }

#### manage parameter with multiple values

    kernel_parameter { "rd_LVM_LV":
      ensure  => present,
      value   => ["vg/lvroot", "vg/lvvar"],
    }

#### manage parameter on certain boot types

Bootmode defaults to "all", so settings are applied for all boot types usually.

Apply only to the default boot:

    kernel_parameter { "quiet":
      ensure   => present,
      bootmode => "default",
    }

Apply only to normal boots. In GRUB legacy, normal boots consist of the default boot plus non-recovery ones. In GRUB2, normal bootmode is just an alias for default.

    kernel_parameter { "quiet":
      ensure   => present,
      bootmode => "normal",
    }

Only recovery mode boots (unsupported with GRUB 2):

    kernel_parameter { "quiet":
      ensure   => present,
      bootmode => "recovery",
    }

#### delete entry

    kernel_parameter { "rhgb":
      ensure => absent,
    }

#### manage parameter in another config location

    kernel_parameter { "elevator":
      ensure => present,
      value  => "deadline",
      target => "/mnt/boot/grub/menu.lst",
    }

### grub_config provider

This custom type manages GRUB Legacy and GRUB2 global configuration parameters.

In GRUB Legacy, the global items at the top of the `grub.conf` file are managed.

In GRUB2, the parameters in `/etc/defaults/grub` are managed.

When using GRUB2, take care that you aren't conflicting with an option later
specified by `grub_menuentry`. Also, be aware that, in GRUB2, any global items
here will not be referenced unless you reference them by variable name per Bash
semantics.

#### change the default legacy GRUB timeout

This will set the `timeout` global value in the Legacy GRUB configuration.

    grub_config { 'timeout':
      value => '1'
    }

#### change the default GRUB2 timeout

This will set the `GRUB_TIMEOUT` global value in the GRUB2 configuration.

    grub_config { 'GRUB_TIMEOUT':
      value => '1'
    }

### grub_menuentry provider

This is a custom type to manage GRUB Legacy and GRUB2 menu entries.

The GRUB Legacy provider utlizes Augeas under the hood but GRUB2 did not have
an available Lens and was written in Ruby.

This will **not** allow for modifying dynamically generated system entries. You
will need to remove some of the native GRUB2 configuration scripts to be fully
independent of the default system values.

The GRUB2 output of this provider will be saved, by default, in
`/etc/grub.d/05_puppet_managed_<random_string>` where the `random_string` is a
hash of the resource `name`.

#### new entry preserving all existing values

This will create a new menu entry and copy over any default values if present.
If the entry currently exists, it will preserve all values and not overwrite
them with the default system values.

    grub_menuentry { 'new_entry':
      root           => '(hd0,0)',
      kernel         => ':preserve:',
      initrd         => ':preserve:',
      kernel_options => [':preserve:']
    }

#### kernel option lines

There are many methods for identifying and manipulating kernel option lines and
so a method was developed for handling the most common scenarios. You can, of
course, simply denote every option, but this is cumbersome and prone to error
over time.

The following format is supported for the new options:

    ':defaults:'  => Copy defaults from the default GRUB entry
    ':preserve:'  => Preserve all existing options (if present)

    Note: ':defaults:' and ':preserve:' are mutually exclusive.

    All of the options below supersede any items affected by the above

    'entry(=.*)?'   => Ensure that `entry` exists *as entered*; replaces all
                       other options with the same name
    '!:entry(=.*)?' => Add this option to the end of the arguments
                       preserving any other options of the same name
    '-:entry'       => Ensure that all instances of `entry` do not exist
    '-:entry=foo'   => Ensure that only instances of `entry` with value `foo` do not exist

    Note: Option removals and additions have higher precedence than preservation

### grub_user provider

This type manages GRUB2 users and superusers.

The output of this provider is stored, by default, in `/etc/grub.d/01_puppet_managed_users`.

Any plain text passwords are automatically converted into the appropriate GRUB
PBKDF2 format.

Note: If no users are defined as superusers, then GRUB2 will not enforce user
restrictions on your entries.

#### user with a plain text password

    grub_user { 'test_user':
      password => 'plain text password'
    }

#### user with a pre-hashed password

    grub_user { 'test_user':
      password => 'grub.pbkdf2.sha512.10000.REALLY_LONG_STRING'
    }

#### user that is a superuser with a plain text password and 20000 rounds

    grub_user { 'test_user':
      password  => 'plain text password',
      superuser => true,
      rounds    => '20000'
    }

## Issues

Please file any issues or suggestions
[on GitHub](https://github.com/voxpupuli/augeasproviders_grub/issues).

## Transfer Notice

This module was originally authored by [hercules-team](http://augeasproviders.com).
The maintainer preferred that Vox Pupuli take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here.

Previously: https://github.com/hercules-team/augeasproviders_grub
