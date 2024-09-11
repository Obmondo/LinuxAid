# docker_distribution #

[![Build Status](https://travis-ci.org/cristifalcas/puppet-docker_distribution.png?branch=master)](https://travis-ci.org/cristifalcas/puppet-docker_distribution)

Puppet module for installing, configuring and managing [Docker Registry 2.0](https://github.com/docker/distribution)



## Support

This module is currently only for RedHat clones 6.x, 7.x and OpenSuSE:

The Docker toolset to pack, ship, store, and deliver content.

## Usage:

          include docker_distribution

### Use tls (it will use puppet certificates) and enable email hooks:

	  class { '::docker_distribution':
	    log_fields               => {
	      service     => 'registry',
	      environment => 'production'
	    }
	    ,
	    log_hooks_mail_disabled  => false,
	    log_hooks_mail_levels    => ['panic', 'error'],
	    log_hooks_mail_to        => 'docker_distribution@company.com',
	    filesystem_rootdirectory => '/srv/registry',
	    http_addr                => ':1443',
	    http_tls                 => true,
	  }

### Start from a container:

		  class { '::docker_distribution':
		    manage_as                    => 'container',
		    # configuration
		    log_fields                   => {
		      service     => 'registry',
		      environment => 'production',
		    },
		    log_hooks_mail_disabled      => false,
		    log_hooks_mail_levels        => ['panic'],
		    log_hooks_mail_to            => 'cloud@company.com',
		    log_hooks_mail_smtp_addr     => 'localhost:25',
		    log_hooks_mail_smtp_insecure => true,
		    filesystem_rootdirectory     => '/srv/registry',
		    http_addr                    => ':1443',
		    http_tls                     => true,
		    storage_delete               => true,
		  }

## Journald forward:

The class support a parameter called journald_forward_enable.

This was added because of the PIPE signal that is sent to go programs when systemd-journald dies.

For more information read here: https://github.com/projectatomic/forward-journald

### Usage:

	  include ::forward_journald
	  Class['forward_journald'] -> Class['docker_distribution']
