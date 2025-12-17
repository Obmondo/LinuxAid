# wildfly

[![License](https://img.shields.io/github/license/voxpupuli/puppet-wildfly.svg)](https://github.com/voxpupuli/puppet-wildfly/blob/master/LICENSE)
[![puppetmodule.info docs](https://www.puppetmodule.info/images/badge.png)](https://www.puppetmodule.info/m/puppet-wildfly)
[![CI](https://github.com/voxpupuli/puppet-wildfly/actions/workflows/ci.yml/badge.svg)](https://github.com/voxpupuli/puppet-wildfly/actions/workflows/ci.yml)
[![Donated by biemond](https://img.shields.io/badge/donated%20by-biemond-fb7047.svg)](#transfer-notice)

[![Puppet Forge Endorsement](https://img.shields.io/puppetforge/e/puppet/wildfly.svg)](https://forge.puppetlabs.com/puppet/wildfly)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/puppet/wildfly.svg)](https://forge.puppetlabs.com/puppet/wildfly)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/puppet/wildfly.svg)](https://forge.puppetlabs.com/puppet/wildfly)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/puppet/wildfly.svg)](https://forge.puppetlabs.com/puppet/wildfly)

## Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wildfly](#setup)
    * [What wildfly affects](#what-wildfly-affects)
    * [Setup requirements](#setup-requirements)
4. [Upgrade](#upgrade)
    * [to 1.2.0](#to-120)
    * [to 2.0.0](#to-200)
    * [to 2.1.0](#to-210)
5. [Usage - Configuration options and additional functionality](#usage)
    * [Wildfly 25.0.0](#wildfly-2500)
    * [Wildfly 23.0.2](#wildfly-2302)
    * [Wildfly 10.1.0](#wildfly-1010)
    * [Wildfly 9.0.2](#wildfly-902)
    * [Wildfly 8.2.1](#wildfly-821)
    * [JBoss EAP 6.x (with hiera)](#jboss-eap-6x-with-hiera)
    * [JBoss EAP 7.0](#jboss-eap-70)
    * [Keycloak](#keycloak)
    * [apiman](#apiman)
    * [Infinispan Server](#infinispan-server)
    * [Wildfly's Configuration Management](#wildflys-configuration-management)
    * [Patch management](#patch-management)
    * [Unmanaged installation](#unmanaged-installation)
    * [Domain Mode](#domain-mode)
    * [Java Virtual Machine options](#java-virtual-machine-options)
    * [Deployment](#deployment)
    * [User management](#user-management)
    * [Module installation](#module-installation)
    * [Datasources](#datasources)
    * [HTTPS/SSL](#httpsssl)
    * [Management over HTTPS/SSL](#mgmtssl)
    * [Server reload](#server-reload)
    * [Messaging](#messaging)
    * [Logging](#logging)
    * [Modcluster](#modcluster)
    * [JGroups](#jgroups)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Documentation](#documentation)

## Overview

Originally created by Edwin Biemond email biemond at gmail dot com
[biemond.blogspot.com](http://biemond.blogspot.com)

Install, configures and manages Wildfly.

Should work on every Redhat or Debian family member, tested with Wildfly 10.1, 10.0, 9.0, 8.2, 8.1 & 8.0 and with JBoss EAP (tested on 6.1/6.2/6.3/6.4 and 7.0). Some defines may work only in certain versions.

[Vagrant Fedora 21, Puppet 4.2.1 example](https://github.com/biemond/vagrant-fedora20-puppet) with Wildfly 8.2, Apache AJP and PostgreSQL.

[Vagrant CentOS Standalone HA + Gossip Router example](https://github.com/jairojunior/wildfly-ha-tcpgossip-vagrant-puppet) with two nodes, a gossip router and a load balancer (httpd + mod_cluster).

[Vagrant CentOS 7.2 Domain Mode](https://github.com/jairojunior/wildfly-domain-vagrant-puppet) with two nodes (Domain master and slave) and a load balancer.

## Module Description

The wildfly module can install, configure and manage - through its HTTP Management API - Wildfly (8/9/10+) and JBoss EAP (6.1+/7.0+).

## Setup

### What wildfly affects

* Manage Wildfly user, group and directory.

* Creates a wildfly service using bundled scripts and manages its installation and resources (using [Management API](https://docs.jboss.org/author/display/WFLY10/Management+API+reference))

* Installs requisite libaio and wget packages

### Setup Requirements

This module requires a JVM ( should already be there ). Just need to be extracted somewhere, no need to update-alternatives, set PATH or anything else, but it also works if you choose to do so.

Three gems are bundled with this module: `treetop` (parsing JBoss-CLI commands), `polyglot` (treetop's requirement) and `net-http-digest_auth` (Management API authentication).

Acceptance tests works with **puppetlabs/java** in both CentOS and Debian.

This module requires `puppetlabs-stdlib`.

It should work on every modern Linux. TO see a list of all tested OSes, please check the metadata.json.

## Upgrade

## to 1.2.0

### wildfly class

The main changes in `wildfly` class are below:

```puppet
class { 'wildfly':
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

`distribution` was introduced to provide out of the box support for JBoss EAP and `properties` to replace fine-grained parameters for address/port binding like `public_bind`, `mgmt_bind` and `public_http_port`. (*Reason*: It's easier - and more reliable - to manage a properties file than Wildfly's XML through augeas)

`users_mgmt` was replaced by `mgmt_user`, and additional users should be managed by `wildfly::config::mgtm_user` defined type. The hash format and default value also changed.

### New dependency

`jethrocarr/initfact` module.

### Defined types

All resources from `wildfly::util` were moved to `wildfly`, hence you need to search and replace them, I suggest you execute these commands in your environment:

`find . -name '*.pp' -type f -exec sed -i 's/wildfly::util::exec_cli/wildfly::cli/g' {} +`

`find . -name '*.pp' -type f -exec sed -i 's/wildfly::util/wildfly/g' {} +`

## to 2.0.0

This version requires Puppet 4.4+ and heavily uses Puppet 4 new features: data types, epp templates and Ruby 2.1+, but there is no breaking change per se. Meaning that if you're using 1.x version with Puppet 4 you should be able to migrate without any problems.

If you're still using Puppet 3.x with Ruby 1.8.7+ check version 1.2.x (**unsupported**).

## to 2.1.0

This version will no longer stringify values for `wildfly_resource`'s state or sort arrays values. In other words, you'll have to declare attributes using a type that matches Wildfly's Management Model type and in the same order returned by the API (in case of an array/LIST).

## Usage

```puppet
class { 'wildfly': }
```

### Wildfly 25.0.0

```puppet
class { 'wildfly':
  version           => '25.0.0',
  install_source    => 'https://github.com/wildfly/wildfly/releases/download/25.0.0.Final/wildfly-25.0.0.Final.tar.gz',
  install_cache_dir => '/tmp',
  java_home         => '/usr/lib/jvm/java-17-openjdk-amd64',
}
```

### Wildfly 23.0.2

```puppet
class { 'wildfly':
  version           => '23.0.2',
  install_source    => 'https://download.jboss.org/wildfly/23.0.2.Final/wildfly-23.0.2.Final.tar.gz',
  install_cache_dir => '/tmp',
  java_home         => '/usr/lib/jvm/java-17-openjdk-amd64',
}
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
include wildfly
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

Some Keycloak configuration can be managed in the same way as a regular Wildfly/Jboss configuration:

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

Currently there aren't no prebuilt packages, but [download page](http://www.apiman.io/latest/download.html) provides instruction to build it for Wildfly 10, 9 and EAP 7.


#### Example

```sh
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
class { 'wildfly':
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
class { 'wildfly':
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

>**NOTE:** Host Controller name has to match a mgmt user name in Domain Controller, since, by default, HC uses it own name as the username for connecting with DC. You can always set a different one by overriding `remote_username` parameter.

#### Domain Management

Make sure you remove default resources (server-groups and server-config) if you're not going to use it.

Domain controller:

```puppet
wildfly::domain::server_group { ['main-server-group', 'other-server-group']:
  ensure => absent,
}
```

Host controller:

```puppet
wildfly::host::server_config { ['server-one', 'server-two']:
 ensure   => absent,
 hostname => $hostname,
 username => $username,
 password => $password,
 before   => Class['wildfly::setup'],
}
```

You can also use a `overlay_class` instead of use `before`.

Host controller:

```puppet
class { 'wildfly':
  # ...
  overlay_class => 'app::cleanup'
}

class app::cleanup {
  wildfly::host::server_config { ['server-one', 'server-two']:
   ensure   => absent,
   hostname => $hostname,
   username => $username,
   password => $password,
  }
}
```

`Username` and `password` are the credentials used to connect to domain controller and make the desired changes. In the first provision this resource will be applied with augeas and will not need that, but in the other these parameters will be required to guarantee that the server-configs no longer exists.

After that, start managing your own `server-groups` and `server-config` with `wildfly::domain::server-group` and `wildfly::host::server_config`:

Domain controller:

```puppet
wildfly::domain::server_group { 'app-server-group':
  profile              => 'full-ha',
  socket_binding_group => 'full-ha-sockets',
}
```

Host controller:

```puppet
wildfly::host::server_config { 'app':
  server_group       => 'app-server-group',
  hostname           => $hostname,
  username           => $username,
  password           => $password,
}
```

Please note that you'll need to enable external facts (`wildfly::external_facts`) since `wildfly::host::server_config` relies on `wildfly_is_running` fact to know if it should use augeas or connect to the domain controller to remove a server-config.

#### Custom Java options

Domain controller:

```puppet
class { 'wildfly':
  ...,
  java_opts                    => ['<java_opt_1>', '<java_opt_2>']
  process_controller_java_opts => ['<controller_opt_1>', '<controller_opt_2>']
}
```

Results in a `domain.conf` with:

```shell
if [ "x$JAVA_OPTS" = "x" ]; then
    JAVA_OPTS=...
    JAVA_OPTS="$JAVA_OPTS <java_opt_1> <java_opt_2>"
    ...
fi
...
if [ "x$PROCESS_CONTROLLER_JAVA_OPTS" = "x" ]; then
    PROCESS_CONTROLLER_JAVA_OPTS="$JAVA_OPTS <controller_opt_1>, <controller_opt_2>"
fi
```

Host controller:

```puppet
class { 'wildfly':
  ...,
  java_opts                 => ['<java_opt_1>', '<java_opt_2>']
  host_controller_java_opts => ['<managed_opt_1>', '<managed_opt_2>']
}
```

Results in a `domain.conf` with:

```shell
if [ "x$JAVA_OPTS" = "x" ]; then
    JAVA_OPTS=...
    JAVA_OPTS="$JAVA_OPTS <java_opt_1> <java_opt_2>"
    ...
fi
...
if [ "x$HOST_CONTROLLER_JAVA_OPTS" = "x" ]; then
    HOST_CONTROLLER_JAVA_OPTS="$JAVA_OPTS <managed_opt_1> <managed_opt_2>"
fi
```

### Java Virtual Machine options

To adjust [JVM heap memory settings](https://www.baeldung.com/jvm-parameters#explicit-heap-memory---xms-and-xmx-options), use `wildfly` class `java_xmx`, `java_xms` and/or `java_maxmetaspace_size` parameters:

```puppet
class { 'wildfly':
  # ...
  java_xms               => '<Minimum heap size>',
  java_xmx               => '<Maximum heap size>',
  java_maxmetaspace_size => '<Maximum Metaspace size>',
}
```

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

### Management over HTTPS/SSL

This feature is currently implemented for standalone mode only.  The default http management console and API can be changed to run over HTTPS/TLS.

#### Basic use with a self signed certificate
This will generate and use a basic self signed certificate for the Management interface.  Requires the puppetlabs/java_ks module:

```puppet
class { 'wildfly':
	secure_mgmt_api => true,
}
```

#### Providing your own certificate
The module will create the approprate keystores, truststores, and configuration if given paths to the private key and certificate.  Use your favorite method to ensure the key and certificate exist on the endpoint.  Requires the puppetlabs/java_ks module:

```puppet
class { 'wildfly':
	secure_mgmt_api => true,
	mgmt_ssl_key => '/etc/pki/tls/private/key.pem',
	mgmt_ssl_cert => '/etc/pki/tls/certs/cert.pem',
}
```

#### Unmanaged keystores
If preferred, the management API can be configured to use keystores/truststores managed outside this module.  These will need to exist before running the wildfly class.

Be aware of the following:
- The existing keystore needs to be readable by the wildfly user.
- Truststores need to exist in the home directories for the wildfly user and the root user.

```puppet
class { 'wildfly':
	secure_mgmt_api => true,
    mgmt_create_keystores => false,
    mgmt_keystore => '/etc/pki/keystores/wf_ks.jks',
	mgmt_keystore_pass => 'password',
	mgmt_keystore_alias => 'wfmgmt',
}
```

### Server Reload

Some configurations like SSL and modcluster requires a server reload (i.e. `server-state = reload-required`), and it can be achieved with the following snippet:

```puppet
## a_resource_that_requires_reload_when_changed {}
~>
wildfly::reload { 'Reload if necessary':
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

> **NOTE:** `full` profiles only

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

> **NOTE:**`full` and `ha` profiles only

```puppet
wildfly::modcluster::config { "Modcluster mybalancer":
  balancer             => 'mybalancer',
  load_balancing_group => 'demolb',
  proxy_url            => '/',
  proxy_list           => '127.0.0.1:6666'
}
```

> **NOTE:** For apache/httpd mod_cluster configuration check [::apache::mod::cluster](https://github.com/puppetlabs/puppetlabs-apache#class-apachemodcluster)

### JGroups

> **NOTE:** `ha` profiles only

```puppet
wildfly::jgroups::stack::tcpgossip { 'TCPGOSSIP':
  initial_hosts       => '172.28.128.1[12001]',
  num_initial_members => 2
}
```

```puppet
wildfly::jgroups::stack::tcpping { 'TCPPING':
  initial_hosts       => '172.28.128.10[7600],17228.128.20[7600]',
  num_initial_members => 2
}
```

## Limitations

Some of this module public defined types  (`widfly::datasources`, `wildfly::messaging`, `wildfly::undertow`, etc) were built for Wildfly 8.x and may not work with other versions. When there is a proven alternative for a different version, examples might be provided, otherwise you'll need to build your own abstraction using `wildfly_resource` or `wildfly::resource`.

One discussed approach would be to generate defined types based on Wildfly's configuration schemas (`$WILDFLY_HOME/docs/schema`) or DMR (See [Issue 174](https://github.com/voxpupuli/puppet-wildfly/issues/174)).

JBoss EAP only works with RHEL-based OS's unless you provide custom scripts.

[This bug](https://bugzilla.redhat.com/show_bug.cgi?id=1224170) might also be a problem for `standalone-full-ha` users of JBoss EAP < 7.

## Development

### Testing

This module uses puppet-lint, rubocop, rspec-puppet, beaker and travis-ci. We hope you use them before submitting your PR.

Hopefully, you'll need rvm to get the correct gems installed (and not messing with your computer's Ruby setup). Pls follow [official installation instructions](https://rvm.io/rvm/install), plus:

```Shell
sudo usermod -aG rvm $USER
echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
```

Reboot for all changes to take effect, then install Ruby 2.7:

```shell
# Didn't work for installing Ruby 2.7, but looks wise:
rvm autolibs enable
# Ruby 2.7 dependency
rvm pkg install openssl
Beware, 'rvm pkg ...' is deprecated, read about the new autolibs feature: 'rvm help autolibs'.
# Inside this project's root directory:
rvm install ruby-2.7 --with-openssl-dir=/usr/share/rvm/usr
rvm use ruby-2.7
# Validate
ruby -v
ruby 2.7.x (20XX-YY-ZZ revision &lt;Hash&gt;) [x86_64-linux]
```

```shell
gem install bundler --no-document
bundle config set --local without 'development'
bundle install

bundle exec rake syntax
bundle exec rake lint
bundle exec rubocop
bundle exec rake spec
```

Acceptance tests (Beaker) can be executed using `./acceptance.sh`. There is a 4x6 matrix (Wildfly 8/8.2/9/10 X Centos 6/7, Debian 7/8, Ubuntu 12.04/14.04).

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
- [More](https://github.com/voxpupuli/puppet-wildfly/graphs/contributors)

## Documentation

see [REFERENCE.md](REFERENCE.md)

Transfer Notice
---------------

This project was originally authored by [biemond](http://github.com/biemond).
The maintainer preferred that Vox Pupuli take ownership of the project for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of biemond-wildlfy.
