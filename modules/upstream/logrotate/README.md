# Logrotate module for Puppet

[![License](https://img.shields.io/github/license/voxpupuli/puppet-logrotate.svg)](https://github.com/voxpupuli/puppet-logrotate/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-logrotate.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-logrotate)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/logrotate.svg)](https://forge.puppetlabs.com/puppet/logrotate)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/logrotate.svg)](https://forge.puppetlabs.com/puppet/logrotate)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/logrotate.svg)](https://forge.puppetlabs.com/puppet/logrotate)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/logrotate.svg)](https://forge.puppetlabs.com/puppet/logrotate)

## Description

A more Puppety way of managing logrotate configs.  Where possible, as many of
the configuration options have remained the same with a couple of notable
exceptions:

 * Booleans are now used instead of the `<something>`/`no<something>` pattern.
   e.g. `copy` == `copy => true`, `nocopy` == `copy => false`.
 * `create` and its three optional arguments have been split into seperate
   parameters documented below.
 * Instead of 'daily', 'weekly', 'monthly' or 'yearly', there is a
   `rotate_every` parameter (see documentation below).

## logrotate::conf

You may, optionally, define logrotate defaults using this defined type.
Parameters are the same as those for logrotate::rule.
Using this type will automatically include a private class that will install
and configure logrotate for you.
You must not also declare the `logrotate` class if using this defined type as you will encounter a Puppet error if you attempt to do so.

## logrotate::rule

The only thing you'll need to deal with, this type configures a logrotate rule.
Using this type will automatically include a private class that will install
and configure logrotate for you.

**Important**: in Hiera, use logrotate::rules (rule**s**, not rule)

```
namevar         - The String name of the rule.
path            - The path(s) to the log file(s) to be rotated.  May be a
                  String or an Array of Strings.
ensure          - The desired state of the logrotate rule as a String.  Valid
                  values are 'absent' and 'present' (default: 'present').
compress        - A Boolean value specifying whether the rotated logs should
                  be compressed (optional).
compresscmd     - The command String that should be executed to compress the
                  rotated logs (optional).
compressext     - The extention String to be appended to the rotated log files
                  after they have been compressed (optional).
compressoptions - A String of command line options to be passed to the
                  compression program specified in `compresscmd` (optional).
copy            - A Boolean specifying whether logrotate should just take a
                  copy of the log file and not touch the original (optional).
copytruncate    - A Boolean specifying whether logrotate should truncate the
                  original log file after taking a copy (optional).
create          - A Boolean specifying whether logrotate should create a new
                  log file immediately after rotation (optional).
create_mode     - An octal mode String logrotate should apply to the newly
                  created log file if create => true (optional).
create_owner    - A username String that logrotate should set the owner of the
                  newly created log file to if create => true (optional).
create_group    - A String group name that logrotate should apply to the newly
                  created log file if create => true (optional).
dateext         - A Boolean specifying whether rotated log files should be
                  archived by adding a date extension rather just a number
                  (optional).
dateformat      - The format String to be used for `dateext` (optional).
                  Valid specifiers are '%Y', '%m', '%d' and '%s'.
dateyesterday   - A Boolean specifying whether to use yesterday's date instead
                  of today's date to create the `dateext` extension (optional).
delaycompress   - A Boolean specifying whether compression of the rotated
                  log file should be delayed until the next logrotate run
                  (optional).
extension       - Log files with this extension String are allowed to keep it
                  after rotation (optional).
ifempty         - A Boolean specifying whether the log file should be rotated
                  even if it is empty (optional).
mail            - The email address String that logs that are about to be
                  rotated out of existence are emailed to (optional).
mailfirst       - A Boolean that when used with `mail` has logrotate email the
                  just rotated file rather than the about to expire file
                  (optional).
maillast        - A Boolean that when used with `mail` has logrotate email the
                  about to expire file rather than the just rotated file
                  (optional).
maxage          - The Integer maximum number of days that a rotated log file
                  can stay on the system (optional).
minsize         - The String minimum size a log file must be to be rotated,
                  but not before the scheduled rotation time (optional).
                  The default units are bytes, append k, M or G for kilobytes,
                  megabytes and gigabytes respectively.
maxsize         - The String maximum size a log file may be to be rotated;
                  When maxsize is used, both the size and timestamp of a log
                  file are considered for rotation.
                  The default units are bytes, append k, M or G for kilobytes,
                  megabytes and gigabytes respectively.
missingok       - A Boolean specifying whether logrotate should ignore missing
                  log files or issue an error (optional).
olddir          - A String path to a directory that rotated logs should be
                  moved to (optional).
postrotate      - A command String that should be executed by /bin/sh after
                  the log file is rotated (optional).
prerotate       - A command String that should be executed by /bin/sh before
                  the log file is rotated and only if it will be rotated
                  (optional).
firstaction     - A command String that should be executed by /bin/sh once
                  before all log files that match the wildcard pattern are
                  rotated (optional).
lastaction      - A command String that should be execute by /bin/sh once
                  after all the log files that match the wildcard pattern are
                  rotated (optional).
rotate          - The Integer number of rotated log files to keep on disk
                  (optional).
rotate_every    - How often the log files should be rotated as a String.
                  Valid values are 'hour', 'day', 'week', 'month' and 'year'
                  (optional).  Please note, older versions of logrotate do not
                  support yearly log rotation.
size            - The String size a log file has to reach before it will be
                  rotated (optional).  The default units are bytes, append k,
                  M or G for kilobytes, megabytes or gigabytes respectively.
sharedscripts   - A Boolean specifying whether logrotate should run the
                  postrotate and prerotate scripts for each matching file or
                  just once (optional).
shred           - A Boolean specifying whether logs should be deleted with
                  shred instead of unlink (optional).
shredcycles     - The Integer number of times shred should overwrite log files
                  before unlinking them (optional).
start           - The Integer number to be used as the base for the extensions
                  appended to the rotated log files (optional).
su              - A Boolean specifying whether logrotate should rotate under
                  the specific su_owner and su_group instead of the default (optional).
su_user         - A username String that logrotate should use to rotate a
                  log file set instead of using the default if
                  su => true (optional).
su_group        - A String group name that logrotate should use to rotate a
                  log file set instead of using the default if
                  su => true (optional).
uncompresscmd   - The String command to be used to uncompress log files
                  (optional).
```

Further details about these options can be found by reading `man 8 logrotate`.

## logrotate

You may, optionally, declare the main `::logrotate` class to adjust some of the
defaults that are used when installing the logrotate package and creating the
main `/etc/logrotate.conf` configuration file.

This example will ensure that the logrotate package is latest and that the `dateext` and `compress` options are added to the defaults for a node.

```puppet
class { 'logrotate':
  ensure => 'latest',
  config => {
    dateext      => true,
    compress     => true,
    rotate       => 10,
    rotate_every => 'week',
    ifempty      => true,
  }
}
```

### Additional startup arguments

With parameter `logrotate_args` you can specify additional startup arguments for logrotate. Configuration file is always added as the last argument for logrotate.

This example tells logrotate to use an alternate state file and which command to use when mailing logs.

```puppet
class { 'logrotate':
  ensure         => 'latest',
  logrotate_args => ['-s /var/lib/logrotate/logrotate.status', '-m /usr/local/bin/mailer']
}
```

### Cron output

By default, the cron output is discarded if there is no error output. To enable this output, when you (for example) enable the verbose startup argument, enable the `cron_always_output` boolean on the logrotate class:

```puppet
class { 'logrotate':
  ensure              => 'latest',
  cron_always_output  => true,
  config              => {
    ...
  }
}
```

## Examples

### Puppet

```puppet
logrotate::conf { '/etc/logrotate.conf':
  rotate       => 10,
  rotate_every => 'week',
  ifempty      => true,
  dateext      => true,
}

logrotate::rule { 'messages':
  path         => '/var/log/messages',
  rotate       => 5,
  rotate_every => 'week',
  postrotate   => '/usr/bin/killall -HUP syslogd',
}

logrotate::rule { 'servicelogs':
  path         => ['/var/log/this-service.log', '/var/log/that-app.log'],
  rotate       => 5,
  rotate_every => 'day',
  postrotate   => '/usr/bin/kill -HUP `cat /run/syslogd.pid`',
}

logrotate::rule { 'apache':
  path          => '/var/log/httpd/*.log',
  rotate        => 5,
  mail          => 'test@example.com',
  size          => '100k',
  sharedscripts => true,
  postrotate    => '/etc/init.d/httpd restart',
}
```

### Hiera

**Important**: in Hiera, use logrotate::rules (rule**s**, not rule)

```yaml
logrotate::config:
  rotate: 10
  rotate_every: 'week'
  ifempty: true
  dateext: true

logrotate::rules:
  messages:
    path: '/var/log/messages'
    rotate: 5
    rotate_every: 'week'
    postrotate: '/usr/bin/killall -HUP syslogd'
  servicelogs:
    path: ['/var/log/this-service.log', '/var/log/that-app.log']
    rotate: 5
    rotate_every: 'day'
    postrotate: '/usr/bin/kill -HUP `cat /run/syslogd.pid`'
  apache:
    path: '/var/log/httpd/*.log'
    rotate: 5
    mail: 'test@example.com'
    size: '100k'
    sharedscripts: true
    postrotate: '/etc/init.d/httpd restart'
```

### Result
This example will create/edit these files:
```
├── logrotate.conf
└── logrotate.d
    ├── apache
    ├── messages
    └── servicelogs
```

## Authors and Module History

Puppet-logrotate has been maintained by VoxPupuli since version 2.0.0.
It was migrated from https://forge.puppet.com/yo61/logrotate.
yo61's version was a fork of https://github.com/rodjek/puppet-logrotate.
It is licensed under the MIT license.
