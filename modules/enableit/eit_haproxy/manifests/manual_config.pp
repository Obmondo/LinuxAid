# Haproxy Config
class eit_haproxy::manual_config (
  Customers::Source $config_file,
) {

  $_config_file = customers::to_file($config_file)

  $_validate_cmd = if dig($::eit_haproxy::service_options, 'CONFIG') {
    dig($::eit_haproxy::service_options, 'CONFIG')
  } else {
    '%'
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure       => present,
    mode         => '0440',
    source       => $_config_file['resource']['source'],
    validate_cmd => "/usr/sbin/haproxy -c -f ${_validate_cmd}",
    notify       => Service[$eit_haproxy::service_name],
  }

}
