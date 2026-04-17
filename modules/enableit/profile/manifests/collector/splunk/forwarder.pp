# Splunk Forwarder
class profile::collector::splunk::forwarder (
  Boolean                   $enable              = $common::monitor::splunk::forwarder::enable,
  Eit_types::Noop_Value     $noop_value          = $common::monitor::splunk::forwarder::noop_value,
  Eit_types::Version        $version             = $common::monitor::splunk::forwarder::version,
  Optional[String]          $build               = $common::monitor::splunk::forwarder::build,
  Optional[Stdlib::HTTPUrl] $deploymentserver    = $common::monitor::splunk::forwarder::deploymentserver,
  Boolean                   $seed_password       = $common::monitor::splunk::forwarder::seed_password,
  String[1]                 $password_hash       = $common::monitor::splunk::forwarder::password_hash,
  Optional[Hash]            $forwarder_output    = $common::monitor::splunk::forwarder::forwarder_output,
  Integer                   $log_keep_count      = $common::monitor::splunk::forwarder::log_keep_count,
  Eit_types::Bytes          $log_max_file_size_b = $common::monitor::splunk::forwarder::log_max_file_size_b,
  Hash[String[1], Hash]     $addons              = $common::monitor::splunk::forwarder::addons,
  String[1]                 $package_ensure      = 'installed',
) {

  user { 'splunkfwd' :
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

    exec { 'splunkforwarder-stop-before-upgrade':
      command => '/opt/splunkforwarder/bin/splunk stop',
      onlyif  => 'test -f /opt/splunkforwarder/bin/splunk',
      timeout => 120,
      noop    => $noop_value,
    }

    class { 'splunk::forwarder':
      seed_password    => $seed_password,
      splunk_user      => 'splunkfwd',
      password_hash    => $password_hash,
      purge_outputs    => false,
      forwarder_output => $forwarder_output,
      package_ensure   => $package_ensure,
      forwarder_input  => {
        'default_host' => {
          section => 'default',
          setting => 'host',
          value   => $facts['networking']['fqdn'],
          tag     => 'splunk_forwarder',
        },
      }
    }

    Exec['splunkforwarder-stop-before-upgrade']
      -> Class['splunk::forwarder::install']
      -> exec { 'splunkforwarder-install-rpm':
        command => "/bin/rpm -U --force /opt/staging/splunk/splunkforwarder-${version}-*.x86_64.rpm",
        unless  => "/bin/rpm -q splunkforwarder-${version}",
        timeout => 300,
        noop    => $noop_value,
      }
      ~> Class['splunk::forwarder::service']

    splunkforwarder_deploymentclient { 'target-broker:deploymentServer':
      setting => 'targetUri',
      value   => $deploymentserver,
    }

    # Set ACL, so splunk user can read the required directories.
    posix_acl { '/var/log':
      action     => set,
      permission => [
        'group:splunkfwd:rX',
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

    $addons.each |$addon_name, $addon_params| {
      splunk::addon { $addon_name:
        * => $addon_params,
      }
    }
  } else {

    if $facts['init_system'] == 'systemd' {
      # Ensure the SplunkForwarder service is stopped and disabled
      service { 'SplunkForwarder.service':
        ensure => 'stopped',
        enable => false,
        noop   => $noop_value,
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
