# Splunk Forwarder
class profile::monitoring::splunk::forwarder (
  Boolean                   $enable              = $common::monitoring::splunk::forwarder::enable,
  Boolean                   $noop_value          = $common::monitoring::splunk::forwarder::noop_value,
  Eit_types::Version        $version             = $common::monitoring::splunk::forwarder::version,
  Optional[String]          $build               = $common::monitoring::splunk::forwarder::build,
  Optional[Stdlib::HTTPUrl] $deploymentserver    = $common::monitoring::splunk::forwarder::deploymentserver,
  Boolean                   $seed_password       = $common::monitoring::splunk::forwarder::seed_password,
  String[1]                 $password_hash       = $common::monitoring::splunk::forwarder::password_hash,
  Optional[Hash]            $forwarder_output    = $common::monitoring::splunk::forwarder::forwarder_output,
  Integer                   $log_keep_count      = $common::monitoring::splunk::forwarder::log_keep_count,
  Eit_types::Bytes          $log_max_file_size_b = $common::monitoring::splunk::forwarder::log_max_file_size_b,
) {

  user { 'splunk' :
    ensure  => ensure_present($enable),
    name    => 'splunk',
    system  => yes,
    shell   => '/usr/sbin/nologin',
    home    => '/opt/splunkforwarder',
    comment => 'Splunk Server',
    noop    => $noop_value,
  }

  if $enable {
    class { 'splunk::params':
      version => $version,
      build   => $build,
    }

    class { 'splunk::forwarder':
      seed_password    => $seed_password,
      splunk_user      => 'splunk',
      password_hash    => $password_hash,
      purge_outputs    => false,
      forwarder_output => $forwarder_output,
      forwarder_input  => {
        'default_host' => {
          section => 'default',
          setting => 'host',
          value   => $facts['networking']['fqdn'],
          tag     => 'splunk_forwarder',
        },
      }
    }

    splunkforwarder_deploymentclient { 'target-broker:deploymentServer':
      setting => 'targetUri',
      value   => $deploymentserver,
    }

    # Set ACL, so splunk user can read the required directories.
    posix_acl { '/var/log':
      action     => set,
      permission => [
        'group:splunk:rX',
      ],
      recursive  => true,
    }

    $_log_settings = {
      'appender.healthreporter.maxBackupIndex' => $log_keep_count,
      'appender.healthreporter.maxFileSize'    => $log_max_file_size_b,
      'appender.metrics.maxBackupIndex'        => $log_keep_count,
      'appender.metrics.maxFileSize'           => $log_max_file_size_b,
      'appender.A1.maxBackupIndex'             => $log_keep_count,
      'appender.A1.maxFileSize'                => $log_max_file_size_b,
      'appender.audittrail.maxBackupIndex'     => $log_keep_count,
      'appender.audittrail.maxFileSize'        => $log_max_file_size_b,
    }

    $_log_settings.each |$_name, $_value| {
      ini_setting { "splunkforwarder log config ${_name}":
        ensure            => ensure_present($enable),
        path              => '/opt/splunkforwarder/etc/log.cfg',
        section           => 'splunkd',
        key_val_separator => '=',
        setting           => $_name,
        value             => $_value,
        notify            => Service[$splunk::params::forwarder_service],
      }
    }
  } else {

    if $facts['init_system'] == 'systemd' {
      common::services::systemd { 'SplunkForwarder.service':
        ensure     => 'absent',
        enable     => false,
        noop_value => $noop_value,
      }
    }

    file { '/opt/splunkforwarder':
      ensure  => 'absent',
      force   => true,
      recurse => true,
      noop    => $noop_value,
    }

    package { 'splunkforwarder' :
      ensure => 'absent',
      noop   => $noop_value,
    }
  }
}
