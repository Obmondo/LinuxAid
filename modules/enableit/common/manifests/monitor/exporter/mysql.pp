# @summary Class for managing the Prometheus MySQL exporter
#
# @param enable Whether to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param username The MySQL monitor username. Defaults to the value of $profile::mysql::mysql_monitor_username.
#
# @param password The MySQL monitor password. Defaults to the value of $profile::mysql::mysql_monitor_password.
#
# @param noop_value Whether to run in noop mode. Defaults to false.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @encrypt_params password
#
# @groups settings enable, noop_value, encrypt_params
#
# @groups configuration username, password
#
class common::monitor::exporter::mysql (
  Boolean             $enable   = $common::monitor::exporter::enable,
  String              $username = $profile::mysql::mysql_monitor_username,
  Eit_types::Password $password = $profile::mysql::mysql_monitor_password,

  Eit_types::Noop_Value      $noop_value     = $common::monitor::exporter::noop_value,
  Eit_types::Encrypt::Params $encrypt_params = ['password'],
) {
  unless $enable { return() }

  class { 'prometheus::mysqld_exporter':
    package_name      => 'obmondo-mysqld-exporter',
    tag               => $::trusted['certname'],
    package_ensure    => ensure_latest($enable),
    init_style        => $facts['service_provider'],
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    user              => 'mysqld_exporter',
    group             => 'mysqld_exporter',
    cnf_user          => $username,
    cnf_password      => $password,
    export_scrape_job => $enable,
    scrape_port       => 9104,
    scrape_host       => $trusted['certname'],
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-mysqld_exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/mysqld_exporter.service'],
  } ~> Service['mysqld_exporter']
}
