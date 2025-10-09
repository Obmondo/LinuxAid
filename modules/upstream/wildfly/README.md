# wildfly

[![Build Status](https://travis-ci.org/biemond/biemond-wildfly.svg?branch=master)](https://travis-ci.org/biemond/biemond-wildfly) ![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/biemond/wildfly.svg) ![Puppet Forge Version](https://img.shields.io/puppetforge/v/biemond/wildfly.svg) ![Puppet Forge Score](https://img.shields.io/puppetforge/f/biemond/wildfly.svg)  ![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/biemond/wildfly.svg) [![Code Climate](https://codeclimate.com/github/biemond/biemond-wildfly/badges/gpa.svg)](https://codeclimate.com/github/biemond/biemond-wildfly) [![Coverage Status](https://coveralls.io/repos/biemond/biemond-wildfly/badge.svg?branch=master&service=github)](https://coveralls.io/github/biemond/biemond-wildfly?branch=master)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wildfly](#setup)
    * [What wildfly affects](#what-wildfly-affects)
    * [Setup requirements](#setup-requirements)
4. [Upgrade](#upgrade)
    * [to 1.2.0](#to-120)
    * [to 2.0.0](#to-200)
5. [Usage - Configuration options and additional functionality](#usage)
    * [Wildfly 10.1.0](#wildfly-1010)
    * [Wildfly 9.0.2](#wildfly-902)
    * [Wildfly 8.2.1](#wildfly-821)
    * [JBoss EAP 6.x (with hiera)](#jboss-eap-6x-with-hiera)
    * [JBoss EAP 7.0](#jboss-eap-70)
    * [Keycloak](#keycloak)
    * [apiman](#apiman)
    * [Infinispan Server](#infinispan-server)
    * [Wildfly's Configuration Management](#wildfly-configuration-management)
    * [Patch management](#patch-management)
    * [Unmanaged installation](#unmanaged-installation)
    * [Domain Mode](#domain-mode)
    * [Deployment](#deployment)
    * [User management](#user-management)
    * [Module installation](#module-installation)
    * [Datasources](#datasources)
    * [HTTPS/SSL](#httpsssl)
    * [Server reload](#server-reload)
    * [Messaging](#messaging)
    * [Logging](#logging)
    * [Modcluster](#modcluster)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

created by Edwin Biemond email biemond at gmail dot com
[biemond.blogspot.com](http://biemond.blogspot.com)
[Github homepage](https://github.com/biemond/biemond-wildfly)

Install, configures and manages Wildfly.

Should work on every Redhat or Debian family member, tested with Wildfly 10.1, 10.0, 9.0, 8.2, 8.1 & 8.0 and with JBoss EAP (tested on 6.1/6.2/6.3/6.4 and 7.0). Some defines may work only in certain versions.

[Vagrant Fedora 21, Puppet 4.2.1 example](https://github.com/biemond/vagrant-fedora20-puppet) with Wildfly 8.2 and Apache AJP, Postgres db.

[Vagrant CentOS Standalone HA + Gossip Router example](https://github.com/jairojunior/wildfly-ha-tcpgossip-vagrant-puppet) with two nodes, a gossip router and a load balancer (httpd + mod_cluster).

[Vagrant CentOS 7.2 Domain Mode](https://github.com/jairojunior/wildfly-domain-vagrant-puppet) with two nodes (Domain master and slave) and a load balancer.

[MCollective JBoss Agent Plugin](https://github.com/jairojunior/mcollective-jboss-agent) might be useful if you want to make consistent large scale changes.

## Module Description

The wildfly module can install, configure and manage - through its HTTP Management API - Wildfly (8/9/10) and JBoss EAP (6.1+/7.0+).

## Setup

### What wildfly affects

* Manage Wildfly user, group and directory.

* Creates a wildfly service using bundled scripts and manages its installation and resources (using [Management API](https://docs.jboss.org/author/display/WFLY10/Management+API+reference))

* Installs requisite libaio and wget packages

### Setup Requirements

This module requires a JVM ( should already be there ). Just need to be extracted somewhere, no need to update-alternatives, set PATH or anything else, but it also works if you choose to do so.

Three gems are bundled with this module: `treetop` (parsing JBoss-CLI commands), `polyglot` (treetop's requirement) and `net-http-digest_auth` (Management API authentication).

Acceptance tests works with **puppetlabs/java** in both CentOS and Debian.

This module requires `puppetlabs-stdlib` and `jethrocarr/initfact` (it uses `init_system` fact provided by this module by default, but it's overridable in `wildfly::initsystem` parameter)

It should work on every operating system with the following init systems: sysvinit, systemd and upstart

## Upgrade

## to 1.2.0

### wildfly class

The main changes in `wildfly` class are bellow:

```puppet
class { '::wildfly':
  distribution     => 'jboss-eap|wildfly',
  properties       => {
    'jboss.bind.address'            => $public_bind,
    'jboss.bind.address.management' => $mgmt_bind,
    'jboss.management.http.port'    => $mgmt_http_port,
    'jboss.management.https.port'   => $mgmt_https_port,
    'jboss.http.port'               => $public_http_port,
    'jboss.https.port'              => $public_https_port,
    'jboss.ajp.port'                => $ajp_port,
  },
  jboss_opts       => '-Dproperty=value'
  mgmt_user        => { username  => $management_user, password  => $management_password },
}
```

`distribution` was introduced to provided out of the box support for JBoss EAP and `properties` to replace fine-grained parameters for address/port binding like `public_bind`, `mgmt_bind` and `public_http_port`. (*Reason*: It's easier to manage a properties file than Wildfly's XML through augeas)

`users_mgmt` was replaced by `mgmt_user`, and additional users should be managed by `wildfly::config::mgtm_user` defined type. The hash format and default value also changed.

### New dependency

`jethrocarr/initfact` module.

### Defined types

All resources from `wildfly::util` were moved to `wildfly`, hence you need to search and replace them, I suggest you execute these commands in your environment:

`find . -name '*.pp' -type f -exec sed -i 's/wildfly::util::exec_cli/wildfly::cli/g' {} +`

`find . -name '*.pp' -type f -exec sed -i 's/wildfly::util/wildfly/g' {} +`

## to 2.0.0

This version requires Puppet 4.4+ and heavily uses Puppet 4 new features: data types, epp templates and Ruby 2.1+, but there is no breaking change per se.

If you're still using Puppet 3.x with Ruby 1.8.7+ check version 1.2.x.

## Usage

```puppet
class { 'wildfly': }
```

### Wildfly 10.1.0

```puppet
class { 'wildfly':
  version        => '10.1.0',
  install_source => 'http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz',
}
```

### Wildfly 9.0.2

```puppet
class { 'wildfly':
  version        => '9.0.2',
  install_source => 'http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz',
}
```

### Wildfly 8.2.1

```puppet
class { 'wildfly':
  version        => '8.2.1',
  install_source => 'http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz',
}
```

### JBoss EAP 6.x (with hiera)

```puppet
include ::wildfly
```

```yaml
wildfly::distribution: 'jboss-eap'
wildfly::version: '6.4'
wildfly::install_source: 'http://mywebserver/jboss-eap-6.4.tar.gz'
wildfly::user: 'jboss-as'
wildfly::group: 'jboss-as'
wildfly::dirname: '/opt/jboss-as'
wildfly::console_log: '/var/log/jboss-as/console.log'
```

### JBoss EAP 7.0

```puppet
class { 'wildfly':
  version        => '7.0',
  distribution   => 'jboss-eap',
  install_source => 'http:/mywebserver/jboss-eap-7.0.tar.gz',
  user           => 'jboss-eap',
  group          => 'jboss-eap',
  dirname        => '/opt/jboss-eap',
  console_log    => '/var/log/jboss-eap/console.log',
}
```


### Keycloak

[Keycloak](http://www.keycloak.org/) is an open source Identity and Access Management built on top of Wildfly/JBoss platform, therefore you should be able to use this module to install and config it.

```puppet
class { 'wildfly':
  version        => '10.1.0',
  distribution   => 'wildfly',
  install_source => 'https://downloads.jboss.org/keycloak/2.5.0.Final/keycloak-2.5.0.Final.tar.gz',
}
```
> **NOTE:** Just make sure to point to the right version/distribution it was built upon.

Some Keycloak configuration can be managed in the same way of a regular Wildfly/Jboss configuration:

```puppet
wildfly::datasources::datasource { 'KeycloakDS':
  config => {
    'driver-name'    => 'postgresql',
    'password'       => 'keycloak',
    'user-name'      => 'keycloak',
    'jndi-name'      => 'java:jboss/datasources/KeycloakDS',
    'connection-url' => "jdbc:postgresql://192.168.33.20:5432/keycloak",
    'background-validation' => true,
    'background-validation-millis' => 60000,
    'check-valid-connection-sql' => 'SELECT 1',
    'flush-strategy' => 'IdleConnections',
  }
}
```

### apiman

[apiman](http://www.apiman.io) is an API Manager built on top of Wildfly/JBoss, therefore you should be able to use this module to install and config it.

Currently there aren't no prebuilt packages, but download page provides instruction to build it for Wildfly 10, 9 and EAP 7.


#### Example

```shell
wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.zip
wget http://downloads.jboss.org/apiman/1.2.9.Final/apiman-distro-wildfly10-1.2.9.Final-overlay.zip
unzip wildfly-10.1.0.Final.zip
unzip -o apiman-distro-wildfly10-1.2.9.Final-overlay.zip -d wildfly-10.1.0.Final
tar czvf apiman-wildfly-10.1.0.Final.tar.gz wildfly-10.1.0.Final
```

```puppet
class { 'wildfly':
  version        => '10.1.0',
  distribution   => 'wildfly',
  config         => 'standalone-apiman.xml',
  install_source => 'http://10.0.2.2:9090/apiman-wildfly-10.1.0.Final.tar.gz',
}
```

> **NOTE:** Just make sure to point to the right version/distribution it was built upon.

### Infinispan Server

Infinispan Server (or JBoss Data Grid) also work with this module but requires more tweaks.

From Infinispan Server 7 to 9 (including JDG 7.0) you will only need to change `install_source` to match the desired version:

```puppet
class { 'wildfly':
  install_source => 'http://10.0.2.2:9090/infinispan-server-8.2.5.Final.tar.gz',
  conf_file      => '/etc/infinispan-server/infinispan-server.conf',
  conf_template  => 'wildfly/infinispan-server.conf.erb',
  service_file   => 'bin/init.d/infinispan-server.sh',
  service_name   => 'infinispan-server',
}
```

> **Limitation:** You need to repackage it to a tar.gz file and Infinispan Server 6 and JDG 6.x are not working.

### Wildfly's Configuration Management

Wildfly has a [Management Model](https://docs.jboss.org/author/display/WFLY8/Description+of+the+Management+Model) that describes its configuration and there are three main elements that you need to understand in order to use this module: `path`, `attributes` and `operations`

This module provides a few defined types built around these concepts using `wildfly_resource` and `wildfly_cli` (`wildfly::messaging::*`, `wildfly:datasources::datasource`, `wildfly:datasources::driver`) to ease management of most used resources, but they are not guaranteed to work across all versions of JBoss/Wildfly and they represent only a tiny subset of the Management Model.

In order to manage virtually any configuration in the [Model Reference](https://wildscribe.github.io/) (i.e. datasources, https, queues, modcluster) with `wildfly::resource` or `wildfly::cli` you must understand how declared resources are converted to Management API requests using `paths`, `attributes` and `operations`.

**Path/Addresss:** The resource address in `/node-type=node-name (/node-type=node-name)*` format. (e.g. `/subsystem=datasources/datasource=DatasourceName`)

**Attributes:** key-value pairs that describes the resource. (e.g. `driver-name=postgresql`, `connection-url=jdbc:postgresql://localhost/postgres`)

**Operations:** An operation to be performed in a resource. (e.g. `read`, `write-attribute`, `remove`)

With `wildfly::cli` you have more control, but you should only use it when you can't manage the resource with `wildfly_resource` (e.g. you can't manage `enabled` attribute as it is only changed as a result of `enable` and `disable` **operations**.):

```puppet
wildfly::cli { "Enable ADatasource":
  command => "/subsystem=datasources/data-source=ADatasource:enable",
  unless  => "(result == true) of /subsystem=datasources/data-source=ADatasource:read-attribute(name=enabled)",
}
```

For all other scenarios, `wildfly::resource` will be your best friend, from the most simple resource:

```puppet
wildfly::resource { "/system-property=myproperty":
  content => {
    'value' => '1234'
  },
}
```

To the most complex:

```puppet
wildfly::resource { '/subsystem=modcluster/mod-cluster-config=configuration':
  recursive => true,
  content   => {
        'advertise'             => true,
        'connector'             => 'ajp',
        'excluded-contexts'     => 'ROOT,invoker,jbossws,juddi,console',
        'proxy-url'             => '/',
        'sticky-session'        => true,
        'proxies'               => ['192.168.1.1:6666', '192.168.1.2::6666']
        'balancer'              => 'mybalancer',
        'load-balancing-group'  => 'mygroup',
        'dynamic-load-provider' => {'configuration' => {
            'load-metric' => {'busyness' => {
                'type' => 'busyness',
            }}
        }},
    }
}
```

The first thing to note about `wildfly::resource` is the absence of an **operation**, as you will only need to set `ensure` with either present or absent, using the first will result in the creation or update of the resource with the declared state/content, whereas the other will remove the resource with all its children.

A resource attribute behaviors like a Puppet resource property. Therefore, **unmanaged attributes** behavior like **unmanaged properties** in puppet resources, meaning: *if you don't declare, you don't care*.

> **NOTE:** Be careful with the type of declared attribute's value as it should match Management Model type. Valid Management Model types include: `STRING`, `INT`, `BOOLEAN`, `LIST` (i.e. arrays []) and `OBJECT` (i.e. hashes {}).

### Patch management

Wildfly/JBoss allows you to apply patches to existing installation in order to update it. I suggest you use `puppet-archive` or any other `archive` module to download patches from remote sources, just be aware that you need to extract patch zip file in order to apply patches to Wildfly, but you'll be able to apply the zip file directly when you're using EAP.

> **NOTE:** Wildfly from versions 8.0.0 to 9.0.1 has a bug in `jboss-cli.sh` [WFCORE-160](https://issues.jboss.org/browse/WFCORE-160) that makes it report that a patch hasn't been successfuly applied (exit code 2) even when it was. If you're using one of theses versions you better update this file or live with a bad report.

#### Offline

Offline patching requires the server to be down, but don't leave the server in a `restart-required` state.

##### EAP/Offline example

```puppet
class { '::wildfly':
  distribution   => 'jboss-eap',
  version        => '6.4',
}

archive { '/opt/wildfly/jboss-eap-6.4.8-patch.zip':
  ensure => present,
  source => 'http://10.0.2.2:9090/jboss-eap-6.4.8-patch.zip',
}
->
wildfly::patch::offline { '6.4.8':
  source => '/opt/wildfly/jboss-eap-6.4.8-patch.zip',
}
```

#### Online

Online patching requires the server to be up and requires a restart after being applied.

##### Wildfly/Online example

```puppet
class { '::wildfly':
  version        => '10.0.0',
  install_source => 'http://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.tar.gz',
}

archive { '/opt/wildfly/wildfly-10.1.0.Final-update.zip':
  ensure       => present,
  extract      => true,
  extract_path => '/opt/wildfly',
  creates      => '/opt/wildfly/wildfly-10.1.0.Final.patch',
  source       => 'http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final-update.zip',
  user         => 'wildfly',
  group        => 'wildfly',
  require      => [File['/opt/wildfly'],Package['unzip']],
}
->
wildfly::patch::online { '10.1.0':
  source       => '/opt/wildfly/wildfly-10.1.0.Final.patch',
  override_all => true,
}
```

### Unmanaged installation

If you don't want to use this module to manage your Wildfly/JBoss installation or you don't want to manage your installation with Puppet at all. You still can use this module to manage your configuration using `wildfly_resource`, `wildfly_cli`, `wildfly_deployment` and `wildfly_restart`.

Example:

```puppet
wildfly_resource { "/subsystem=datasources/data-source=MyDS":
  ensure            => 'present',
  username          => 'admin',
  password          => 'password',
  host              => '192.168.33.10',
  port              => '9990',
  state             => {
    'driver-name'    => 'postgresql',
    'connection-url' => 'jdbc:postgresql://localhost/postgres',
    'jndi-name'      => 'java:jboss/datasources/MyDS',
    'user-name'      => 'postgres',
    'password'       => 'postgres',
  },
}
```

### Domain Mode

#### Master (Domain Controller)

```puppet
class { 'wildfly':
  mode        => 'domain',
  host_config => 'host-master.xml',
  properties  => {
    'jboss.bind.address.management' => '172.17.0.2',
  },
}

wildfly::config::mgmt_user { 'slave1':
  password => 'wildfly',
}
```

> **NOTE:** Don't forget to set `target_profile` while managing your domain resources.

#### Slave (Host Controller)

```puppet
class { 'wildfly':
    mode         => 'domain',
    host_config  => 'host-slave.xml',
    properties   => {
      'jboss.domain.master.address' => '172.17.0.2',
    },
    secret_value => 'd2lsZGZseQ==', #base64('wildfly'),
}
```

#### Domain Management

Make sure you remove default resources (server-groups and server-config) if you're not going to use it.

Domain controller:

```puppet
wildfly::resource { ['/server-group=main-server-group', '/server-group=other-server-group'] :
  ensure => absent,
}
```

Host controller:

``` puppet
wildlfy::resource { ['/host=slave1/server-config=server-one', '/host=slave1/server-config=server-two']:
  ensure => absent,
}
```

Then start managing your own `server-groups` and `server-config` with `wildfly::domain::server-group` and `wildfly::host::server_config`

### Deployment

#### From a local or remote source

Source supports these protocols: `http://`, `ftp://`, `puppet://`, `file://`

```puppet
wildfly::deployment { 'hawtio.war':
 source => 'http://central.maven.org/maven2/io/hawt/hawtio-web/1.4.48/hawtio-web-1.4.48.war',
}
```

```puppet
wildfly::deployment { 'hawtio.war':
 source => 'puppet:///modules/profile/wildfly/hawtio-web-1.4.48.war',
}
```

```puppet
wildfly::deployment { 'hawtio.war':
 source => 'file://var/tmp/hawtio-web-1.4.48.war',
}
```

#### To a target server-group (domain mode)

```puppet
wildfly::deployment { 'hawtio.war':
 source       => 'http://central.maven.org/maven2/io/hawt/hawtio-web/1.4.48/hawtio-web-1.4.48.war',
 server_group => 'main-server-group',
}
```

#### From nexus

> **NOTE:** This feature was removed to avoid 'archive' name collision, but you can still use [archive::nexus](https://github.com/voxpupuli/puppet-archive/#archivenexus) to download an artifact and use as an input for `wildfly::deployment`

```puppet
archive::nexus { '/tmp/hawtio.war':
  url        => 'https://oss.sonatype.org',
  gav        => 'io.hawt:hawtio-web:1.4.66',
  repository => 'releases',
  packaging  => 'war',
}
~>
wildfly::deployment { 'hawtio.war':
  source => '/tmp/hawtio.war'
}
```

### User management

You can add App and Management users (requires server restart).

```puppet
wildfly::config::mgmt_user { 'mgmtuser':
  password => 'mgmtuser'
}
```

```puppet
wildfly::config::app_user { 'appuser':
  password => 'appuser'
}
```

And associate groups or roles to them (requires server restart)

```puppet
wildfly::config::user_groups { 'mgmtuser':
  groups => 'admin,mygroup'
}
```

```puppet
wildfly::config::user_roles { 'appuser':
  roles => 'guest,ejb'
}
```

### Module installation

Install a JAR module from a remote file system, puppet file server or local file system.

```puppet
wildfly::config::module { 'org.postgresql':
  source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar',
  dependencies => ['javax.api', 'javax.transaction.api']
}
```

```puppet
wildfly::config::module { 'org.postgresql':
  source       => 'puppet:///modules/profiles/wildfly/postgresql-9.3-1103-jdbc4.jar',
  dependencies => ['javax.api', 'javax.transaction.api']
}
```

```puppet
wildfly::config::module { 'org.postgresql':
  source       => 'file:///var/tmp/postgresql-9.3-1103-jdbc4.jar',
  dependencies => ['javax.api', 'javax.transaction.api']
}
```

### Datasources

Setup a driver and a datasource (for domain mode you need to set `target_profile` parameter):

```puppet
wildfly::datasources::driver { 'Driver postgresql':
  driver_name                     => 'postgresql',
  driver_module_name              => 'org.postgresql',
  driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource'
}
->
wildfly::datasources::datasource { 'DemoDS':
  config         => {
    'driver-name'    => 'postgresql',
    'connection-url' => 'jdbc:postgresql://localhost/postgres',
    'jndi-name'      => 'java:jboss/datasources/DemoDS',
    'user-name'      => 'postgres',
    'password'       => 'postgres'
  }
}
```

Alternatively, you can install a JDBC driver and module using deployment if your driver is JDBC4 compliant:

```puppet
wildfly::deployment { 'postgresql-9.3-1103-jdbc4.jar':
  source => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar'
}
->
wildfly::datasources::datasource { 'DemoDS':
  config         => {
    'driver-name'    => 'postgresql-9.3-1103-jdbc4.jar',
    'connection-url' => 'jdbc:postgresql://localhost/postgres',
    'jndi-name'      => 'java:jboss/datasources/DemoDS',
    'user-name'      => 'postgres',
    'password'       => 'postgres'
  }
}
```

A postgresql normal & XA datasource example

```puppet
wildfly::config::module { 'org.postgresql':
  source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar',
  dependencies => ['javax.api', 'javax.transaction.api'],
  require      => Class['wildfly'],
}
->
wildfly::datasources::driver { 'Driver postgresql':
  driver_name                     => 'postgresql',
  driver_module_name              => 'org.postgresql',
  driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource'
}
->
wildfly::datasources::datasource { 'petshop datasource':
  name           => 'petshopDS',
  config         => { 'driver-name'    => 'postgresql',
                      'connection-url' => 'jdbc:postgresql://10.10.10.10/petshop',
                      'jndi-name'      => 'java:jboss/datasources/petshopDS',
                      'user-name'      => 'petshop',
                      'password'       => 'password'
                    }
}
->
wildfly::datasources::xa_datasource { 'petshopDSXa':
  config          => {  'driver-name'              => 'postgresql',
                        'jndi-name'                => 'java:jboss/datasources/petshopDSXa',
                        'user-name'                => 'petshop',
                        'password'                 => 'password',
                        'xa-datasource-class'      => 'org.postgresql.xa.PGXADataSource',
                        'xa-datasource-properties' => {
                              'url' => {'value' => 'jdbc:postgresql://10.10.10.10/petshop'}
                        },
  }
}
```

Datasource configuration uses a hash with elements that match [JBoss-CLI datasource add elements name](https://docs.jboss.org/author/display/WFLY8/DataSource+configuration).

Configure Database Property, only works for normal datasources

```puppet
wildfly::datasources::db_property { 'DemoDbProperty':
 value    => 'demovalue',
 database => 'ExampleDS',
}
```

### HTTPS/SSL

#### Wildfly 8+

```puppet
wildfly::undertow::https { 'https':
  socket_binding    => 'https',
  keystore_path     => '/vagrant/identitystore.jks',
  keystore_password => 'changeit',
  key_alias         => 'demo',
  key_password      => 'changeit'
}
```

#### JBoss AS7/EAP 6

```puppet
wildfly::web::connector { 'https':
  scheme         => 'https',
  protocol       => 'HTTP/1.1',
  socket_binding => 'https',
  enable_lookups => false,
  secure         => true,
}
->
wildfly::web::ssl { 'ssl':
  connector            => 'https',
  protocol             => 'TLSv1,TLSv1.1,TLSv1.2',
  password             => 'changeit',
  key_alias            => 'demo',
  certificate_key_file => '/opt/identitykeystore.jks',
  cipher_suite         => 'TLS_RSA_WITH_AES_128_CBC_SHA,SSL_RSA_WITH_3DES_EDE_CBC_SHA',
}
```

#### Sample identity store configuration with `puppetlabs-java_ks`

```puppet
java_ks { 'demo:/opt/identitystore.jks':
  ensure      => latest,
  certificate => '/opt/demo.pub.crt',
  private_key => '/opt/demo.private.pem',
  path        => '/usr/java/jdk1.7.0_75/bin/',
  password    => 'changeit',
}
```

### Server Reload

Some configurations like SSL and modcluster requires a server reload (i.e. `server-state = reload-required`), and it can be achieved with the following snippet:

```puppet
## a_resource_that_requires_reload_when_changed {}
~>
widlfly::reload { 'Reload if necessary':
  retries => 2,
  wait    => 15,
}
```

Or

```puppet
wildfly::cli { 'Reload if necessary':
  command => ':reload',
  onlyif  => '(result == reload-required) of :read-attribute(name=server-state)'
}
```

Even [operation-headers](https://docs.jboss.org/author/display/WFLY9/Admin+Guide#AdminGuide-OperationHeaders) can do the trick in some cases:

```puppet
wildfly::resource { '/some=resource':
  operation_headers => {
    'allow-resource-service-restart' => true,
  }
}
```

### Messaging

> **NOTE** `full` profiles only

```puppet
wildfly::messaging::queue { 'DemoQueue':
  durable  => true,
  entries  => ['java:/jms/queue/DemoQueue'],
  selector => "MessageType = 'AddRequest'"
}

wildfly::messaging::topic { 'DemoTopic':
  entries => ['java:/jms/topic/DemoTopic']
}
```

Wildfly 10/EAP 7+ replaced HornetQ with ActiveMQ and queue/topic management is slightly different:

```puppet
wildfly::messaging::activemq::queue { 'DemoQueue':
  durable  => true,
  entries  => ['java:/jms/queue/DemoQueue'],
  selector => "MessageType = 'AddRequest'"
}

wildfly::messaging::activemq::topic { 'DemoTopic':
  entries => ['java:/jms/topic/DemoTopic']
}
```

### Logging

```puppet
wildfly::logging::category { 'DemoCategory':
  level               => 'DEBUG',
  use_parent_handlers => false,
  handlers            =>  ['DemoHandler']
}
```

### System Property

```puppet
wildfly::system::property { 'DemoSysProperty':
 value => 'demovalue'
}
```

### Modcluster

*`full` and `ha` profiles only

```puppet
wildfly::modcluster::config { "Modcluster mybalancer":
  balancer             => 'mybalancer',
  load_balancing_group => 'demolb',
  proxy_url            => '/',
  proxy_list           => '127.0.0.1:6666'
}
```

> **NOTE:** For apache/httpd mod_cluster configuration check [::apache::mod::cluster](https://github.com/puppetlabs/puppetlabs-apache#class-apachemodcluster)

## Limitations

Some of this module public defined types  (`widfly::datasources`, `wildfly::messaging`, `wildfly::undertow`, etc) are built for Wildfly 8.x and may not work with other versions. When there is a proven alternative for a different version, examples might be provided, otherwise you'll need to build your own abstraction using `wildfly_resource` or `wildfly::resource`.

One discussed approach would be to generate defined types based on Wildfly's configuration schemas (`$WILDFLY_HOME/docs/schema`).

JBoss EAP only works with RHEL-based OS's unless you provide custom scripts.

[This bug](https://bugzilla.redhat.com/show_bug.cgi?id=1224170) might also be a problem for `standalone-full-ha` users in JBoss EAP.

## Development

### Testing

This module uses puppet-lint, rubocop, rspec-puppet, beaker and travis-ci. We hope you use them before submitting your PR.

```shell
gem install bundler --no-rdoc --no-ri
bundle install --without development

bundle exec rake syntax
bundle exec rake lint
bundle exec rubocop
bundle exec rake spec
```

Acceptance tests (Beaker) can be executed using `./acceptance.sh`. There is a 4x4 matrix (Wildfly 8/8.2/9/10 X Centos 6/7 and Debian 7/8).

I suggest you create a `~/.vagrant.d/Vagrantfile` file and install `vagrant-cachier` plugin with the following content to speed up the execution:

```ruby
Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
    config.cache.enable :yum
    config.cache.enable :apt
    config.cache.enable :generic, 'wget' => { cache_dir: '/var/cache/wget' }
  end
end
```

It takes ~3 minutes per test.

### New features

JBoss/Wildfly configuration management is based on three custom types, `wildfly_resource`, `wildfly_cli` and `wildfly_deployment`. And you can do virtually any configuration that is possible through JBoss-CLI or XML configuration using them.

So, before build your awesome definition to manage a new resource or introduce a new configuration in an existing resource, check `wildfly::*` (`wildfly::deployment`, `wildfly::datasources::*`, `wildfly::undertow::*`, `wildfly::messaging::*`) for guidance.

If you can't figure out how to achieve your configuration, feel free to open an issue.

## Author/Contributors

- Edwin Biemond (biemond at gmail dot com)
- Jairo Junior (junior.jairo1 at gmail dot com)
- [More](https://github.com/biemond/biemond-wildfly/graphs/contributors)
