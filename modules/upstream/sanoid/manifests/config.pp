# Sanoid::Config
class sanoid::config (
  Sanoid::Pools     $pools       = $sanoid::pools,
  Sanoid::Templates $templates   = $sanoid::templates,
  String            $config_file = $sanoid::config_file,
) {

  file { '/etc/sanoid':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file { "/etc/sanoid/${config_file}":
    ensure  => file,
    content => epp('sanoid/sanoid.conf.epp', {
      'pools'     => $pools,
      'templates' => $templates,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/sanoid'],
  }
}
