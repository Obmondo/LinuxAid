[![Build Status](https://travis-ci.org/loomsen/puppet-rsnapshot.svg?branch=master)](https://travis-ci.org/loomsen/puppet-rsnapshot)

# rsnapshot

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
    * [Notes](#notes)
3. [Setup - The basics of getting started with rsnapshot](#setup)
    * [What rsnapshot affects](#what-rsnapshot-affects)
    * [Setup requirements](#setup-requirements)
    * [Getting started with rsnapshot](#getting-started)
4. [Configuration - options and additional functionality](#configuration)
    * [Examples](#examples)
    * [More Options](#more-options)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Functions](#functions)
    * [Parameters](parameters)
    * [Rsnapshot Configuration Parameters](#rsnapshot-configuration-variables)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Editors](#editors)
8. [Contributors](#contributors)

## Overview

The rsnapshot module installs, configures and manages rsnapshot on a dedicated backup server.

## Module Description
The rsnapshot module installs, configures and manages rsnapshot on a dedicated backup server. It allows to set up a centralized Backup Server for all your nodes.
For the cron setup, the module will pick random time entries for the crons from an Array or a Range of time. For how to configure this, [please see below](#more-options)

### Notes
This module is best used with an ENC like hiera. It will make your config much easier to read and to maintain. Check the examples to see what I mean.

## Setup

### What rsnapshot affects

* This module will install the rsnapshot package on your system
* This module will manage the rsnapshot config on your system
* This module will manage cron entries for your configured nodes
* This module will manage the cron service on your system

### Setup Requirements

On CentOS Systems this module requires the stahnma-epel module. Also you will need to have rsync installed on all nodes to be backed up.
It will create repeatable random cron entries from a configurable timerange for all hosts.

### Getting Started

You will need to pass the nodenames to be backed up at least. 
This will pickup all defaults and add localhost to the backups:


```puppet
class { '::rsnapshot':
  hosts => {
    'localhost' => {},
  }
}
```

## Configuration
Here are some more elaborate examples of what you can do with this module.

### Examples
This will backup localhost with defaults. It will disable the default backup locations for example.com
and just backup '/var' for example.com.

```puppet
class { '::rsnapshot':
  hosts => {
    'localhost' => {},
    'example.com'    => {
      backup_defaults => false,
      backup          => {
        '/var/'       => './'
      }
    }
  }
}
```

The same in hiera:

```yaml
---
classes: rsnapshot
rsnapshot::hosts:
  localhost:
  example.com:
    backup_defaults: false
    backup:
      '/var/': './'
```



A more complete hiera example:

```yaml
---
classes: 
  - rsnapshot

# override default backup dirs for all hosts:
rsnapshot::default_backup:
    '/etc':         './'
    '/usr/local':   './'
    '/home':        './'

# configure hosts to be backed up
rsnapshot::hosts:
# pick all defaults for localhost
  localhost:
# add futher backups for node foo.example.com (additional to default_backup) and use a different snapshot root
  foo.example.com:
    backup:
      '/foo':       './'
      '/bar':       './'
      '/baz':       './misc'
    snapshot_root:  '/tmp/rsnapshot'
# all defaults
  foo1.example.com:
  foo2:
# disable default backup dirs and just backup /var for node bar1
# also set the minute to 0-10 for daily cron (note: this is not particularly useful, it's just meant to document the features)
# lastly set the range of hours to pick a random hour from (the cron for bar1 will have hour set to something between 1 and 5)
  bar1:
    backup_defaults: false
    backup:
      '/var': './var'
    cron:
      mailto: 'bar1@example.com'
      daily:
        minute: '0-10'
        hour:   '1..5'
  db1:
    backup_scripts:
      mysql:
      misc:

```



### More options
The defaults are pretty reasonable, I hope. However, you may override pretty much anything. Available parameters are discussed below. 

#### Specials
This module will generate random time entries for your hosts. The random number generator is hashed with hostname and backup_level, so the randomness will be repeatable per host.level. This is important so puppet won't override the crons with each run.
You may specify time ranges as follows:
  * default cron syntax
  * an array with allowed values
    - for example, if you want the backup for a host to run between 1am and 5am, you would override the hours setting for the host in question.

In hiera this would look like: (Explanation see below)

```yaml
rsnapshot::hosts:
  example.com:
    cron:
      'daily':
        'minute': '1'
        'hour':   '1..5'
```

This will create the rsnapshot config using defaults from params.pp, but set the minute of the daily backup to '1' and the hour to something random between 1 and 5.
So it would look something like:

```
1 4 * * * foo daily
``` 

or maybe

```
1 2 * * * foo daily
```

## Reference

### Classes

#### Public Classes
* rsnapshot: Main class, includes all other classes.

#### Private Classes

* rsnapshot::install: Handles the packages.
* rsnapshot::config: Handles configuration and cron files.
* rsnapshot::params: default values.

### Functions
#### `assert_empty_hash`
Sets an empty value to a hash (we need this so a loop doesn't break if just a hostname is given to pick up all defaults.

#### `pick_undef`
Like pick but returns undef values.

#### `rand_from_array`
Takes an Integer, a String or an Array as input, and returns a random entry from the array (or just the String/Integer)

### Parameters

The following parameters are available in the `::rsnapshot` class:

#### `$backup_defaults`
Boolean. Backup default backup dirs or not.
(Default: true)

#### `$backup_levels`
Array containing the backup levels (hourly, daily, weekly, monthly)
Configure the backup_levels (valid per host and global, so you may either set: rsnapshot::backup_levels for all hosts or override default backup_levels for specific hosts)
(Default: [ 'daily', 'weekly', ] )
#### `$backup_user`
The user to run the backup scripts as 
(Default: root, also the user used for ssh connections, if you change this make sure you have proper key deployed and the user exists in the nodes to be backed up.)
#### `$conf_d`
The place where the configs will be dropped 
(Default: /etc/rsnapshot (will be created if it doesn't exist))
#### `$cron`
Hash. Set time ranges for different backup levels. Each item (minute, hour...) allows for cron notation, an array to pick a random time from and a range to pick a random time from.
The range notation is '$start..$end', so to pick a random hour from 8 pm to 2 am, you could set the hour of your desired backup level to 
`[ '20..23','0..2' ]`
For the range feature to work, hours >0 and <10 must not have a preceding zero. 
Wrong: `00.09`
Correct: `0..9`
Also, you can set a mailto for each host, or globally now. The settings will be merged bottom to top, so if you override a setting in a hosts cron, it will have precedence over the global setting,
which in turn has precedence over the default.

Example:

```puppet
  $cron = {
    mailto     => 'admin@example.com',
    hourly     => {
      minute   => '0..59',
      hour     => [ '20..23','0..2' ],
    }
  }
```

Or in hiera:
- global override

```yaml
rsnapshot::cron:
  mailto: 'admin@example.com'
  daily:
    minute: '20'
  weekly:
    minute: '20'
```

- per host override

```yaml
rsnapshot::hosts:
  webserver:
    cron:
      mailto: 'support@example.com'
      daily:
        hour: [ '20..23','0..2' ]
      weekly:
        hour: [ '20..23','0..2' ]
  
  webhost:

  customervm.provider.com:
    backup_user: 'customer'
```

`webhost`:  Mails will go to `admin@example.com` (from the global override).

`webserver`: Mails will go to `support@example.com`.

`customervm.provider.com`: The backup (and thus ssh) user will be `customer@customervm.provider.com`



Hash is of the form:

```puppet
$cron    =>{
  mailto => param,
  daily => {
    minute => param,
    hour => param,
  }
  weekly => {
    minute => param,
    hour => param,
  }
  {...}
}
```


Default is:

```puppet
  $cron = {
    mailto     => 'admin@example.com',
    hourly     => {
      minute   => '0..59',  # random from 0 to 59
      hour     => '*',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '*',
    },
    daily      => {
      minute   => '0..10',      # random from 0 to 10
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '*',
    },
    weekly     => {
      minute   => '0..59',
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '*',
      month    => '*',
      weekday  => '0..6',
    },
    monthly    => {
      minute   => '0..59',
      hour     => '0..23',      # you could also do:   ['21..23','0..4','5'],
      monthday => '1..28',
      month    => '*',
      weekday  => '*',
    },
  }
```

#### `$cron_dir`
Directory to drop the cron files to. Crons will be created per host. 
(Default: /etc/cron.d)

#### `$cronfile_prefix_use`
Bool. Set this to true if you want your cronfiles to have a prefix.
(Default: false)

#### `$cronfile_prefix`
Optional prefix to add to the cronfiles name. Your files will be named: prefix_hostname
(Default: 'rsnapshot_' only if you set $cronfile_prefix_use = true)

#### `$default_backup`
The default backup directories. This will apply to all hosts unless you set [backup_defaults](#backup_defaults) = false
Default is:

```puppet
  $default_backup         = {
    '/etc'  => './',
    '/home' => './',
  }
```

#### `$hosts`
Hash containing the hosts to be backed up and optional overrides per host
(Default: undef (do nothing when no host given))

#### `$interval`
How many backups of each level to keep.
Default is:

```puppet
  $interval               = {
    'daily'   => '7',
    'weekly'  => '4',
    'monthly' => '6',
  }
```

#### `$package_ensure`
(Default: present)

#### `$package_name`
(Default: rsnapshot)

#### `$snapshot_root`
global. the directory holding your backups.
(Default: /backup)
You will end up with a structure like:

```
/backup/
├── example.com
│   ├── daily.0
│   ├── daily.1
│   ├── daily.2
│   ├── daily.3
│   ├── weekly.0
│   ├── weekly.1
│   ├── weekly.2
│   └── weekly.3
└── localhost
    ├── daily.0
    ├── daily.1
    ├── daily.2
    └── weekly.0
```

#### `$backup_scripts`
Additional scripts to create, possible values are: mysql, psql, misc

`mysql`: used for mysql backups

`psql`: used for postgresql backups

`misc`: custom commands to run on the node

You can set 

`$dbbackup_user`:     backup user

`$dbbackup_password`: password for the backup user

`$dumper`:            path to the dump bin you wish to use

`$dump_flags`:        flags for your dump bin

`$ignore_dbs`:        databases to be ignored (the psql script ignores template and postgres databases by default)

`$commands`:          array of commands to run on the host (this has no effect on psql and mysql scripts and is intended for your custom needs, see misc script section)

See below for defaults

NOTE: the psql and mysql scripts will SSH into your host and try and use $dumper.
Make sure you have those tools installed on your DB hosts.

Also, this module will try and use pbzip to compress your databases. You can install pbzip2 (and additional packages you might need) by passing an array to [$rsnapshot::package_name](#package_name)


Default is:

```puppet
  $backup_scripts = {
    mysql               => {
      dbbackup_user     => 'root',
      dbbackup_password => '',
      dumper            => 'mysqldump',
      dump_flags        => '--single-transaction --quick --routines --ignore-table=mysql.event',
      ignore_dbs        => [ 'information_schema', 'performance_schema' ],
    },
    psql                => {
      dbbackup_user     => 'postgres',
      dbbackup_password => '',
      dumper            => 'pg_dump',
      dump_flags        => '-Fc',
      ignore_dbs        => [ 'postgres' ],
    },
    misc         => {
      commands   => $::osfamily ? {
        'RedHat' =>  [
          'rpm -qa --qf="%{name}," > packages.txt',
        ],
        'Debian' => [
          'dpkg --get-selections > packages.txt',
        ],
        default => [],
      },
    }
  }

```

Configuration example:

```yaml
rsnapshot::backup_scripts:
  mysql:
    dbbackup_user: 'dbbackup'
    dbbackup_password: 'hunter2'
  psql:
    dbbackup_user: 'dbbackup'
    dbbackup_password: 'yeshorsebatterystaple'

rsnapshot::hosts:
  foobar.com:
    backup_scripts:
      mysql:
      psql:
        dumper: '/usr/local/bin/pg_dump'
        dump_flags: '-Fc'
        ignore_dbs: [ 'db1', 'tmp_db' ]
      misc:
  bazqux:de:
    backup_scripts:
      mysql:
        dbbackup_user: 'myuser'
        dbbackup_password: 'mypassword'
      misc:
        commands:
          - 'cat /etc/hostname > hostname.txt'
          - 'date > date.txt'
```

This creates 
- a mysql and a psql backup script for `foobar.com` using the credentials `dbbackup:hunter2` for mysql and `dbbackup:yeshorsebatterystaple` for psql
- the psql script will use `/usr/local/bin/pg_dump` as the dump program with flags `-Fc`
- it will ignore the postgres databases `db1` and `tmp_db` for postgres
- a mysql backup script for `bazqux.de` using the credentials `myuser:mypassword`
- a misc script for bazqux.de containing two commands to run on the node. the output will be redirected to hostname.txt and date.txt in the misc/ subfolder of the hosts backup directory (i.e. /snapshot_root/bazqux.de/daily.0/misc/hostname.txt)

The scripts look like this:

##### `bazqux.de`

```bash
#!/bin/bash
host=bazqux.de
user=myuser
pass=mypassword

dbs=( 
      $(ssh -l root "$host" "mysql -u ${user} -p${pass} -e 'show databases' | sed '1d;/information_schema/d;/performance_schema/d'")  
    )

for db in "${dbs[@]}"; do
  ssh -l root "$host" "mysqldump --user=${user} --password=${pass} --single-transaction --quick --routines --ignore-table=mysql.event ${db}" > "${db}.sql"
  wait
  pbzip2 "$db".sql
done      

```

```bash
#!/bin/bash

ssh bazqux.de 'cat /etc/hostname > hostname.txt'

ssh bazqux.de 'date > date.txt'

```



##### `foobar.com`

psql:

```bash
#!/bin/bash
host=foobar.com
user=dbbackup
pass=yeshorsebatterystaple

PGPASSWORD="$pass"
dbs=( 
      $(ssh -l root "$host" "psql -U ${user} -Atc \"SELECT datname FROM pg_database WHERE NOT datistemplate AND datname ~ 'postgres|db1|tmp_db'\"" )
    )

for db in "${dbs[@]}"; do
  ssh -l root "$host" "pg_dump -U ${user} -Fc ${db}" > "$db".sql
  wait
  pbzip2 "$db".sql
done
```

mysql:


```bash
#!/bin/bash
host=foobar.com
user=dbbackup
pass=hunter2

dbs=( 
      $(ssh -l root "$host" "mysql -u ${user} -p${pass} -e 'show databases' | sed '1d;/information_schema/d;/performance_schema/d'")  
    )

for db in "${dbs[@]}"; do
  ssh -l root "$host" "mysqldump --user=${user} --password=${pass} --single-transaction --quick --routines --ignore-table=mysql.event ${db}" > "${db}.sql"
  wait
  pbzip2 "$db".sql
done      

```

misc (assuming foobar.com is a RedHat node):

```bash
#!/bin/bash

ssh foobar.com 'rpm -qa --qf "%{name}," > packages.txt'

```

##### another example with root user and empty password

mysql with root user:

```bash
#!/bin/bash
host=bazqux.de
user=root
password=

dbs=( 
      $(ssh -l root "$host" "mysql -e 'show databases' | sed '1d;/information_schema/d;/performance_schema/d'")  
    )

for db in "${dbs[@]}"; do
  ssh -l root "$host" "mysqldump --single-transaction --quick --routines --ignore-table=mysql.event ${db}" > "${db}.sql"
  wait
  pbzip2 "$db".sql
done      

```


### rsnapshot configuration variables
Please read up on the following in the [rsnapshot manpage](http://linux.die.net/man/1/rsnapshot)

#### `$config_version`
Default is:  '1.2'

#### `$cmd_cp`
Default is:  '/bin/cp'

#### `$cmd_rm`
Default is:  '/bin/rm'

#### `$cmd_rsync`
Default is:  '/usr/bin/rsync'

#### `$cmd_ssh`
Default is:  '/usr/bin/ssh'

#### `$cmd_logger`
Default is:  '/usr/bin/logger'

#### `$cmd_du`
Default is:  '/usr/bin/du'

#### `$cmd_rsnapshot_diff`
Default is:  '/usr/bin/rsnapshot-diff'

#### `$cmd_preexec`
Default is:  undef

#### `$cmd_postexec`
Default is:  undef

#### `$du_args`
Default is:  undef

#### `$exclude`
Default is:  []

#### `$exclude_file`
Other than this might suggest, the default behavior is to create an exclude file per host.
Default is:  undef

#### `$include`
Default is:  []

#### `$include_file`
Default is:  undef

#### `$link_dest`
Default is:  false

#### `$linux_lvm_cmd_lvcreate`
Default is:  undef # '/sbin/lvcreate'

#### `$linux_lvm_cmd_lvremove`
Default is:  undef # '/sbin/lvremove'

#### `$linux_lvm_cmd_mount`
Default is:  undef # '/sbin/mount'

#### `$linux_lvm_cmd_umount`
Default is:  undef # '/sbin/umount'

#### `$linux_lvm_snapshotsize`
Default is:  undef # '100M'

#### `$linux_lvm_snapshotname`
Default is:  undef

#### `$linux_lvm_vgpath`

Default is:  undef

#### `$linux_lvm_mountpath`
Default is:  undef

#### `$lockpath`
Default is:  '/var/run/rsnapshot'

#### `$logpath`
Default is:  '/var/log/rsnapshot'

#### `$logfile`
unused, we are logging to $logpath/$host.log
Default is:  '/var/log/rsnapshot.log'

#### `$loglevel`
Default is:  '4'

#### `$manage_cron`
Should this module manage the cron service?
Default is: true

#### `$no_create_root`
Boolean: true or false
Default is:  undef

#### `$one_fs`
Default is:  undef

#### `$retain`
Default is:  { }

#### `$rsync_short_args`
Default is:  '-az'

#### `$rsync_long_args`
rsync defaults are: --delete --numeric-ids --relative --delete-excluded 
Default is:  undef

#### `$rsync_numtries`
Default is:  1

#### `$snapshot_root`
Default is:  '/backup/'

#### `$ssh_args`
Default is:  undef

#### `$stop_on_stale_lockfile`
Boolean: true or false
Default is:  undef

#### `$sync_first`
Default is:  false

#### `$use_lvm`
Default is:  undef

#### `$use_lazy_deletes`
Default is:  false

#### `$verbose`
Default is:  '2'

## Limitations
Currently, this module support CentOS, Fedora, Ubuntu and Debian.

## Development
I have limited access to resources and time, so if you think this module is useful, like it, hate it, want to make it better or
want it off the face of the planet, feel free to get in touch with me.

## Editors
Norbert Varzariu (loomsen)

## Contributors
Please see the [list of contributors.](https://github.com/loomsen/puppet-rsnapshot/graphs/contributors)
A big thank you to Hendrik Horeis <hendrik.horeis@gmail.com> for all his input and testing of this module.
