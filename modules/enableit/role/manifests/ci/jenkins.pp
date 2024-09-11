# Jenkins CI
class role::ci::jenkins (
  String                      $ssl_combined_pem,
  Eit_types::Version          $version          = 'installed',
  Hash                        $config_hash      = {},
  Eit_types::Jenkins::Plugins $plugins          = {},
) {

  class { 'profile::ci::jenkins':
    version          => $version,
    ssl_combined_pem => $ssl_combined_pem,
    config_hash      => $config_hash,
    plugins          => $plugins,
  }
}
