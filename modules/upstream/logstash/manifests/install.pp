# This class is called from the kibana class to manage installation.
# It is not meant to be called directly.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class kibana::install {
  if $kibana::manage_repo {
    if $facts['os']['family'] == 'Debian' {
      include apt
      Class['apt::update'] -> Package['kibana']
    }
  }

  if $kibana::package_source != undef {
    case $facts['os']['family'] {
      'Debian': { Package['kibana'] { provider => 'dpkg' } }
      'RedHat': { Package['kibana'] { provider => 'rpm' } }
      default: { fail("unsupported parameter 'source' set for osfamily ${facts['os']['family']}") }
    }
  }

  $_oss = $kibana::oss ? {
    true    => '-oss',
    default => '',
  }

  package { 'kibana':
    ensure => $kibana::ensure,
    name   => "${kibana::package_name}${_oss}",
    source => $kibana::package_source,
  }
}
