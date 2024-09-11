#wildfly
[![Build Status](https://travis-ci.org/biemond/biemond-wildfly.svg?branch=master)](https://travis-ci.org/biemond/biemond-wildfly)  [![Coverage Status](https://coveralls.io/repos/biemond/biemond-wildfly/badge.svg?branch=master&service=github)](https://coveralls.io/github/biemond/biemond-wildfly?branch=master)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wildfly](#setup)
    * [What wildfly affects](#what-wildfly-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with wildfly](#beginning-with-wildfly)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

[![Build Status](https://travis-ci.org/biemond/biemond-wildfly.png)](https://travis-ci.org/biemond/biemond-wildfly)

created by Edwin Biemond email biemond at gmail dot com
[biemond.blogspot.com](http://biemond.blogspot.com)
[Github homepage](https://github.com/biemond/biemond-wildfly)

Install, configures and manages Wildfly.

Should work on every Redhat or Debian family member, tested it with Wildfly 9.0, 8.2, 8.1 & 8.0

Can also work with JBoss EAP ( tested on 6.1/6.2/6.3), it may change in the future and probably is not supported on Debian

    # hiera example
    wildfly::service_name: jboss-as
    wildfly::conf_file: /etc/jboss-as/jboss-as.conf
    wildfly::service_file: jboss-as-standalone.sh
    wildfly::install_source: http://mywebserver/jboss-eap-6.1.tar.gz


[Vagrant Fedora 21, Puppet 4.2.1 example](https://github.com/biemond/vagrant-fedora20-puppet) with Wildfly 8.2 and Apache AJP, Postgress db.

[Vagrant CentOS HA example](https://github.com/jairojunior/wildfly-ha-vagrant-puppet) with two nodes and a load balancer (Apache + modcluster).

[Vagrant CentOS Domain Mode](https://github.com/jairojunior/wildfly-domain-vagrant-puppet) with two nodes (Domain master and slave).

[MCollective JBoss Agent Plugin](https://github.com/jairojunior/mcollective-jboss-agent) might be useful if you want to make consistent large scale changes.

##Module Description

The wildfly module can install, configure and manage (using its HTTP API) Wildfly (8/9) and JBoss AS7/EAP6 (with limitations).

##Setup

###What wildfly affects

* Creates a wildfly service and manages its installation (in an unobtrusive way using Wildfly HTTP API meaning that there are no templates for its standalone/domain configurations file)

* Installs requisite libaio and wget packages

###Setup Requirements

This module requires a JVM ( should already be there ).

Acceptance tests works with **puppetlabs/java** in both CentOS and Debian.

###Beginning with wildlfy

## Module defaults
- version           9.0.2
- install_source    http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz
- java_home         /usr/java/jdk1.7.0_75/ (default dir for oracle official rpm)
- manage_user       true
- group             wildfly
- user              wildfly
- dirname           /opt/wildfly
- package_ensure    present
- service_ensure    true
- service_enable    true
- java_home         /usr/java/jdk1.7.0_75/
- mode              standalone
- config            standalone.xml
- domain_config     domain.xml
- host_config       host.xml
- console_log       /var/log/wildfly/console.log
- mgmt_bind         0.0.0.0
- mgmt_http_port    9990
- mgmt_https_port   9993
- public_bind       0.0.0.0
- public_http_port  8080
- public_https_port 8443
- ajp_port          8009
- java_xmx          512m
- java_xms          128m
- java_maxpermsize  256m
- users_mgmt        user 'wildfly' with wildfly as password
- install_cache_dir /var/cache/wget

##Usage


    class { 'wildfly': }

or for wildfly 9.0.2

    class { 'wildfly':
      version        => '9.0.2',
      install_source => 'http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or for wildfly 9.0.0

    class { 'wildfly':
      version        => '9.0.0',
      install_source => 'http://download.jboss.org/wildfly/9.0.0.Final/wildfly-9.0.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or for wildfly 8.2.0

    class { 'wildfly':
      version        => '8.2.0',
      install_source => 'http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or for wildfly 8.1.0

    class { 'wildfly':
      version        => '8.1.0',
      install_source => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or for wildfly 8.0.0

    class { 'wildfly':
      version        => '8.0.0',
      install_source => 'http://download.jboss.org/wildfly/8.0.0.Final/wildfly-8.0.0.Final.tar.gz',
      java_home      => '/opt/jdk-8',
    }

or you can override a paramater

    class { 'wildfly':
      version           => '8.1.0',
      install_source    => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
      java_home         => '/opt/jdk-8',
      group             => 'wildfly',
      user              => 'wildfly',
      dirname           => '/opt/wildfly',
      mode              => 'standalone',
      config            => 'standalone-full.xml',
      java_xmx          => '512m',
      java_xms          => '256m',
      java_maxpermsize  => '256m',
      mgmt_http_port    => '9990',
      mgmt_https_port   => '9993',
      public_http_port  => '8080',
      public_https_port => '8443',
      ajp_port          => '8009',
      users_mgmt        => { 'wildfly' => { password => 'wildfly'}},
    }

or with java_opts instead of java_xmx, java_xms, java_maxpermsize

    class { 'wildfly':
      version           => '8.1.0',
      install_source    => 'http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz',
      java_home         => '/opt/jdk-8',
      group             => 'wildfly',
      user              => 'wildfly',
      dirname           => '/opt/wildfly',
      mode              => 'standalone',
      config            => 'standalone-full.xml',
      java_opts         => '-Xms64m -Xmx512m -XX:MaxPermSize=256m',
      mgmt_http_port    => '9990',
      mgmt_https_port   => '9993',
      public_http_port  => '8080',
      public_https_port => '8443',
      ajp_port          => '8009',
      users_mgmt        => { 'wildfly' => { password => 'wildfly'}},
    }

## Domain Mode

### Domain Master

    class { 'wildfly':
      mode        => 'domain',
      host_config => 'host-master.xml'
    }

    wildfly::config::mgmt_user { 'slave1':
      password => 'wildfly',
    }

### Domain Slave

    class { 'wildfly':
        mode        => 'domain',
        host_config => 'host-slave.xml',
        domain_slave => {
          host_name => 'slave1',
          secret    => 'd2lsZGZseQ==', #base64(password)
          domain_master_address => 'DomainBindAddress',
        }
    }

## Deployment

**From a source:**

Source supports: http://, ftp://, puppet://, file:

    wildfly::deployment { 'hawtio.war':
     source   => 'http://central.maven.org/maven2/io/hawt/hawtio-web/1.4.48/hawtio-web-1.4.48.war',
    }
    
    wildfly::deployment { 'hawtio.war':
     source   => 'puppet:///modules/profile/wildfly/hawtio-web-1.4.48.war',
    }
    
    wildfly::deployment { 'hawtio.war':
     source   => 'file:/var/tmp/hawtio-web-1.4.48.war',
    }

**To a server-group (domain mode):**

    wildfly::deployment { 'hawtio.war':
     source       => 'http://central.maven.org/maven2/io/hawt/hawtio-web/1.4.48/hawtio-web-1.4.48.war',
     server_group => 'main-server-group',
    }

**Deploy from nexus: **

This feature was removed to avoid 'archive' name collision, but you can still use archive::nexus to download an artifact and use as an input for wildfly::deploy

## User management

You can add App and Management users (requires server restart).

    wildfly::config::mgmt_user { 'mgmtuser':
      password => 'mgmtuser'
    }

    wildfly::config::app_user { 'appuser':
      password => 'appuser'
    }

And associate groups or roles to them (requires server restart)

    wildfly::config::user_groups { 'mgmtuser':
      groups   => 'admin,mygroup'
    }

    wildfly::config::user_roles { 'appuser':
      roles    => 'guest,ejb'
    }

## Module installation

Install a JAR module from a remote file system, puppet file server or local file system.

    wildfly::config::module { 'org.postgresql':
      source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar',
      dependencies => ['javax.api', 'javax.transaction.api']
    }
    
    wildfly::config::module { 'org.postgresql':
      source       => 'puppet:///modules/profile/wildfly/postgresql-9.3-1103-jdbc4.jar',
      dependencies => ['javax.api', 'javax.transaction.api']
    }
    
    wildfly::config::module { 'org.postgresql':
      source       => 'file:/var/tmp/postgresql-9.3-1103-jdbc4.jar',
      dependencies => ['javax.api', 'javax.transaction.api']
    }

## Datasources

Setup a driver and a datasource (for domain mode you need to set target_profile parameter):

    wildfly::datasources::driver { 'Driver postgresql':
      driver_name                     => 'postgresql',
      driver_module_name              => 'org.postgresql',
      driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource'
    }
    ->
    wildfly::datasources::datasource { 'DemoDS':
      config         => {
        'driver-name' => 'postgresql',
        'connection-url' => 'jdbc:postgresql://localhost/postgres',
        'jndi-name' => 'java:jboss/datasources/DemoDS',
        'user-name' => 'postgres',
        'password' => 'postgres'
      }
    }

Alternatively, you can install a JDBC driver and module using deploy if your driver is JDBC4 compliant:

    wildfly::deployment { 'postgresql-9.3-1103-jdbc4.jar':
      source => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar'
    }
    ->
    wildfly::datasources::datasource { 'DemoDS':
      config         => {
        'driver-name' => 'postgresql-9.3-1103-jdbc4.jar',
        'connection-url' => 'jdbc:postgresql://localhost/postgres',
        'jndi-name' => 'java:jboss/datasources/DemoDS',
        'user-name' => 'postgres',
        'password' => 'postgres'
      }
    }

A postgresql normal & XA datasource example

    wildfly::config::module { 'org.postgresql':
      source       => 'http://central.maven.org/maven2/org/postgresql/postgresql/9.3-1103-jdbc4/postgresql-9.3-1103-jdbc4.jar',
      dependencies => ['javax.api', 'javax.transaction.api'],
      require      => Class['wildfly'],
    } ->

    wildfly::datasources::driver { 'Driver postgresql':
      driver_name                     => 'postgresql',
      driver_module_name              => 'org.postgresql',
      driver_xa_datasource_class_name => 'org.postgresql.xa.PGXADataSource'
    } ->

    wildfly::datasources::datasource { 'petshop datasource':
      name           => 'petshopDS',
      config         => { 'driver-name'    => 'postgresql',
                          'connection-url' => 'jdbc:postgresql://10.10.10.10/petshop',
                          'jndi-name'      => 'java:jboss/datasources/petshopDS',
                          'user-name'      => 'petshop',
                          'password'       => 'password'
                        }
    } ->

    wildfly::datasources::xa_datasource { 'petshop xa datasource':
      name            => 'petshopDSXa',
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


Configure Database Property, only works for normal datasources

    wildfly::datasources::db_property { 'DemoDbProperty':
     value => 'demovalue',
     database => 'ExampleDS',
    }

Datasource configuration uses a hash with elements that match JBoss-CLI datasource add elements name. More info here: https://docs.jboss.org/author/display/WFLY8/DataSource+configuration

## HTTPS/SSL

    wildfly::undertow::https { 'https':
      socket_binding    => 'https',
      keystore_path     => '/vagrant/identitystore.jks',
      keystore_password => 'changeit',
      key_alias         => 'demo',
      key_password      => 'changeit'
    }

**Identity Store sample Configuration:**

    java_ks { 'demo:/opt/identitystore.jks':
      ensure      => latest,
      certificate => '/opt/demo.pub.crt',
      private_key => '/opt/demo.private.pem',
      path        => '/usr/java/jdk1.7.0_75/bin/',
      password    => 'changeit',
    }

## Server Reload

Some configurations like SSL and modcluster requires a server reload, it can be achieved with the following snippet:

    wildfly::util::exec_cli { 'Reload if necessary':
      command => 'reload',
      onlyif  => '(result == reload-required) of read-attribute server-state'
    }

## Messaging (Only for full profiles)
for domain mode you need to set target_profile parameter

    wildfly::messaging::queue { 'DemoQueue':
      durable => true,
      entries => ['java:/jms/queue/DemoQueue'],
      selector => "MessageType = 'AddRequest'"
    }

    wildfly::messaging::topic { 'DemoTopic':
      entries => ['java:/jms/topic/DemoTopic']
    }

## Logging (Only for full profiles)
for domain mode you need to set target_profile parameter

    wildfly::logging::category { 'DemoCategory':
      level => 'DEBUG',
      use_parent_handlers => false,
      handlers =>  ['DemoHandler']
    }

## System Property (Only for full profiles)
for domain mode you need to set target_profile parameter

    wildfly::system::property { 'DemoSysProperty':
     value    => 'demovalue'
    }

## Modcluster (Only for HA profiles)
for domain mode you need to set target_profile parameter

    wildfly::modcluster::config { "Modcluster mybalancer":
      balancer => 'mybalancer',
      load_balancing_group => 'demolb',
      proxy_url => '/',
      proxy_list => '127.0.0.1:6666'
    }

##Reference

###Classes

####Public classes

* [wildfly]

####Private classes

* [wildfly::install]
* [wildfly::prepare]
* [wildfly::setup]
* [wildfly::service]

###Resources

* [wildfly::config::app_user]
* [wildfly::config::mgmt_user]
* [wildfly::config::user_groups]
* [wildfly::config::user_roles]
* [wildfly::config::module]
* [wildfly::util::resource]
* [wildfly::util::exec_cli]
* [wildfly::deployment]

Check types tab for more info about custom types/providers.

##Limitations

wildfly definitions (datasources, messaging, undertow, etc) which are intended to enforce good practices, syntax sugar or serve as examples are built for Wildfly 8.x and may not work with other versions. (Check Issue #27 for more details)

JBoss AS7/EAP 6 support is limited due to the above limitation and to the fact that service scripts are a little different. (Don't support debian and have only one script for both standalone/domain modes)
This bug might also be a problem for standalone-full-ha users in JBoss EAP: https://bugzilla.redhat.com/show_bug.cgi?id=1224170

##Development

This module uses puppet-lint, rubocop, rspec, beaker and travis-ci. Try to use them before submit your PR.

    gem install bundler --no-rdoc --no-ri
    bundle install --without development
    gem update --system 2.1.11

    bundle exec rake syntax
    bundle exec rake lint
    bundle exec rubocop

    bundle exec rake spec
    bundle exec rspec spec/acceptance # default centos-66-x64
    BEAKER_set=centos-70-x64 bundle exec rspec spec/acceptance
    BEAKER_set=debian-78-x64 bundle exec rspec spec/acceptance

JBoss/Wildfly management is based on three custom types and you can do virtually any JBoss/Wildfly configuration using them. So, before build your awesome definition to manage a resource (anything in configurations XML's) or deploy an artifact from my_internal_protocol://, check wildfly::deploy or wildfly::datasources namespace for guidance.


*Examples*:

    wildfly_cli { 'Enable ExampleDS'
      command => '/subsystem=datasources/data-source=ExampleDS:enable',
      unless  => '(result == true) of /subsystem=datasources/data-source=ExampleDS:read-attribute(name=enabled)'
    }

    wildfly_resource { '/subsystem=datasources/data-source=ExampleDS':
      state => {
               'driver-name' => 'postgresql',
               'connection-url' => 'jdbc:postgresql://localhost/example',
               'jndi-name' => 'java:jboss/datasources/ExampleDS',
               'user-name' => 'postgres',
               'password' => 'postgres'
               }
    }

    wildfly_deployment { 'sample.war':
      source => 'file:/vagrant/sample.war'
    }

They all require a management username, password, host and port params, as it uses Wildfly HTTP API. *Host defaults to 127.0.0.1 and port to 9990*

##Author/Contributors

- Edwin Biemond (biemond at gmail dot com)
- Jairo Junior (junior.jairo1 at gmail dot com)

More: https://github.com/biemond/biemond-wildfly/graphs/contributors
