# @summary Class for managing the Prometheus MySQL exporter
#
# @param enable 
# Whether to enable the exporter. Defaults to the value of $::common::monitor::exporter::enable.
#
# @param username 
# The MySQL monitor username. Defaults to the value of $::profile::mysql::mysql_monitor_username.
#
# @param password 
# The MySQL monitor password. Defaults to the value of $::profile::mysql::mysql_monitor_password.
#
# @param mysql_port 
# The port used by MySQL. Defaults to the value of $::profile::mysql::mysql_port.
#
# @param mysql_monitor_hostname 
# The hostname for MySQL monitoring. Defaults to the value of $::profile::mysql::mysql_monitor_hostname.
#
# @param listen_port 
# The port for Prometheus to scrape metrics. Defaults to 9104.
#
# @param noop_value 
# Whether to run in noop mode. Defaults to false.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class common::monitor::exporter::mysql (
  Boolean             $enable                 = $::common::monitor::exporter::enable,
  String              $username               = $::profile::mysql::mysql_monitor_username,
  Eit_types::Password $password               = $::profile::mysql::mysql_monitor_password,
  Stdlib::Port        $mysql_port             = $::profile::mysql::mysql_port,
  String              $mysql_monitor_hostname = $::profile::mysql::mysql_monitor_hostname,
  Stdlib::Port        $listen_port            = 9104,
  Boolean             $noop_value             = false,
  Eit_types::Encrypt::Params $encrypt_params  = ['password'],
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
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-mysqld_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
