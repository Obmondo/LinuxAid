# Cassandra
[![Build Status](https://travis-ci.org/voxpupuli/puppet-cassandra.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-cassandra)

## Table of Contents

1. [Overview](#overview)
1. [Setup - The basics of getting started with Cassandra](#setup)
    * [What Cassandra affects](#what-cassandra-affects)
    * [Upgrading](#upgrading)
    * [Beginning with Cassandra](#beginning-with-cassandra)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Setup a keyspace and users](#setup-a-keyspace-and-users)
    * [Create a Cluster in a Single Data Center](#create-a-cluster-in-a-single-data-center)
    * [Create a Cluster in Multiple Data Centers](#create-a-cluster-in-multiple-data-centers)
    * [DataStax Enterprise](#datastax-enterprise)
    * [Apache Cassandra](#apache-cassandra)
1. [Reference](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development](#development)

## Overview

A Puppet module to install and manage Cassandra, DataStax Agent & OpsCenter

## Setup

### What Cassandra affects

#### What the Cassandra class affects

* Installs the Cassandra package (default **cassandra22** on Red Hat and
  **cassandra** on Debian).
* Configures settings in `${config_path}/cassandra.yaml`.
* On CentOS 7 if the `init` service provider is used, then cassandra
  is added as a system service.
* Optionally ensures that the Cassandra service is enabled and running.
* On Debian systems:
  * Optionally replace ```/etc/init.d/cassandra``` with a workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

#### What the cassandra::datastax_agent class affects

* Optionally installs the DataStax agent.
* Optionally sets JAVA_HOME in **/etc/default/datastax-agent**.

#### What the cassandra::datastax_repo class affects

* Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Debian).

#### What the cassandra::dse class affects

* Optionally configures files in the `/etc/dse` directory if one is using
  DataStax Enterprise.

#### What the cassandra::firewall_ports class affects

* Optionally configures the firewall for the Cassandra related network
  ports.

#### What the cassandra::java class affects

* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk) and the
  Java Native Access (JNA).

#### What the cassandra::optutils class affects

* Optionally installs the Cassandra support tools (e.g. cassandra22-tools).

### Upgrading

We follow [SemVer Versioning](http://semver.org/) and an update of the major
release (i.e. from 1.*Y*.*Z* to 2.*Y*.*Z*) will indicate a significant change
to the API which will most probably require a change to your manifest.

#### Changes in 2.0.0

This is a major change to the API and you will more than likely need to
change your manifest to accomodate these changes.

The `service_ensure` attribute of the cassandra class now defaults to
*undef*, users who do want to manage service status in Puppet can still set
it to true.  If leaving the value at the default and setting
`service_refresh` and `service_enable` to false will mean that the
user and not Puppet running will control the running state of
Cassandra.  This currently works OK on the Red Hat family, but
has issues on Debian due to
[CASSANDRA-2356](https://issues.apache.org/jira/browse/CASSANDRA-2356)
during an initial install or package upgrade.

All the functionality relating to OpsCenter has been divested to the
[locp/opscenter](https://forge.puppet.com/locp/opscenter) module on
Puppet Forge.

It should also be noted that the module no longer creates directories for
the `data`, `commitlog`, `saved_caches` and for Cassandra 3 the `hints`
directory.  These resources will now need to be defined in your
manifest/profile.

For a list of features that have been deprecated in this release, please see
https://github.com/voxpupuli/puppet-cassandra/wiki/Deprecations

For details on migrating from the version 1.X.X attributes to the `settings`
hash, see
(https://github.com/voxpupuli/puppet-cassandra/wiki/Suggested-Baseline-Settings)

Please also see the notes for 2.0.0 in the
[CHANGELOG](./CHANGELOG.md).

#### Changes in 1.19.0

The hints_directory documentation will cause a change in the cassandra.yaml
file regardless of the value you set it to.  If you do not wish this to
result in a refesh of the Cassandra service, please set service_refresh to
false.

#### Changes in 1.9.2

Now that Cassandra 3 is available from the DataStax repositories, there is
a problem (especially on Debian) with the operating system package manager
attempting to install Cassandra 3.  This can be mitigated against using
something similar to the code in this modules acceptance test.  Please note
that the default Cassandra package name has now been changed from 'dsc'.  See
the documentation for cassandra::package_name below for details.

```puppet
 if $::osfamily == 'RedHat' {
   $version = '2.2.4-1'
 } else {
   $version = '2.2.4'
 }

 class { 'cassandra':
   package_ensure => $version,
 }
```

#### Changes in 1.8.0

A somewhat embarrassing correction to the spelling of the
cassandra::fail_on_non_suppoted_os to cassandra::fail_on_non_supported_os.

#### Issues when Upgrading to 1.4.0

Unfortunately both releases 1.3.7 and 1.4.0 have subsequently been found to
call a refresh service even when no changes had been made to the underlying
configuration.  In release 1.8.0 (somewhat belatedly) the service_refresh
flag has been introduced to mitigate against similar problems.

#### Issues When Upgrading to 1.3.7

* Please see the notes for 1.4.0.

#### Changes in 1.0.0

* cassandra::cassandra_package_ensure has been renamed to
  cassandra::package_ensure.
* cassandra::cassandra_package_name has been renamed to
  cassandra::package_name.

#### Changes in 0.4.0

There is now a cassandra::datastax_agent class, therefore:

* cassandra::datastax_agent_package_ensure has now been replaced with
  cassandra::datastax_agent::package_ensure.
* cassandra::datastax_agent_service_enable has now been replaced with
  cassandra::datastax_agent::service_enable.
* cassandra::datastax_agent_service_ensure has now been replaced with
  cassandra::datastax_agent::service_ensure.
* cassandra::datastax_agent_package_name has now been replaced with
  cassandra::datastax_agent::package_name.
* cassandra::datastax_agent_service_name has now been replaced with
  cassandra::datastax_agent::service_name.

Likewise now there is a new class for handling the installation of Java:

* cassandra::java_package_ensure has now been replaced with
  cassandra::java::ensure.
* cassandra::java_package_name has now been replaced with
  cassandra::java::package_name.

Also there is now a class for installing the optional utilities:

* cassandra::cassandra_opt_package_ensure has now been replaced with
  cassandra::optutils:ensure.
* cassandra::cassandra_opt_package_name has now been replaced with
  cassandra::optutils:package_name.

#### Changes in 0.3.0

* cassandra_opt_package_ensure changed from 'present' to undef.

* The manage_service option has been replaced with service_enable and
  service_ensure.

### Beginning with Cassandra

Create a Cassandra 2.X cluster called MyCassandraCluster which uses the
GossipingPropertyFileSnitch and password authentication.  In this very
basic example the node itself becomes a seed for the cluster and the
credentials will default to a user called cassandra with a password
called of cassandra.

```puppet
# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

class { 'cassandra':
  settings => {
    'authenticator'               => 'PasswordAuthenticator',
    'cluster_name'                => 'MyCassandraCluster',
    'commitlog_directory'         => '/var/lib/cassandra/commitlog',
    'commitlog_sync'              => 'periodic',
    'commitlog_sync_period_in_ms' => 10000,
    'data_file_directories'       => ['/var/lib/cassandra/data'],
    'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
    'listen_address'              => $::ipaddress,
    'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
    'seed_provider'               => [
      {
        'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'parameters' => [
          {
            'seeds' => $::ipaddress,
          },
        ],
      },
    ],
    'start_native_transport'      => true,
  },
  require  => Class['cassandra::datastax_repo', 'cassandra::java'],
}
```
However, **PLEASE** note that this is the **ABSOLUTE MINIMUM** configuration
to get Cassandra up and running but will probably give you a rather badly
configured node.  Please see
[Suggested Baseline Settings](https://github.com/voxpupuli/puppet-cassandra/wiki/Suggested-Baseline-Settings)
for details on making your configuration a lot more robust.

For this code to run with version 3.X of Cassandra, the `hints_directory` will
also need to be specified:

```puppet
...

class { 'cassandra':
  settings => {
    ...
    'hints_directory'             => '/var/lib/cassandra/hints',
    ...
  },
  require  => Class['cassandra::datastax_repo', 'cassandra::java'],
}
```

### Hiera

In your top level node classification (usually `common.yaml`), add the
settings hash and all the tweaks you want all the clusters to use:

```YAML
cassandra::baseline_settings:
  authenticator: AllowAllAuthenticator
  authorizer: AllowAllAuthorizer
  auto_bootstrap: true
  auto_snapshot: true
  ...
```

Then, in the individual node classification add the parts which define
the cluster:

```YAML
cassandra::settings:
  cluster_name: developer playground cassandra cluster
cassandra::dc: Onsite1
cassandra::rack: RAC1
cassandra::package_ensure: 3.0.5-1
cassandra::package_name: cassandra30
```

## Usage

### Setup a keyspace and users

We assume that authentication has been enabled for the cassandra
cluster and we are connecting with the default user name and password
('cassandra/cassandra').

In this example, we create a keyspace (mykeyspace) with a table called
'users' and an index called 'users_lname_idx'.

We also add three users (to Cassandra, not the mykeyspace.users
table) called spillman, akers and boone while ensuring that a user
called lucan is absent.

```puppet
class { 'cassandra':
  ...
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  cqlsh_host     => $::ipaddress,
  indexes        => {
    'users_lname_idx' => {
      table    => 'users',
      keys     => 'lname',
      keyspace => 'mykeyspace',
    },
  },
  keyspaces      => {
    'mykeyspace' => {
      durable_writes  => false,
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 1,
      },
    }
  },
  permissions    => {
    'Grant select permissions to spillman to all keyspaces' => {
      permission_name => 'SELECT',
      user_name       => 'spillman',
    },
    'Grant modify to to keyspace mykeyspace to akers'       => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'MODIFY',
      user_name       => 'akers',
    },
    'Grant alter permissions to mykeyspace to boone'        => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      user_name       => 'boone',
    },
    'Grant ALL permissions to mykeyspace.users to gbennet'  => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      table_name      => 'users',
      user_name       => 'gbennet',
    },
  },
  tables         => {
    'users' => {
      columns  => {
        user_id       => 'int',
        fname         => 'text',
        lname         => 'text',
        'PRIMARY KEY' => '(user_id)',
      },
      keyspace => 'mykeyspace',
    },
  },
  users          => {
    'spillman' => {
      password => 'Niner27',
    },
    'akers'    => {
      password  => 'Niner2',
      superuser => true,
    },
    'boone'    => {
      password => 'Niner75',
    },
    'gbennet'  => {
      'password' => 'foobar',
    },
    'lucan'    => {
      'ensure' => absent
    },
  },
}
```

### Create a Cluster in a Single Data Center

In the DataStax documentation _Initializing a multiple node cluster (single
data center)_
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initSingleDS.html>
there is a basic example of a six node cluster with two seeds to be created in
a single data center spanning two racks.  The nodes in the cluster are:

**Node Name**  | **IP Address** |
---------------|----------------|
node0 (seed 1) | 110.82.155.0   |
node1          | 110.82.155.1   |
node2          | 110.82.155.2   |
node3 (seed 2) | 110.82.156.3   |
node4          | 110.82.156.4   |
node5          | 110.82.156.5   |

Each node is configured to use the GossipingPropertyFileSnitch and 256 virtual
nodes (vnodes).  The name of the cluster is _MyCassandraCluster_.  Also,
while building the initial cluster, we are setting the auto_bootstrap
to false.

In this initial example, we are going to expand the example by:

* Ensuring that the software is installed via the DataStax Community
  repository by including `cassandra::datastax_repo`.  This needs to be
  executed before the Cassandra package is installed.
* That a suitable Java Runtime environment (JRE) is installed with Java Native
  Access (JNA) by including `cassandra::java`.  This need to be executed
  before the Cassandra service is started.

```puppet
node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  }

  class { 'cassandra::java':
    before => Class['cassandra']
  }

  class { 'cassandra':
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}
```

The default value for the num_tokens is already 256, but it is
included in the example for clarity.  Do not forget to either
set auto_bootstrap to true or not set the attribute at all
after initializing the cluster.

### Create a Cluster in Multiple Data Centers

To continue with the examples provided by DataStax, we look at the example
for a cluster across multiple data centers
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initMultipleDS.html>.

**Node Name**  | **IP Address** | **Data Center** | **Rack** |
---------------|----------------|-----------------|----------|
node0 (seed 1) | 10.168.66.41   | DC1             | RAC1     |
node1          | 10.176.43.66   | DC1             | RAC1     |
node2          | 10.168.247.41  | DC1             | RAC1     |
node3 (seed 2) | 10.176.170.59  | DC2             | RAC1     |
node4          | 10.169.61.170  | DC2             | RAC1     |
node5          | 10.169.30.138  | DC2             | RAC1     |

For the sake of simplicity, we will confine this example to the nodes:

```puppet
node /^node[012]$/ {
  class { 'cassandra':
    dc             => 'DC1',
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}

node /^node[345]$/ {
  class { 'cassandra':
    dc             => 'DC2',
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}
```

We don't need to specify the rack name (with the rack attribute) as RAC1 is
the default value.  Again, do not forget to either set auto_bootstrap to
true or not set the attribute at all after initializing the cluster.

### DataStax Enterprise

After configuring the relevant repository, the following snippet works on
CentOS 7 to install DSE Cassandra 4.7.0, set the HADOOP_LOG_DIR, set the
DSE_HOME and configure DataStax Enterprise to use LDAP for authentication:

```puppet
class { 'cassandra::datastax_repo':
  descr   => 'DataStax Repo for DataStax Enterprise',
  pkg_url => 'https://username:password@rpm.datastax.com/enterprise',
  before  => Class['cassandra'],
}

class { 'cassandra':
  cluster_name    => 'MyCassandraCluster',
  config_path     => '/etc/dse/cassandra',
  package_ensure  => '4.7.0-1',
  package_name    => 'dse-full',
  service_name    => 'dse',
  ...
}

class { 'cassandra::dse':
  file_lines => {
    'Set HADOOP_LOG_DIR directory' => {
      ensure => present,
      path   => '/etc/dse/dse-env.sh',
      line   => 'export HADOOP_LOG_DIR=/var/log/hadoop',
      match  => '^# export HADOOP_LOG_DIR=<log_dir>',
    },
    'Set DSE_HOME'                 => {
      ensure => present,
      path   => '/etc/dse/dse-env.sh',
      line   => 'export DSE_HOME=/usr/share/dse',
      match  => '^#export DSE_HOME',
    },
  },
  settings   => {
    ldap_options => {
      server_host                => localhost,
      server_port                => 389,
      search_dn                  => 'cn=Admin',
      search_password            => secret,
      use_ssl                    => false,
      use_tls                    => false,
      truststore_type            => jks,
      user_search_base           => 'ou=users,dc=example,dc=com',
      user_search_filter         => '(uid={0})',
      credentials_validity_in_ms => 0,
      connection_pool            => {
        max_active => 8,
        max_idle   => 8,
      }
    }
  }
}
```

### Apache Cassandra
DataStax announced in late October 2016 that it was no longer supporting
the community edition of Cassandra or DSC as it was known (see
*[Take a bow Planet
Cassandra]*(http://www.datastax.com/2016/10/take-a-bow-planet-cassandra)
for details).  However, the following snippet of code running on Ubuntu
14.04 worked fine without having to change any of the `::cassandra` class
settings:

```puppet
require cassandra::java
include cassandra::optutils

class { 'cassandra::apache_repo':
  release => '310x',
  before  => Class['cassandra', 'cassandra::optutils'],
}

class { 'cassandra':
  ...
}
```

## Reference

The reference documentation is generated using the
[puppet-strings](https://github.com/puppetlabs/puppet-strings) tool.  To see
all of it, please go to
[http://voxpupuli.github.io/puppet-cassandra](http://voxpupuli.github.io/puppet-cassandra/_index.html).

## Limitations

* When using a Ruby version before 1.9.0, the contents of the Cassandra
configuration file may change order of elements due to a problem with
to_yaml in earlier versions of Ruby.
* When creating key spaces, indexes, cql_types and users the settings will only
be used to create a new resource if it does not currently exist.  If a change
is made to the Puppet manifest but the resource already exits, this change
will not be reflected.
* At the moment the `cassandra::system::transparent_hugepage` does not
persist between reboots.
* Acceptance for Debian 7 are confined to Cassandra 2.1 and 2.2.  There is
a conflict between the GLIBC on Debian 7 and the newer releases of Cassandra
3.X.

## Development

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

Please also see the
[CONTRIBUTING.md](./CONTRIBUTING.md)
page for project specific requirements.

### Additional Contributers

For a list of contributers see
[CONTRIBUTING.md](./CONTRIBUTING.md)
and https://github.com/voxpupuli/puppet-cassandra/graphs/contributors
