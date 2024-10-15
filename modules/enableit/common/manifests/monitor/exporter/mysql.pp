# Prometheus mysql Exporter
class common::monitor::exporter::mysql (
  Boolean             $enable                 = $::common::monitor::exporter::enable,
  String              $username               = $::profile::mysql::mysql_monitor_username,
  Eit_types::Password $password               = $::profile::mysql::mysql_monitor_password,
  Stdlib::Port        $mysql_port             = $::profile::mysql::mysql_port,
  String              $mysql_monitor_hostname = $::profile::mysql::mysql_monitor_hostname,
  Stdlib::Port        $listen_port            = 9104,
) {

  class { 'prometheus::mysqld_exporter':
    package_name      => 'obmondo-mysqld-exporter',
    tag               => $::trusted['certname'],
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    user              => 'mysqld_exporter',
    group             => 'mysqld_exporter',
    cnf_user          => $username,
    cnf_password      => $password,
    export_scrape_job => $enable,
    scrape_port       => Integer($listen_port),
    scrape_host       => $trusted['certname'],
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-mysqld_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
