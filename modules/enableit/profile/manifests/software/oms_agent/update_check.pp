#omsagent update check
class profile::software::oms_agent::update_check (
  Boolean           $enable     = $common::software::oms_agent::update_check::enable,
) {

  if $enable { contain monitor::system::service::omsagent }
  $textfile_directory = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)

  package {'obmondo-omsagent-update-check':
    ensure  => ensure_latest($enable),
    require => if $enable { Package['obmondo-node-exporter'] },
  }

  file { "${textfile_directory}/omsagent.prom" :
    ensure  => ensure_file($enable),
    require => if $enable { Package['obmondo-omsagent-update-check'] },
  }

  service { [ 'omsagent-update-check.timer', 'omsagent-update-check.service' ]:
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['obmondo-omsagent-update-check'],
  }
}
