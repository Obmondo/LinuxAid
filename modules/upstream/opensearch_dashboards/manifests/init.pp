# @summary
#   Module to manage OpensSearch Dashboards
#
# @param version The version to be installed
#
# @param manage_package Whether to manage the package installation
# @param package_directory The directory to install the package. Only used for package_install_method = 'archive'
# @param package_ensure The status of the package
# @param package_source The source for the package
# @param pin_package Whether to enable the `apt::pin` or `yum::versionlock` for the package
# @param apt_pin_priority The priority for apt::pin of the opensearch-dashboards package
#
# @param manage_repository Whether to manage the package repository
# @param repository_ensure The status of the repository
# @param repository_location The location of the repository
# @param repository_gpg_key The GnuPG key of the repository
#
# @param manage_config Whether to manage the configuration
# @param settings Custom settings for OpenSearch Dashboards
#
# @param manage_service Whether to manage the opensearch-dashboards service
# @param service_ensure The state for the opensearch-dashboards service
# @param service_enable Whether to enable the service
# @param restart_on_config_change Restart the service on any config changes
# @param restart_on_package_change Restart the service on package changes
#
class opensearch_dashboards (
  ##
  ## version
  ##
  Optional[String]                          $version                   = undef,

  ##
  ## package
  ##
  Boolean                                   $manage_package            = true,
  Stdlib::Absolutepath                      $package_directory         = '/opt/opensearch-dashboards',
  Enum['present', 'absent']                 $package_ensure            = 'present',
  Enum['archive', 'download', 'repository'] $package_source            = 'repository',
  Boolean                                   $pin_package               = true,
  Integer                                   $apt_pin_priority          = 1001,

  ##
  ## repository
  ##
  Boolean                                   $manage_repository         = true,
  Enum['present', 'absent']                 $repository_ensure         = 'present',
  Optional[Stdlib::HTTPUrl]                 $repository_location       = undef,
  Stdlib::HTTPUrl                           $repository_gpg_key        = 'https://artifacts.opensearch.org/publickeys/opensearch.pgp',

  ##
  ## settings
  ##
  Boolean                                   $manage_config             = true,
  Hash                                      $settings                  = {},

  ##
  ## service
  ##
  Boolean                                   $manage_service            = true,
  Stdlib::Ensure::Service                   $service_ensure            = 'running',
  Boolean                                   $service_enable            = true,
  Boolean                                   $restart_on_config_change  = true,
  Boolean                                   $restart_on_package_change = true,
) {
  $package_architecture = fact('os.hardware') ? {
    'amd64'  => 'x64',
    'arm64'  => 'arm64',
    'x64'    => 'x64',
    'x86_64' => 'x64',
  }
  $package_provider = fact('os.family') ? {
    'Debian' => 'dpkg',
    'RedHat' => 'rpm',
  }

  contain opensearch_dashboards::install
  contain opensearch_dashboards::config
  contain opensearch_dashboards::service

  Class['opensearch_dashboards::install'] -> Class['opensearch_dashboards::config'] -> Class['opensearch_dashboards::service']

  if $restart_on_package_change {
    Class['opensearch_dashboards::install'] ~> Class['opensearch_dashboards::service']
  }

  if $restart_on_config_change {
    Class['opensearch_dashboards::config'] ~> Class['opensearch_dashboards::service']
  }
}
