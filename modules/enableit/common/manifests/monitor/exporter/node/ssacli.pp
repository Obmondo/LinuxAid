# Prometheus SSacli
class common::monitor::exporter::node::ssacli (
  Boolean           $enable         = $common::monitor::exporter::node::enable,
  Optional[Boolean] $noop_value     = false,
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
    ensure  => ensure_latest($enable),
    require => if $enable { Package['obmondo-node-exporter'] },
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
