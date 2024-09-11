puppet-sentry
======

[Sentry](https://www.getsentry.com) is "a modern error logging and aggregation platform."  This module installs the [on-premise](https://docs.getsentry.com/on-premise/) open source version of Sentry. A Sentry administrative user, default Organization and default Team will be created.

**NOTE** version 3 of this module only supports Sentry versions 8.4.0 and above.

## Dependencies
This module supports only Red Hat Enterprise Linux 7 and its derivatives.

Puppet 4 or future parser are **required**.

The following modules are required:
* [apache](https://forge.puppetlabs.com/puppetlabs/apache)
* [logrotate](https://forge.puppet.com/yo61/logrotate)
* [python](https://forge.puppetlabs.com/stankevich/python)
* [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

This module configures Sentry to use a PostgreSQL database, memcached, and Redis. The installation and configuration of these services are not managed by this module.  Please see the [Modules we use](#modules-we-use) to satify those dependencies below.

If an LDAP host is defined for the Sentry configuration, the [getsentry-ldap-auth](https://github.com/banno/getsentry-ldap-auth) plugin is activated.

# Usage
To install the latest version of Sentry with all default values:
```
class { 'sentry': }
```
The default configuration assumes all of the dependencies are running on localhost, which is likely only useful for a development scenario.  This will also use the Red Hat default `snakeoil` SSL certificate for HTTPS.

A more realistic use case following the roles and profiles pattern:
* **role/manifests/sentry.pp**
```
class role::sentry {

  include profile::sentry
  # Sentry servers run memcached locally
  include profile::memcached

}
```

* **profile/manifests/sentry.pp**
```
class profile::sentry {

  include profile::postgresql_client
  include ::sentry

  Class['profile::postgresql_client'] ->
    Class['::sentry']

}
```

* **hieradata/hosts/sentry.example.com.yaml**
```
---
classes:
  - role::sentry
sentry::admin_email: 'admin@example.com'
sentry::admin_password: <redacted>
sentry::db_host: 'postgresql.example.com'
sentry::db_name: 'sentry'
sentry::db_user: 'sentry'
sentry::db_password: 'sentry_db_password'
sentry::extensions:
  sentry-github: https://github.com/getsentry/sentry-github/archive/master.zip
  sentry-hipchat: https://github.com/getsentry/sentry-hipchat-ac/archive/master.zip
sentry::ldap_auth_version: '2.0'
sentry::ldap_domain: 'example'
sentry::ldap_base_ou: 'dc=example,dc=com'
sentry::ldap_group_base: 'OU=Sentry Users,OU=Admin Users,DC=example,DC=com'
sentry::ldap_group_dn: 'CN=Sentry Group,OU=Admin Groups,DC=example,DC=com'
sentry::ldap_host: 'ldap.example.com'
sentry::ldap_user: 'sentry_ldap@example.com'
sentry::ldap_password: 'ldap_bind_password'
sentry::organization: 'Awesome Organization'
sentry::path: '/var/lib/sentry'
sentry::redis_host: 'redis.example.com'
sentry::secret_key: <some secret key>
sentry::smtp_host: 'smtp.example.com'
sentry::ssl_cert: '/etc/ssl/sentry.example.com.pem'
sentry::ssl_key: '/etc/ssl/sentry.example.com.key'
sentry::version: '8.4.1'
sentry::sentry_vhost: 'sentry.example.com'
```

## Classes
### sentry
This is the main class that handles the installation of Sentry, configures an Apache virtual host running `mod_wsgi`, and manages the Sentry background worker processes.

Class parameters:
* **admin_email**: the admin user's email address; also used as login name (root@localhost)
* **admin_password**: the admin user's password (admin)
* **custom_config**: array of custom configs to put into `config.yml`
* **custom_settings**: array of custom settings to put into `sentry.conf.py`
* **db_host**: the PostgreSQL database host (localhost)
* **db_name**: the name of the PostgreSQL database to use (sentry)
* **db_password**: the DB user's password (sentry)
* **db_port**: the PostgreSQL database port (5432)
* **db_user**: the user account with which to connect to the database (sentry)
* **extensions**: hash of Sentry extensions, with source URLs, to install
* **group**: UNIX group to own virtualenv, and run background workers (sentry)
* **ldap_* **: LDAP connection details used for creating local user accounts from AD users
* **memcached_host**: name or IP of memcached server (localhost)
* **memcached_port**: port to use for memcached (11211)
* **metrics_enable**: whether to enable the sentry metrics (false)
* **metrics_backend**: which metrics backend to enable (statsd)
* **organization**: default organization to create, and in which to create new users
* **path**: path into which to install Sentry, and create the virtualenv (/srv/sentry)
* **redis_host**: name or IP of Redis server (localhost)
* **redis_port**: port to use for Redis (6379)
* **secret_key**: string used to hash cookies (fqdn_rand_string(40))
* **smtp_host**: name or IP of SMTP server (localhost)
* **ssl_* **: Apache SSL controls.  The `ssl_cert` and `ssl_key` parameters reference files on the Sentry server. Your Sentry profile class or other higher level class should manage the installation of these file resources.
* **statsd_host**: hostname of statsd server (localhost)
* **statsd_port**: port for statsd server (8125)
* **url**: source URL form which to install Sentry (false, use [PyPI](https://pypi.python.org/pypi/sentry/))
* **user**: UNIX user to own virtualenv, and run background workers (sentry)
* **version**: the Sentry version to install
* **vhost**: the URL at which users will access the Sentry GUI
* **wsgi_* **: mod_wsgi controls
* **worker_concurrency**: number of concurrent workers

### sentry::setup
This private class ensures that all of the Sentry prerequisites are installed.  It will create the direcotry into which Sentry will be installed, create the Sentry user and group, create a Python virtual environment, and install the RPM and `pip` dependencies.

### sentry::config
This private class installs the `sentry.conf.py` and `config.yml` configuration files used by Sentry.

### sentry::install
This private class installs Sentry itself. The [getsentry-ldap-auth](https://github.com/banno/getsentry-ldap-auth) plugin is installed, but will not be used unless an LDAP host is defined in `sentry::init`.

Upon first installation, the initial database migrations will be performed, a Sentry admin user will be created, and a basic configuration will be bootstrapped.

This class will also handle upgrades to Sentry, when the `version` parameter defined here is different from the version installed.  The upgrade process is as automated as possible, but manual intervention may be required depending on your specific configuration.

### sentry::service
This private class manages the Sentry background workers via `systemd`.

### sentry::wsgi
This private class installs an Apache virtual host with `mod_wsgi`. HTTPS support is optional.

## Defines
### sentry::server::collect
This defined type collects all of the exported `sentry::source::project` resources and instantiates them on the Sentry server.

This allows for applications to create Sentry projects and DSNs automatically.

### sentry::source::export
This defined type exports a `sentry::source::project` resource.

Type parameters:
* **organization**: The Sentry organization to use.  Required.  No default.
* **team**: The Sentry team to use.  Required.  No default.
* **language**: the Sentry language to use
* **env**: the tag to apply

The `title` of this resource will be used to create a `sentry::source::project` resource of the form `${name}-${::hostname}`.  This allows multiple application servers to export the same application to Sentry, but ensures that only one Sentry project is created.

`organization` and `team` are required parameters.  The organization must exist, however, if the team does not exist it will be created.  We don't have a need for dynamically creating new organization which is why its not supported at this time.

This defined type looks for a custom fact named `${name}_lang`.  If found, the value of this fact will be used for this project's language, regardless of any `$language` class parameter defined.  This custom fact **is not** included in this module.  An example is available in the `examples` directory.

### sentry::source::project
This defined type defines a Sentry project.

For each `sentry::source::project`, a Sentry project will be created in the default Organization and Team.

Type parameters:
* **organization**: The Sentry organization to use.  Required.  No default.
* **team**: The Sentry team to use.  Required.  No default.
* **project**: the name of the project
* **platform**: the language used by this project
* **path**: the virtualenv path to use for Sentry

## Automation
One of the goals of this module was hands-off creation of new Sentry projects for applications. Here's how **we** accomplish this task. Your mileage may vary.

Our application servers are classified with our `profile::appserver` class.  This class includes a custom fact that enumerates all of the applications deployed to the server.  We take this list of deployed applications and pass it as an array to `sentry::source::export` to create one exported resource for each application:
```
    sentry::source::export { $::deployed_apps:
      organization => hiera(sentry::organization)
      team         => hiera(sentry::team)
      env          => $::application_environment
    }
```
We tag the exported resources with another custom fact for the application environment (`production`, `testing`, etc).

The `sentry::source::export` defined type simply exports a `sentry::source::project` defined type, with the important caveat that the application server's hostname is included in the exported resource title.  This ensures that each exported resource is unique.

The main `sentry` class includes `sentry::server::collect`, which collects all of the exported `sentry::source::project` resources from our application servers, based on env.  We have separate Sentry instances for production, testing, etc, so each Sentry server will only collect the `sentry::source::project`s that are appropriate for its environment.

The `sentry::source::project` is instantiated based on the `project` parameter.  Remember, the resource **title** is unique, by hostname, but the parameters need not be.  The Sentry server executes a simple Python script to create the project.  This script creates a file named after the project, containing the Sentry DSN for that project.

These DSN files can optionally be exposed via Apache in `sentry::wsgi`.  This allows an application server to automatically look up the DSNs for each of its applications via a custom fact.  For an example of such a custom fact, see the **examples** directory.

# Modules we use
* [Postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)
* [Redis](https://github.com/covermymeds/puppet-redis)
* [Memcached](https://github.com/saz/puppet-memcached)

# Contributing
Fork it and submit pull requests!

# Copyright
Copyright 2015 [CoverMyMeds](https://www.covermymeds.com/) and released under the terms of the [MIT License](http://opensource.org/licenses/MIT).
