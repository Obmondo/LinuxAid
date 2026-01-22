# Elastic Curator
# https://github.com/elastic/curator
class profile::elastic::curator (
  Integer[5]                          $version      = 5,
  Boolean                             $ensure       = true,
  Hash[Eit_types::SimpleString, Hash] $filters      = {},
  Stdlib::Unixpath                    $config_file  = '/etc/elasticsearch/curator/curator.yml',
  Stdlib::Unixpath                    $actions_file = '/etc/elasticsearch/curator/action.yml',
) {

  # Setup Curator
  class { '::curator':
    ensure           => ensure_latest($ensure),
    manage_repo      => true,
    config_file      => $config_file,
    repo_version     => String($version),
    actions_file     => $actions_file,
    package_provider => $::facts['package_provider'],
  }

  $filters.each |$_name, $_filter| {
    curator::action { $_name:
      * => $_filter,
    }
  }

  # Cron Job
  cron { 'curator_run':
    ensure  => 'present',
    command => "chronic curator --config ${config_file} '${actions_file}'",
    hour    => 1,
    # to try to ensure that multiple nodes in a cluster do not run Curate at the
    # same time
    minute  => fqdn_rand(60),
    weekday => '*',
  }
}
