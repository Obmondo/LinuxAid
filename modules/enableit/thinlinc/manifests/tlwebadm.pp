# Configure ThinLinc tlwebadm service
#
class thinlinc::tlwebadm (
  String                     $username        = $::thinlinc::tlwebadm_username,
  String                     $password        = $::thinlinc::tlwebadm_password,
  Stdlib::Absolutepath       $cert            = $::thinlinc::tlwebadm_cert,
  Stdlib::Absolutepath       $cert_key        = $::thinlinc::tlwebadm_cert_key,
  Stdlib::Port               $listen_port     = $::thinlinc::tlwebadm_listen_port,
  Array[Stdlib::IP::Address] $allowed_hosts   = $::thinlinc::tlwebadm_allowed_hosts,
  String                     $gnutls_priority = $::thinlinc::tlwebadm_gnutls_priority,

  Boolean                $log_to_file       = $::thinlinc::log_to_file,
  Stdlib::Absolutepath   $log_dir           = $::thinlinc::log_dir,
  Boolean                $log_to_syslog     = $::thinlinc::log_to_syslog,
  String                 $syslog_facility   = $::thinlinc::syslog_facility,
  Stdlib::Absolutepath   $syslog_socket     = $::thinlinc::syslog_socket,
  Optional[Stdlib::Host] $syslog_host       = $::thinlinc::syslog_host,
  ThinLinc::LogLevel     $default_log_level = $::thinlinc::default_log_level,
) inherits ::thinlinc {

  thinlinc::ensure_log_dir($log_dir)

  $_config_file = "${thinlinc::install_dir}/etc/conf.d/tlwebadm.hconf"
  file { $_config_file:
    ensure  => 'file',
    content => epp('thinlinc/conf.d/tlwebadm.hconf.epp'),
    notify  => Service['tlwebadm'],
  }

  firewall { '200 allow tlwebadm inbound traffic':
    jump   => 'accept',
    dport  => [$listen_port],
    proto  => 'tcp',
    source => if $allowed_hosts.count > 0{
      $allowed_hosts
    },
  }

  if $log_to_file {
    logrotate::rule { 'thinlinc-tlwebadm':
      path         => "${log_dir}/tlwebadm.log",
      copytruncate => true,
    }
  }

}
