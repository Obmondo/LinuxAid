# Gitolite Module

James Fryman <james@frymanet.com>

This module manages Gitolite from within Puppet.

# Quick Start

Install and bootstrap a Gitolite Server instance. Includes 
Gitolite and GitWeb as a viewer

# Requirements
_Puppet Labs Standard Library_
- http://github.com/puppetlabs/puppetlabs-stdlib
_Apache Module_
- http://github.com/puppetlabs/puppetlabs-apache

*Setup the initial Gitolite Admin keys and bootstrap* 
<pre>
   class { 'gitolite':
    server    => 'true',
    site_name => 'Frymanet.com Git Repository',
    ssh_key   => 'ssh-rsa AAAA....',
    vhost     => 'git.frymanet.com',
  }
</pre>

*Setup the initial Gitolite Admin keys and bootstrap using an external apache module* 
<pre>
   class { 'gitolite':
    server               => 'true',
    site_name            => 'Frymanet.com Git Repository',
    ssh_key              => 'ssh-rsa AAAA....',
    vhost                => 'git.frymanet.com',
    write_apache_conf_to => '/opt/git/git-apache.conf',
    apache_notify        => Service['apache2'],
  }
</pre>

*Setup the initial Gitolite Admin keys and bootstrap, but don't manage apache*
<pre> 
   class { 'gitolite':
    server               => 'true',
    manage_apache        => 'false',
    site_name            => 'Frymanet.com Git Repository',
    ssh_key              => 'ssh-rsa AAAA....',
  }
</pre>

*Only install Git Client Binaries*
<pre>
 class { 'gitolite': }
</pre>
