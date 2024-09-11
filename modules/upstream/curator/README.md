[![Puppet Forge](http://img.shields.io/puppetforge/v/pest/curator.svg)](https://forge.puppetlabs.com/pest/curator)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with curator](#setup)
    * [What curator affects](#what-curator-affects)
    * [Beginning with curator](#beginning-with-curator)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)


## Overview

A puppet module for installing and configuring [elastic-curator](https://github.com/elastic/curator).
This module was forked from [ccin2p3-puppet-curator](https://github.com/ccin2p3/puppet-curator) which is a fork of 
cristifalcas-curator and was updated for curator4.

## Module Description

Curator is used to manage and clean up time-series elasticsearch indexes, this module manages curator.

NOTE: If you are using curator < 4.0.0 use a previous version of this module.

The original module allowed you to create various cron jobs for curator.

The new module will only create the config file, one action file and ensure the last folder of the path. 
If there is more than one (folder-)level missing you will have to create that folders externally before this module runs. 
e.g. "/etc/curator/my_settings/" you have to ensure that "/etc/curator" is present.

Also, now it is your job to create the cron job:

```puppet
  cron { "curator_run":
    ensure  => 'present',
    command => '/bin/curator /root/.curator/actions.yml >/dev/null',
    hour    => 1,
    minute  => 10,
    weekday => '*',
  }
```

## Setup

### What curator affects

* curator package
* curator config

### Beginning with curator

Installation of the curator module:

```
  puppet module install pest-curator
```

## Usage

Generic curator install via pip (requires pip is installed)
```puppet
  class { 'curator': }
```

Install via yum
```puppet
  class { 'curator':
    package_name => 'python-elasticsearch-curator',
    provider     => 'yum'
  }
```

Close indexes over 2 days old
```puppet
  curator::action { 'apache_close':
    action                => 'close',
    continue_if_exception => 'True',
    filters               => [
      {
        'filtertype' => 'age',
        'direction'  => 'older',
        'timestring' => '"%Y.%m.%d"',
        'unit'       => 'days',
        'unit_count' => '2',
        'source'     => 'name',
      }
    ]
  }
```

Delete logstash indexes older than a week
```puppet
  curator::action { 'delete_indices':
    action                => 'delete_indices',
    continue_if_exception => 'True',
    filters               => [
      {
        'filtertype' => 'pattern',
        'value'      => 'logstash-',
        'kind'       => 'prefix',
      },
      {
        'filtertype' => 'age',
        'direction'  => 'older',
        'timestring' => '"%Y.%m.%d"',
        'unit'       => 'days',
        'unit_count' => '7',
        'source'     => 'name',
      }
    ]
  }
```

Currently this package supports installing curator via pip or your local
package manager.  RPM packages can easly be created by running:

```
fpm -s python -t rpm urllib3
fpm -s python -t rpm elasticsearch
fpm -s python -t rpm click
fpm -s python -t rpm elasticsearch-curator
```

## Reference

### Public methods

#### Class: curator

#####`ensure`
String.  Version of curator to be installed
Default: latest

#####`manage_repo`
Boolean. Enable repo management by enabling the official repositories.
Default: false

#####`package_provider`
String.  Name of the provider to install the package with.
         If not specified will use system's default provider.
Default: undef

#####`repo_version`
String.  Elastic repositories  are versioned per major release (2, 3)
         select here which version you want.
Default: false

#####`config_file`
String.  Path to configuration file. You must ensure that the directory path exists.
Default: '/root/.curator/curator.yml'

#####`action_file`
String.  Path to actions file. You must ensure that the directory path exists.
Default: '/root/.curator/actions.yml'

#####`hosts`
Array.   The hosts where to connect.
Default: 'localhost'

#####`port`
Number.  The host port where to connect.
Default: 9200

#####`url_prefix`
String.  In some cases you may be obliged to connect to your Elasticsearch cluster through a proxy of some kind.
         There may be a URL prefix before the API URI items, e.g. http://example.com/elasticsearch/ as opposed to
         http://localhost:9200. In such a case, the set the url_prefix to the appropriate value, elasticsearch in this example.
Default: empty string

#####`use_ssl`
Boolean. If access to your Elasticsearch instance is protected by SSL encryption, you must use set use_ssl to True.
Default: False

#####`certificate`
String.  This setting allows the use of a specified CA certificate file to validate the SSL certificate used by Elasticsearch.
Default: empty string

#####`client_cert`
String.  Allows the use of a specified SSL client cert file to authenticate to Elasticsearch. The file may contain both an SSL
         client certificate and an SSL key, in which case client_key is not used. If specifying client_cert, and the file
         specified does not also contain the key, use client_key to specify the file containing the SSL key. The file must be in
         PEM format, and the key part, if used, must be an unencrypted key in PEM format as well.
Default: empty string

#####`client_key`
String.  Allows the use of a specified SSL client key file to authenticate to Elasticsearch. If using client_cert and the file specified
         does not also contain the key, use client_key to specify the file containing the SSL key. The key file must be an unencrypted key
         in PEM format.
Default: empty string

#####`aws_key`
String.  This should be an AWS IAM access key, or left empty.
Default: empty string

#####`aws_secret_key`
String.  This should be an AWS IAM secret access key, or left empty.
Default: empty string

#####`aws_region`
String.  This should be an AWS region, or left empty.
Default: empty string

#####`ssl_no_validate`
Boolean. If access to your Elasticsearch instance is protected by SSL encryption, you may set ssl_no_validate to True to disable SSL
         certificate verification.
Default: False

#####`http_auth`
String.  This setting allows basic HTTP authentication to an Elasticsearch instance.
         This should be a authentication credentials (e.g. user:pass), or left empty.
Default: empty string

#####`timeout`
String.  You can change the default client connection timeout value with this setting.
Default: 30

#####`master_only`
Boolean. In some situations, primarily with automated deployments, it makes sense to install Curator on every node.
         But you wouldn’t want it to run on each node. By setting master_only to True, this is possible. It tests for,
         and will only continue running on the node that is the elected master.
Default: False

#####`loglevel`
String.  Set the minimum acceptable log severity to display. This should be CRITICAL, ERROR, WARNING, INFO, DEBUG, or left empty.
Default: INFO

#####`logfile`
String.  This should be a path to a log file, or left empty.
Default: empty string

#####`logformat`
String.  This should default, json, logstash, or left empty.
Default: default

#####`blacklist`
String.  This should be an empty array [], an array of log handler strings, or left empty.
Default: ['elasticsearch', 'urllib3']
