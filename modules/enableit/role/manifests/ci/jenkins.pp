
# @summary Class for managing the Jenkins CI role
#
# @param ssl_combined_pem The SSL combined PEM file. No default.
#
# @param version The version of Jenkins to install. Defaults to 'installed'.
#
# @param config_hash A hash of configuration parameters. Defaults to an empty hash.
#
# @param plugins A hash of Jenkins plugins to install. Defaults to an empty hash.
#
# @groups certification ssl_combined_pem
#
# @groups jenkins_info version, config_hash, plugins
#
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
