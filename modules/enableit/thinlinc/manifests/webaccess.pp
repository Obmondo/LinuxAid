# Configure ThinLinc webaccess
#
class thinlinc::webaccess (
  Stdlib::Absolutepath $cert            = $::thinlinc::webaccess_cert,
  Stdlib::Absolutepath $cert_key        = $::thinlinc::webaccess_cert_key,
  Stdlib::Absolutepath $login_page      = $::thinlinc::webaccess_login_page,
  Stdlib::Port         $listen_port     = $::thinlinc::webaccess_listen_port,
  String               $gnutls_priority = $::thinlinc::webaccess_gnutls_priority,

  Boolean                $log_to_file       = $::thinlinc::webaccess_log_to_file,
  Stdlib::Absolutepath   $log_dir           = $::thinlinc::webaccess_log_dir,
  Boolean                $log_to_syslog     = $::thinlinc::webaccess_log_to_syslog,
  String                 $syslog_facility   = $::thinlinc::webaccess_syslog_facility,
  Stdlib::Absolutepath   $syslog_socket     = $::thinlinc::webaccess_syslog_socket,
  Optional[Stdlib::Host] $syslog_host       = $::thinlinc::webaccess_syslog_host,
  ThinLinc::LogLevel     $default_log_level = $::thinlinc::webaccess_default_log_level,
) inherits ::thinlinc {

  thinlinc::ensure_log_dir($log_dir)

  $_config_file = "${thinlinc::install_dir}/etc/conf.d/webaccess.hconf"

  file { $_config_file:
    ensure  => 'file',
    content => epp('thinlinc/conf.d/webaccess.hconf.epp'),
    notify  => Service['tlwebaccess'],
  }

  if $log_to_file {
    logrotate::rule { 'thinlinc-webaccess':
      path         => "${log_dir}/webaccess.log",
      copytruncate => true,
    }
  }

}
