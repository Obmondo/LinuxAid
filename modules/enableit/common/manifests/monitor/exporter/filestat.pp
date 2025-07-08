# @summary Class for monitoring file statistics with Prometheus exporter
#
# @param enable Boolean flag to enable or disable the exporter. Defaults to false.
#
# @param noop_value Boolean value used for noop operations during testing. Defaults to false.
#
# @param config_file The path to the exporter configuration YAML file. Defaults to "${common::monitor::exporter::config_dir}/filestat_exporter.yaml".
#
# @param working_directory The working directory for the exporter process. Defaults to '/backup'.
#
# @param file_pattern An array of file patterns to monitor. Defaults to an empty array.
#
# @param listen_address The IP and port to listen on, in the format 'IP:port'. Defaults to '127.254.254.254:63387'.
#
class common::monitor::exporter::filestat (
  Boolean                     $enable            = false,
  Boolean[false]              $noop_value        = false,
  Stdlib::Absolutepath        $config_file       = "${common::monitor::exporter::config_dir}/filestat_exporter.yaml",
  Stdlib::Absolutepath        $working_directory = '/backup',
  Array[String]               $file_pattern      = [],
  Eit_types::IPPort           $listen_address    = '127.254.254.254:63387',
) {
  confine($enable, $file_pattern.size == 0, 'filestat needs some file_pattern, so it can monitor those, try setting common::monitor::exporter::filestat::file_pattern in hiera') #lint:ignore:140chars  
  File {
    noop => $noop_value
  }
  Service {
    noop => $noop_value
  }
  Package {
    noop => $noop_value
  }
  User {
    noop => $noop_value
  }
  Group {
    noop => $noop_value
  }
  $user = 'root'
  $_options = [
    "-web.listen-address=${listen_address}",
    '-config.file /opt/obmondo/etc/exporter/filestat_exporter.yaml',
  ]
  file { $config_file :
    ensure  => ensure_file($enable),
    noop    => false,
    owner   => $user,
    group   => $user,
    content => stdlib::to_yaml({
      'exporter' => {
        'working_directory'     => $working_directory,
        'enable_crc32_metric'   => false,
        'files'                 => [
          'patterns'            => $file_pattern,
        ],
        'enable_nb_line_metric' => false,
      },
    }),
    before  => if $enable {
      Package['obmondo-filestat-exporter']
    },
  }
  prometheus::daemon { 'filestat_exporter':
    package_name      => 'obmondo-filestat-exporter',
    package_ensure    => ensure_latest($enable),
    version           => '0.3.6',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_user       => false,
    manage_group      => false,
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => $user,
    group             => $user,
    notify_service    => Service[ 'filestat_exporter' ],
    real_download_url => 'https://github.com/michael-doubez/filestat_exporter',
    export_scrape_job => $enable,
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'filestat',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.  
  # upstream module cant handle noop. (which is correct)  
  Exec <| tag == 'systemd-filestat_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
