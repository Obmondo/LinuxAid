#drupal

##Overview

Install and manage different versions of Drupal including modules and sites.

##Usage

The module uses [Drush](https://github.com/drush-ops/drush) and the Drush makefiles to manage a Drupal site
configuration. So everytime any of the Puppet configuration changes, the whole site will be rebuild from ground. To be
able to do this, the site configuration (`settings.php`) and `files` have to be kept outside of the actual Drupal site.
Furthermore, multi-site configurations are currently not supported.

The structure of the three major properties (`modules`, `themes` and `libraries`) translates directly to the Drush
makefile format. See [here](https://github.com/drush-ops/drush/blob/master/examples/example.make) for an example of the
possible configuration.

Install Drupal 7 with a bunch of modules, a theme and a library:

```
drupal::site { 'example.com':
  core_version => '7.32',
  modules      => {
    'ctools'   => '1.4',
    'token'    => '1.5',
    'pathauto' => '1.2',
    'views'    => '3.8',
  },
  themes       => {
    'omega' => '4.3',
  },
  libraries    => {
    'jquery_ui' => {
      'download' => {
        'type' => 'file',
        'url'  => 'http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip',
        'md5'  => 'c177d38bc7af59d696b2efd7dda5c605',
      },
    },
  },
}
```

Install Drupal 6:

```
drupal::site { 'example.com':
  core_version => '6.33',
}
```

Install a module from a custom location:

```
drupal::site { 'example.com':
  modules => {
    'cck'   => {
      'download' => {
        'type' => 'file',
        'url'  => 'http://ftp.drupal.org/files/projects/cck-6.x-2.9.tar.gz',
        'md5'  => '9e30f22592b7ecf08d020e0c626efc5b',
      },
    },
  },
}
```

Apply a patch:

```
drupal::site { 'example.com':
  modules => {
    'pathauto' => {
      'version' => '1.2',
      'patch'   => [
        'https://www.drupal.org/files/pathauto_admin.patch'
      ],
    },
  },
}
```

Install the `jquery_ui` library into `sites/all/modules/jquery_ui/jquery.ui` as opposed to `sites/all/libraries/jquery_ui`.

```
drupal::site { 'example.com':
  libraries => {
    'jquery_ui' => {
      'download'       => {
        'type' => 'file',
        'url'  => 'https://www.dropbox.com/s/kcg4l39c3bqgee1/jquery.ui-1.6.zip',
        'md5'  => 'c177d38bc7af59d696b2efd7dda5c605',
      },
      'destination'    => 'modules/jquery_ui',
      'directory_name' => 'jquery.ui',
    },
  },
}
```

Configure the cron job:

```
drupal::site { 'example.com':
  cron_email_address => 'webmaster',
}
```

Disable the cron job (e.g. if it is managed separately):

```
drupal::site { 'example.com':
  cron_file_ensure => absent,
}
```

##Limitations

Drupal-specific

* No multi-sites support
* No backup configuration
* Drupal site configuration (`settings.xml`) has to be provided

The module has been tested on the following operating systems. Testing and patches for other platforms are welcome.

* Debian 7.0 (Wheezy)
* Debian 8.0 (Jessie)
* Ubuntu 12.04 (Precise Pangolin); upgrade to PHP 5.4 required
* Ubuntu 14.04 (Trusty Tahr)

[![Build Status](https://travis-ci.org/tohuwabohu/puppet-drupal.png?branch=master)](https://travis-ci.org/tohuwabohu/puppet-drupal)

##Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

###Development

This project uses rspec-puppet and beaker to ensure the module works as expected and to prevent regressions.

```
gem install bundler
bundle install --path vendor

bundle exec rake spec
bundle exec rake beaker
```
(note: see [Beaker - Supported ENV variables](https://github.com/puppetlabs/beaker-rspec/blob/master/README.md)
for a list of environment variables to control the default behaviour of Beaker)
