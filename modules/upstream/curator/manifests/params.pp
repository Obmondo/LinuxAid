# Class curator::params
#
# Default configuration for curator module
#
class curator::params {
  $ensure           = 'latest'
  $package_name     = 'elasticsearch-curator'
  $package_provider = undef
  $manage_repo      = false
  $repo_version     = false
  $install_only     = false

  $config_file     = '/root/.curator/curator.yml'
  $actions_file    = '/root/.curator/actions.yml'
  $hosts           = 'localhost'
  $port            = 9200
  $url_prefix      = ''
  $use_ssl         = 'False'
  $certificate     = ''
  $client_cert     = ''
  $client_key      = ''
  $aws_key         = ''
  $aws_secret_key  = ''
  $aws_region      = ''
  $ssl_no_validate = 'False'
  $http_auth       = ''
  $timeout         = 30
  $master_only     = 'False'
  $log_level       = 'INFO'
  $logfile         = '/var/log/curator.log'
  $logformat       = 'default'
  $blacklist       = ['elasticsearch', 'urllib3']
}
