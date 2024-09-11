# Common script class
define common::services::initscript (
  Optional[
    Variant[
      Enum['running', 'stopped'],
      Boolean,
    ]
  ] $ensure = 'running',
  Optional[String]
    $source = undef,
  Optional[String]
    $content = undef,
) {

  confine($facts['init_system'] == 'systemd', 'common::services::initscript only works on SYS V servers')

  file { "/etc/init.d/${name}" :
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $content,
    source  => $source,
    notify  => Service[$name],
  }

  service { $name :
    ensure    => $ensure,
    enable    => true,
    subscribe => File["/etc/init.d/${name}"],
  }
}
