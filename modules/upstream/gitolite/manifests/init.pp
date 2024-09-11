# Class: gitolite
#
# Description
#  This module is designed to configure and install git clients
#  and also setup a gitolite server as appropriate.
#
#   This module has been built and tested on RHEL systems.
#
# Parameters:
#  $server: Whether to install gitolite in addition to git core tools.
#  $site_name: (default: "fqdn Git Repository") The friendly name displayed on
#               the GitWeb main page.
#  $manage_apache: flag to determine whether gitolite module also manages Apache
#                  configuration
#  $write_apache_conf_to: (file path). This option is used when you want to
#                         contain apache configuration within the gitolite class,
#                         but do not want to use the puppetlabs-apache module
#                         to manage apache. This option takes a file path
#                         and will write the apache template to a specific file
#                         on the filesystem.
#                         REQUIRES: $apache_notify
#  $apache_notify: Reference notification to be used if the gitolite module will
#                  manage apache, but the puppetlabs-apache module is not
#                  going to be used. This takes a type reference (e.g.:
#                  Class['apache::service'] or Service['apache2']) to send a
#                  notification to the reference to restart an external apache
#                  service.
#  $vhost: the virtual host of the apache instance.
#  $ssh_key: the SSH key used to seed the admin account for gitolite.
#  $hooks: Array of repositories which have hooks in $gt_hooks_module
#  $wildrepos: Whether to enable wildrepos or not.
#
#
# Actions:
#   This module will install Java packages, ensure that it adheres
#   to LSB alternatives, and configure the base system to use the defined
#   Java $version on the system
#
# Requires:
#  - Class[stdlib]. This is Puppet Labs standard library to include additional
#    methods for use within Puppet.
#    [https://github.com/puppetlabs/puppetlabs-stdlib]
#
# Optional:
#  - Class[puppetlabs-apache]. Apache management module provided by puppetlabs
#    [https://github.com/puppetlabs/puppetlabs-apache]
#
# Sample Usage:
#
#  Manage Apache:
#   class { 'gitolite':
#    server        => 'true',
#    site_name     => 'Frymanet.com Git Repository',
#    ssh_key       => 'ssh-rsa AAAA....',
#    vhost         => 'git.frymanet.com',
#    manage_apache => true,
#  }
#
#  Use and External Apache Module:
#   class { 'gitolite':
#    server               => 'true',
#    site_name            => 'Frymanet.com Git Repository',
#    ssh_key              => 'ssh-rsa AAAA....',
#    vhost                => 'git.frymanet.com',
#    write_apache_conf_to => '/opt/git/git-apache.conf',
#    apache_notify        => Service['apache2'],
#    manage_apache        => true,
#  }
#
#  Do not manage Apache:
#   class { 'gitolite':
#    server               => 'true',
#    site_name            => 'Frymanet.com Git Repository',
#    ssh_key              => 'ssh-rsa AAAA....',
#  }
#
#  Only install Git Client Binaries:
#   class { 'gitolite': }
class gitolite(
  $server               = false,
  $site_name            = '',
  $vhost                = '',
  $manage_apache        = false,
  $apache_notify        = '',
  $write_apache_conf_to = '',
  $ssh_key              = '',
  $hooks                = false,
  $wildrepos            = false,
) {
  include stdlib
  include gitolite::params

  anchor { 'gitolite::begin': }
  -> class  { 'gitolite::client': }
  -> anchor { 'gitolite::end': }

  if $server == true {
    class { 'gitolite::server':
      site_name            => $site_name,
      vhost                => $vhost,
      manage_apache        => $manage_apache,
      apache_notify        => $apache_notify,
      write_apache_conf_to => $write_apache_conf_to,
      ssh_key              => $ssh_key,
      wildrepos            => $wildrepos,
      require              => Class['gitolite::client'],
      before               => Anchor['gitolite::end'],
    }
    if $hooks {
      gitolite::hook { $hooks:
        require => Class['gitolite::server'],
      }
    }
  }
}
