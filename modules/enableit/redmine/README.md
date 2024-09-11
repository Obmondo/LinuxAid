johanek-redmine
---------------

[![Build Status](https://travis-ci.org/johanek/johanek-redmine.png?branch=master)](http://travis-ci.org/johanek/johanek-redmine)

This module installs redmine, running behind apache and passenger, and backed by mysql, mariadb or postgresql

Tested on CentOS 6.5, debian wheezy and Ubuntu 14.04 (Trusty)

Requirements
------------

Required modules:
* puppetlabs-mysql 2.0 or later
* puppetlabs-stdlib
* puppetlabs-apache
* puppetlabs-concat
* puppetlabs-postgresql 3.3.0 or later

Optional modules:
* puppetlabs-vcsrepo if you want to download redmine from a repository (the default)

RedHat or CentOS:
* EPEL yum repository needs to be configured

Example Usage
-------------

To install the default version of redmine

```puppet
    class { 'apache': }
    class { 'apache::mod::passenger': }
    class { '::mysql::server': }
    class { 'redmine': }
```

To install version 2.5.0 from the official svn repository

```puppet
    class { 'apache': }
    class { 'apache::mod::passenger': }
    class { '::mysql::server': }
    class { 'redmine':
      download_url => 'svn.redmine.org/redmine/tags/2.5.0',
      provider     => 'svn',
      version      => 'HEAD',
    }
```

Install default redmine with a postgresql database

```puppet
    class { 'apache': }
    class { 'apache::mod::passenger': }
    class { '::postgresql::server': }
    class { 'redmine':
      database_adapter => 'postgresql',
    }
```

Installing Plugins
------------------

Plugins can be installed and configured via the redmine::plugin resource. For example, a simple
plugin can be installed like this:

```puppet
    redmine::plugin { 'redmine_plugin'
      source => 'git://example.com/redmine_plugin.git'
    }
```
Plugins can be installed via git (the default) or any other version control system.

Bundle updates and database migrations will be handled automatically. You can update your plugin by
setting `ensure => latest` or directly specifying the version. More complex updates can be done by subscribing
to the plugin resource (via `subscribe => Redmine::Plugin['yourplugin']`)

Uninstalling plugins can be done by simply setting `ensure => absent`. Again, database migration and
deletion are done for you.


Redmine Parameters
------------------

#####`version`

  Set to desired version. Default: 2.2.3

#####`download_url`

  Download URL for redmine tar.gz when using wget as the provider. The repository url otherwise.
  When using wget, be sure to provide the full url.
  Default: https://github.com/redmine/redmine

#####`provider`

  The VCS provider or wget.
  When setting the provider to wget, be sure to set download_url to a valid tar.gz archive.
  To use the svn provider you have to provide the full url to the tag or branch you want to download and unset the version.
  Default: git

#####`database_server`

  Database server to use. Default: 'localhost'
  If server is not on localhost, the database and user must be setup in advance.

#####`database_user`

  Database user. Default: 'redmine'

#####`database_password`

  Database user password. Default: 'redmine'

#####`production_database`

  Name of database to use for production environment. Default: 'redmine'

#####`development_database`

  Name of database to use for development environment. Default: 'redmine_development'

#####`database_adapter`

  Database adapter to use for database configuration.
  Can be either 'mysql' for ruby 1.8, 'mysql2' for ruby 1.9 or 'postgresql'.
  Default: 'mysql' or 'mysql2' depending on your ruby version.

#####`smtp_server`

  SMTP server to use. Default: 'localhost'

#####`smtp_domain`

  Domain to send emails from. Default: $::domain

#####`smtp_port`

  SMTP port to use. Default: 25

#####`smtp_authentication`

  Toggle SMTP authentication. Default: false

#####`smtp_username`

  SMTP user name for authentication. Default: none

#####`smtp_password`

  SMTP password for authentication. Default: none

#####`vhost_aliases`

  Server aliases to use in the vhost config. Default 'redmine'. Expects a string.

#####`vhost_servername`

  Server name to use in the vhost config. Default 'redmine'. Expects a string.

#####`webroot`

  Directory in which redmine web files will be installed. Default: 'DOCROOT/redmine'
  DOCROOT is the document root of your apache server, usually /var/www or /var/www/html

#####`install_dir`

  Path where redmine will be installed
  Default: '/usr/src/redmine'

#####`override_options`

  Empty hash by default. Can be used to add additional options to the redmine configuration file.
  Example:
```puppet
class { 'redmine':
  default_override => {'foo' => 'bar', 'bar' => 'baz'},
}
```
This will generate a config that looks like this:
```yaml
default:
  # default setting of the module
  delivery_method: :smtp
  smtp_settings:
    address: localhost
    port: 25
    domain: example.com
  # user provided custom options
  bar: baz
  foo: bar
```
  Currently does not support nested options.

#####`plugins`

  Optional hash of plugins to install, which are passed to redmine::plugin

#####`www_subdir`

  Optional directory relative to the site webroot to install redmine in.
  Undef by default. Expects a path string without leading slash.
  When using this option the vhost config is your responsibility.
  Example:
```puppet
apache::vhost { 'www.somesite.com':
  priority        => 20,
  port            => '80',
  docroot         => '/usr/src/sites/www.somesite.com/website',
  servername      => 'www.somesite.com',
  serveraliases   => ['somesite.com'],
  directories     => [
                       { path => '/usr/src/sites/www.somesite.com/website',
                       },
                       { path    => '/usr/src/redmine',
                         options => 'FollowSymlinks ExecCGI',
                         custom_fragment => "PassengerAppRoot /var/www/html/redmine\n    RailsBaseURI /redmine",
                       },
                     ],
  aliases         => [
                       { alias            => '/redmine',
                         path             => '/usr/src/redmine',
                       },
                     ],
}
```

#####`create_vhost`

  Enable or disable vhost creation.
  True by default.
  When disabling this option the vhost config is your responsibility.

Plugin Parameters
------------------

#####`ensure`
  Wether the plugin should be installed.
  Possible values are installed, latest, and absent.

#####`source`
  Repository of the plugin. Required

#####`version`
  Set to desired version.

#####`provider`
  The vcs provider. Default: git

Contributing
------------

See the wiki for further information about contributing to this module: https://github.com/johanek/johanek-redmine/wiki
