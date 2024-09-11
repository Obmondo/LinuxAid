# Netbackup client configuration
class netbackup::client::config (
  $clientname        = $netbackup::client::clientname,
  $masterserver      = $netbackup::client::masterserver,
  $mediaservers      = $netbackup::client::mediaservers,
  $service_enabled   = $netbackup::client::service_enabled,
  $excludes          = $netbackup::client::excludes,
){

  file { 'bp.conf':
    ensure  => file,
    path    => '/usr/openv/netbackup/bp.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('netbackup/bp.conf.erb'),
  }

  service { 'netbackup-client':
    ensure     => $service_enabled,
    name       => 'netbackup',
    hasrestart => false,
    hasstatus  => false,
    pattern    => 'bpcd',
    subscribe  => File['bp.conf']
  }

  if $excludes.count {
    file { 'exclude_list':
      ensure  => file,
      path    => '/usr/openv/netbackup/exclude_list',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('netbackup/exclude_list.erb'),
    }
  }
}
