# EasyRedmine profile
# Does not support SSL
class profile::projectmanagement::easyredmine (
  Stdlib::Fqdn                $servername      = $role::projectmanagement::easyredmine::servername,
  Variant[
    Array[Stdlib::Fqdn],
    Stdlib::Fqdn
  ]                           $serveralias     = $role::projectmanagement::easyredmine::serveralias,
  Enum['mysql2','postgresql'] $db_connector    = $role::projectmanagement::easyredmine::_database,
  Eit_types::Version          $version         = $role::projectmanagement::easyredmine::version,
  # FIXME: currently just changed the variable to $location, in future we should support
  # URL, so it can download easyredmine from internet
  Stdlib::Unixpath            $download_url    = $role::projectmanagement::easyredmine::location,
  Optional[Hash]              $plugins         = $role::projectmanagement::easyredmine::plugins,
  Optional[String]            $custom_fragment = $role::projectmanagement::easyredmine::custom_fragment,
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
    version               => $version,
    database_adapter      => $db_connector,
    plugins               => $plugins,
    provider              => 'file',
    download_url          => $download_url,
    app                   => 'easyredmine',
    vhost_servername      => $servername,
    vhost_aliases         => $serveralias,
    smtp_domain           => 'enableit.dk',
    vhost_custom_fragment => $custom_fragment,
  }
}
