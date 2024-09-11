# Manage roundcube configs
class kolab::roundcube {

  File {
    default:
      ensure  => present,
      mode    => '0640',
      owner   => 'root',
      group   => 'apache', # We support only centos7 for now.
      require => Package['roundcubemail'],
    ;
    ['/etc/roundcubemail/kolab_files.inc.php']:
      content => template('kolab/kolab_files.inc.erb'),
    ;
    ['/etc/roundcubemail/libkolab.inc.php']:
      content => template('kolab/libkolab.inc.erb'),
    ;
    ['/etc/roundcubemail/config.inc.php']:
      content => template('kolab/config.inc.erb'),
    ;
  }
}

