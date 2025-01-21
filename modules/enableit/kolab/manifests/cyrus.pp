# Manage imap from cyrus
class kolab::cyrus {
  # Firewall
  firewall {'000 allow imaps':
    proto => 'tcp',
    dport => 993,
    jump  => 'accept',
  }

  # Install package
  package { 'cyrus-imapd' : }
  package { 'clamav-update' : }

  # Remove the 'Example' line from freshclam.conf to run the freshclam
  # TODO test on Debian family.
  file_line { 'freshclam_conf header' :
    ensure  => present,
    path    => '/etc/freshclam.conf',
    match   => '^Example',
    line    => '#Example # Edit by Puppet',
    require => Package['clamav-update'],
  }

  # See https://askubuntu.com/questions/1214151/ubuntu-clamav-freshclam-cant-download-main-cvd
  file_line { 'freshclam_conf receivetimeout' :
    ensure  => present,
    path    => '/etc/freshclam.conf',
    match   => '^#?ReceiveTimeout',
    line    => 'ReceiveTimeout 60',
    require => Package['clamav-update'],
  }

  # Run freshclam, otherwise clamd@amavisd will fail to run.
  exec { 'freshclam' :
    command => '/usr/bin/freshclam',
    unless  => '/usr/bin/freshclam | grep -E "main|daily|bytecode" | grep "up to date"',
    timeout => '600',
  }

  # Update clamav antivirus database
  cron { 'freshclam_update' :
    command => '(test -x /usr/bin/freshclam && /usr/bin/freshclam --quiet)',
    user    => 'root',
    hour    => '04',
    minute  => '00',
    require => Package['clamav-update']
  }

  # Setup configuration file
  file { 'imapd.conf' :
    ensure  => present,
    content => template('kolab/imapd.conf.erb'),
    owner   => 'cyrus',
    group   => 'mail',
    path    => '/etc/imapd.conf'
  }

  # Manage service
  service { 'cyrus-imapd' :
    ensure    => running,
    enable    => true,
    require   => Package['cyrus-imapd'],
    subscribe => File['imapd.conf']
  }
  service { 'clamd@amavisd' :
    ensure  => running,
    enable  => true,
    require => Package['clamav-server']
  }
}
