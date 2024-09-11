# Class: gitolite::server
#
# This module manages git server management
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
#                         and will write the apache template to a specific
#                         file on the filesystem.
#                         REQUIRES: $apache_notify
#  $apache_notify: Reference notification to be used if the gitolite module will
#                  manage apache, but the puppetlabs-apache module is not going
#                  to be used. This takes a type reference (e.g.:
#                  Class['apache::service'] or Service['apache2']) to send a
#                  notification to the reference to restart an external apache
#                  service.
#  $vhost: the virtual host of the apache instance.
#  $ssh_key: the SSH key used to seed the admin account for gitolite.
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
#   class { 'gitolite::server':
#    site_name => 'Frymanet.com Git Repository',
#    ssh_key   => 'ssh-rsa AAAA....',
#    vhost     => 'git.frymanet.com',
#  }
#
#  Use and External Apache Module:
#   class { 'gitolite::server':
#    site_name            => 'Frymanet.com Git Repository',
#    ssh_key              => 'ssh-rsa AAAA....',
#    vhost                => 'git.frymanet.com',
#    write_apache_conf_to => '/opt/git/git-apache.conf',
#    apache_notify        => Service['apache2'],
#  }
#
#  Do not manage Apache:
#   class { 'gitolite::server':
#    manage_apache        => 'false',
#    site_name            => 'Frymanet.com Git Repository',
#    ssh_key              => 'ssh-rsa AAAA....',
#  }
#
class gitolite::server(
  $ssh_key,
  $site_name            = '',
  $vhost                = '',
  $manage_apache        = '',
  $apache_notify        = '',
  $write_apache_conf_to = '',
  $wildrepos            = false
) {
  include stdlib

  if $site_name == '' { $real_site_name = $gitolite::params::gt_site_name }
  else { $real_site_name = $site_name }

  if $vhost == '' { $real_vhost = $gitolite::params::gt_vhost }
  else { $real_vhost = $vhost }

  anchor { 'gitolite::server::begin': }
  -> class { 'gitolite::server::package': }
  -> class { 'gitolite::server::config':
    site_name            => $real_site_name,
    ssh_key              => $ssh_key,
    vhost                => $real_vhost,
    manage_apache        => $manage_apache,
    apache_notify        => $apache_notify,
    write_apache_conf_to => $write_apache_conf_to,
    wildrepos            => $wildrepos,
  }
  -> anchor { 'gitolite::server::end': }
}
