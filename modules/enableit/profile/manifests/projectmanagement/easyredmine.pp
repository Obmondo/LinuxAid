# EasyRedmine profile
# Does not support SSL
class profile::projectmanagement::easyredmine (
  Stdlib::Fqdn     $servername   = $role::projectmanagement::easyredmine::servername,
  # FIXME: currently just changed the variable to $location, in future we should support
  # URL, so it can download easyredmine from internet
  Stdlib::Unixpath $download_url = $role::projectmanagement::easyredmine::location,
) {

  class { '::profile::web::apache':
    http    => true,
    https   => false,
    vhosts  => {},
    modules => [],
    ciphers => 'default',
  }

  apache::mod::passenger.contain

  class { 'redmine':
    version               => '3.3.0',
    database_adapter      => 'postgresql',
    plugins               => {},
    provider              => 'file',
    download_url          => $download_url,
    app                   => 'easyredmine',
    vhost_servername      => $servername,
    vhost_aliases         => $servername,
    smtp_domain           => 'enableit.dk',
    vhost_custom_fragment => '',
  }
}
