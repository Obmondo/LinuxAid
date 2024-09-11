# freight

A Puppet module for managing Freight - a tool for creating and maintaining apt 
repositories easily. This module can manage several freight repositories 
residing on the same host.

# Module usage

Setup freight and nginx (using [puppetfinland/nginx](https://github.com/Puppet-Finland/puppet-nginx.git)):

    class { '::freight':
      manage_webserver      =>  true,
      document_root         =>  '/var/www/html',
      allow_address_ipv4    => 'anyv4',
      allow_address_ipv6    => 'anyv6',
      default_gpg_key_id    => 'C42A86B2',
      default_gpg_key_email => 'john@example.org',
    }

Create two freight repositories:

    # This one uses the default GPG keys defined above and stores the passphrase
    # on disk
    ::freight::config { 'repo1':
      varcache            => '/var/www/html/repo1',
      gpg_key_passphrase  => 'mysecret',
    }
    
    # This one uses a custom set of GPG keys and always prompts for the
    # passphrase
    ::freight::config { 'repo2':
      varcache      => '/var/www/html/repo2',
      gpg_key_id    => '974C71E8',
      gpg_key_email => 'jane@example.org',
    }

For details look at these manifests:

* [Class: freight](manifests/init.pp)
* [Define: freight::config](manifests/config.pp)
