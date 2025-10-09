# == Class: curator::config
#
# Representation of curator configuration
#
class curator::config {

  $path = dirname($curator::config_file)

  file { $path:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  file { $curator::config_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/config.erb"),
    require => [
      Package[$curator::package_name],
      File[$path],
    ],
  }

  concat { $curator::actions_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [
      File[$path],
    ]
  }

  concat::fragment { 'curator.config.header':
    target  => $curator::actions_file,
    content => template("${module_name}/actions_header.erb"),
    order   => '00',
  }
}
