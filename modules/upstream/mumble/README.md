# Mumble module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-mumble.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-mumble)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-mumble/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-mumble)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/mumble.svg)](https://forge.puppetlabs.com/puppet/mumble)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/mumble.svg)](https://forge.puppetlabs.com/puppet/mumble)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/mumble.svg)](https://forge.puppetlabs.com/puppet/mumble)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/mumble.svg)](https://forge.puppetlabs.com/puppet/mumble)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with puppet-mumble](#setup)
    * [What puppet-mumble affects](#what-puppet-mumble-affects)
    * [Beginning with puppet-mumble](#beginning-with-puppet-mumble)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs the Mumble VoIP server, murmurd.

It is in beta development and tested on Ubuntu 12.04 and 14.04.

## Module Description

This module is intended for Ubuntu. If `$ppa` is true, it adds either
the snapshot or release (depending on `$snapshot`) Mumble PPA, then
installs mumble-server, configures it through a template, and starts
the service.

## Get in touch

* IRC: [#voxpupuli on irc.freenode.net](irc://irc.freenode.net/voxpupuli)
  ([Freenode WebChat](http://webchat.freenode.net/?channels=%23voxpupuli))
* Mailinglist: <voxpupuli@groups.io>
  ([groups.io Webinterface](https://groups.io/g/voxpupuli/topics))

## Setup

### What puppet-mumble affects

* Packages
    * `mumble-server`
    * `libicu-dev` if `$libicu_dev` ([bugfix](https://bugs.launchpad.net/ubuntu/+source/qt4-x11/+bug/989915))
* PPAs
    * `ppa:mumble/release`
    * `ppa:mumble/snapshot`
* Services
    * `mumble-server`
* Files
    * `/etc/mumble-server.ini`
* User
    * `mumble-server`
* Group
    * `mumble-server`

### Beginning with puppet-mumble

The simplest use of this module is:

    include mumble

### Usage

Generated puppet strings documentation with examples is available from
https://voxpupuli.org/puppet-mumble/

It's also included in the docs/ folder as simple html pages.

This module has one class, `mumble`, with the following
parameters:

    $autostart          = true,  # Start server at boot
    $ppa                = false, # Install the PPA
    $snapshot           = false, # Use snapshot over release PPA
    $server_password    = '',    # Supervisor account password

    # The following parameters affect mumble-server.ini through a template
    # For more info, see http://mumble.sourceforge.net/Murmur.ini
    $register_name      = 'Mumble Server',
    $password           = undef,    # General entrance password
    $port               = 64738,
    $host               = '',
    $user               = 'mumble-server',
    $group              = 'mumble-server',
    $bandwidth          = 72000,
    $users              = 100,
    $text_length_limit  = 5000,
    $autoban_attempts   = 10,
    $autoban_time_frame = 120,
    $autoban_time       = 300,
    $database_path      = '/var/lib/mumble-server/mumble-server.sqlite',
    $log_path           = '/var/log/mumble-server/mumble-server.log',
    $allow_html         = true,
    $log_days           = 31,
    $ssl_cert           = '',
    $ssl_key            = '',
    $welcome_text       = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',

Note that the mumble-server package by default sets up a user and
group named 'mumble-server', and so will be created additionally if
the user and group are changed here.

More information about the configuraiton file's settings can be found
in the [Wiki](http://mumble.sourceforge.net/Murmur.ini).

The `snapshot` parameter enables the use of the snapshot PPA, which as
of this writing, seems to fix the bug where libicui-dev was needed but
not a dependency.

The `server_password` parameter sets the supervisor account's password
by executing `murmurd -supw password`, it is not a template
configuration, and thus can be set manually as well.

## Limitations

This module currently only supports Ubuntu. It is working on my
Vagrant box, Ubuntu 12.04.4 LTS with Puppet 3.4.1, and as such it's
development is on hold.

If Mumble ever runs without being given an SSL certificate and key,
then it will auto-generate its own. If later given a custom
certificate and key, the Mumble service must be stopped, and then
manually run with the option to wipe the keys from its internal
configuration database.

```sh
service mumble-server stop
murmurd -wipessl
pkill murmurd
service mumble-server start
```

Please note that on Debian / Ubuntu, you may want to change
`USER=mumble-server` to `USER=root` in `/etc/init.d/mumber-server` so
that root owned keys can be read by Mumble on startup, as per this
[bug](https://bugs.launchpad.net/ubuntu/+source/mumble/+bug/1017301). The
Mumble daemon automatically drops privileges itself.

## Development

Fork on [GitHub](https://github.com/voxpupuli/puppet-mumble), make a Pull Request.
