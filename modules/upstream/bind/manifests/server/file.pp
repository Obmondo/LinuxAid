# Define: bind::server::file
#
# ISC BIND server template-based or pre-created zone file definition.
# Either of $source or $content must be specificed when using it.
#
# Parameters:
#  $zonedir:
#    Directory where to store the zone file. Default: '/var/named'
#  $zonename:
#    Zone name to be used when validating the zone. Default: same as title
#  $owner:
#    Zone file user owner. Default: 'root'
#  $group:
#    Zone file group owner. Default: 'named'
#  $mode:
#    Zone file mode: Default: '0640'
#  $source:
#    Zone file content source. Default: none
#  $source_base:
#    Zone file content source base, where to look for a file named the same as
#    the zone itselt. Default: none
#  $content:
#    Zone file content (usually template-based). Default: none
#  $ensure:
#    Whether the zone file should be 'present' or 'absent'. Default: present.
#
# Sample Usage :
#  bind::server::file { 'example.com':
#    zonedir => '/var/named',
#    source  => 'puppet:///files/dns/example.com',
#  }
#
define bind::server::file (
  $zonedir     = '/var/named',
  $zonename    = $title,
  $owner       = 'root',
  $group       = undef,
  $mode        = '0640',
  $dirmode     = '0750',
  $source      = undef,
  $source_base = undef,
  $content     = undef,
  $ensure      = undef,
) {

  include '::bind::params'

  if $group {
    $bindgroup = $group
  } else {
    $bindgroup = $::bind::params::bindgroup
  }

  if $source {
    $zone_source = $source
  } elsif $source_base {
    $zone_source = "${source_base}${title}"
  } else {
    $zone_source = undef
  }

  if ! defined(File[$zonedir]) {
    file { $zonedir:
      ensure  => 'directory',
      owner   => $owner,
      group   => $bindgroup,
      mode    => $dirmode,
      require => Class['::bind::package'],
    }
  }

  file { "${zonedir}/${title}":
    ensure       => $ensure,
    owner        => $owner,
    group        => $bindgroup,
    mode         => $mode,
    source       => $zone_source,
    content      => $content,
    validate_cmd => "/usr/sbin/named-checkzone ${zonename} %",
    notify       => Class['::bind::service'],
    # For the parent directory
    require      => [
      Class['::bind::package'],
      File[$zonedir],
    ],
  }

}
