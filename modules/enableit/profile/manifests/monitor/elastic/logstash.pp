# Elastic Logstash
# https://github.com/elastic/logstash
class profile::elastic::logstash (
  Pattern[/\d\.\d\.\d/] $version     = '5.6.4',
  Boolean               $ensure      = true,
  Boolean               $manage_repo = true,
) {

  # Setup Logstash
  class { '::logstash':
    ensure      => ensure_present($ensure),
    manage_repo => $manage_repo,
    version     => $version,
  }

}
