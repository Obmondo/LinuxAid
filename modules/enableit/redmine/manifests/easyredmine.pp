# Easyredmine
class redmine::easyredmine {
  package { 'redmine-installer' :
    provider => 'gem',
  }

  exec { 'Install Easy Redmine':
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin:/snap/bin',
    command => "redmine install ${redmine::download_url} /usr/src/redmine",
    creates => '/usr/src/redmine',
    require => Package['redmine-installer'],
  }
}
