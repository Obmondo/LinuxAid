# @summary Class for managing the common::monitor::exporter::node::ssacli
#
# @param enable Boolean to enable or disable the exporter. Defaults to the value of $common::monitor::exporter::node::enable.
#
# @param noop_value Optional[Boolean], the noop value for resources. Defaults to false.
#
# @groups exporter_management enable, noop_value.
#
class common::monitor::exporter::node::ssacli (
  Boolean $enable     = $common::monitor::exporter::node::enable,
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::node::noop_value,
) {

  File {
    noop => $noop_value,
  }

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  $textfile_directory = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)

  package {'obmondo-ssacli-text-file-exporter':
    ensure => ensure_latest($enable),
  }

  file { "${textfile_directory}/ssacli.prom" :
    ensure  => ensure_file($enable),
    require => if $enable { Package['obmondo-ssacli-text-file-exporter'] },
  }

  service { 'ssacli_text_file_exporter.timer':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['obmondo-ssacli-text-file-exporter'],
  }
}
