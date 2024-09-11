# xtrabackup
[![Puppet Forge](https://img.shields.io/puppetforge/v/johnlawerance/xtrabackup.svg)](https://forge.puppetlabs.com/johnlawerance/xtrabackup)
[![Build Status](https://travis-ci.org/johnlawerance/xtrabackup.svg?branch=master)](https://github.com/johnlawerance/xtrabackup)


#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with xtrabackup](#setup)
    * [What xtrabackup affects](#what-xtrabackup-affects)
    * [Beginning with xtrabackup](#beginning-with-xtrabackup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs Percona xtrabackup / innobackupx and schedules automated backups of MySQL, MariaDB, Percona-Server and other MySQL derivitives.

## Setup

### What xtrabackup affects

* Percona repository
* xtrabackup / innobackupx installations
* cronjob for scheduling backups / retention period

### Beginning with xtrabackup

Basic install with required paramaters and default settings.

```puppet
class { ::xtrabackup:
  backup_dir => '/mnt/backup/', 
  mysql_user => 'backup_user',
  mysql_pass => 'backup_password'
}
```

## Usage

All interactions with the xtrabackup module can be performed through the main ::xtrabackup class.

### Minimal installation using default settings:
```puppet
class { ::xtrabackup:
  backup_dir => '/mnt/backup/', 
  mysql_user => 'backup_user',
  mysql_pass => 'backup_password'
}
```

### Install xtrabackup version 2.3.4-1.el7 and the backup script but don't schedule cronjob.
```puppet
class { ::xtrabackup:
  package_version => '2.3.4-1.el7',
  enable_cron     => false,
  backup_dir      => '/mnt/backup/', 
  mysql_user      => 'backup_user',
  mysql_pass      => 'backup_password'
}
```

### Schedule backup for weekly Friday night's at 11PM, set the backup retention to 30 days, and don't install the xtrabackup packages, and don't install the Percona repo:
```puppet
class { ::xtrabackup:
  backup_retention       => '30',
  cron_hour              => '22',
  cron_weekday           => '5',
  install_xtrabackup_bin => false,
  manage_repo            => false,
  backup_dir             => '/mnt/backup/', 
  mysql_user             => 'backup_user',
  mysql_pass             => 'backup_password'
}
```

### Schedule backup with custom xtrabackup options to use 2 threads and compress the output:
```puppet
class { ::xtrabackup:
  xtrabackup_options => '--parallel=2 --compress',
  backup_dir         => '/mnt/backup/', 
  mysql_user         => 'backup_user',
  mysql_pass         => 'backup_password'
}
```

### Schedule backup using innobackupx with custom options to save slave data:
```puppet
class { ::xtrabackup:
  use_innobackupx     => true,
  innobackupx_options => '--slave-info',
  backup_dir          => '/mnt/backup/', 
  mysql_user          => 'backup_user',
  mysql_pass          => 'backup_password'
}
```

## Reference

### Public Classes

* xtrabackup: Main class, includes all other classes.

#### Private Classes

* xtrabackup::repo: Installs and manages the percona repo.
* xtrabackup::install: Installs the packages and backup script.
* xtrabackup::cron: Schedules the cronjob.

### Required Module Parameters
#### `backup_dir`
Location to store the backup files (default: '') [REQUIRED]
#### `mysql_user`
User that should perform the backup (default: '') [REQUIRED]
#### `mysql_pass`
Password that should perform the backup (default: '') [REQUIRED]


### Complete Module Parameters

#### `package_version`
Which version of xtrabackup binaries to install (default: latest)
#### `install_xtrabackup_bin`
Should the module install the Percona xtrabackup packages? (default: true)
#### `manage_repo`
Should the module install the Percona repo? (default: true)
#### `prune_backups`
Should the module manage backup retention? (default: true)
#### `backup_retention`
Time in days the module should keep old backups around (default: 7)
#### `backup_dir`
Location to store the backup files (default: '') [REQUIRED]
#### `use_innobackupx`
Should the module use the `innobackupx` command instead of `xtrabackup`? (default: false)
#### `backup_script_location`
Where should the backup shell script be installed? (default: '/usr/local/bin/')
#### `mysql_user`
User that should perform the backup (default: '') [REQUIRED]
#### `mysql_pass`
Password that should perform the backup (default: '') [REQUIRED]
#### `enable_cron`
Should the module manage the cronjob to perform the backups? (default: true)
#### `cron_hour`
Hour(s) to schedule the backup (default: '1') # Cronjob defaults for daily at 1AM
#### `cron_minute`
Minute(s) to schedule the backup (default: '0')
#### `cron_weekday`
Weekday(s) to schedule the backup (default: '*')
#### `cron_month`
Month(s) to schedule the backup (default: '*')
#### `cron_monthday`
Monthday(s) to schedule the backup (default: '*')
#### `xtrabackup_options`
Extra options to pass to the xtrabackup command (default: '')
#### `innobackupx_options`
Extra options to pass to the innobackupx command (default: '')
#### `logfile`
Location where the shell script output should be logged (default: '/var/log/xtrabackup.log')



## Limitations

### OSes Supported:
* RHEL/CentOS 6, 7
* Ubuntu 12.04, 14.04

### Dependencies:
* puppetlabs-stdlib >= 3.0.0
* puppetlabs-apt >= 2.0.0 (Only required for Ubuntu)

This module has only been tested on CentOS7 and Ubuntu 14.04 using Puppet Enterprise 2015.3

## Development

Please feel free to ask (or submit PRs) for feature requests, improvements, etc!
