# Perforce version control system
class profile::projectmanagement::perforce (
  Stdlib::Absolutepath      $service_root      = $role::projectmanagement::perforce::service_root,
  Boolean                   $ssl               = $role::projectmanagement::perforce::ssl,
  Stdlib::Port              $service_port      = $role::projectmanagement::perforce::service_port,
  Eit_types::Password       $service_password  = $role::projectmanagement::perforce::service_password,
  Stdlib::Host              $hostname          = $role::projectmanagement::perforce::hostname,
  Perforce::Version         $version           = $role::projectmanagement::perforce::version,
  Stdlib::Absolutepath      $log_dir           = $role::projectmanagement::perforce::log_dir,
  Stdlib::Absolutepath      $log_file          = "${log_dir}/p4d.log",

  Boolean                   $git_connector     = $role::projectmanagement::perforce::git_connector,

  Eit_types::User           $admin_user        = $role::projectmanagement::perforce::admin_user,
  Eit_types::Password       $admin_password    = $role::projectmanagement::perforce::admin_password,
  Eit_types::User           $operator_user     = $role::projectmanagement::perforce::operator_user,
  Eit_types::Password       $operator_password = $role::projectmanagement::perforce::operator_password,

  Stdlib::Absolutepath      $backup_dir        = $role::projectmanagement::perforce::backup_dir,
) inherits profile {

  $_user = 'perforce'
  $_service_ssldir = '/etc/perforce/ssl'

  $_version_suffix = ".el${facts['os']['release']['major']}"

  $versionrelease = $version.split('-')

  $helix_packages = lookup('profile::projectmanagement::perforce::helix_packages')

  yum::versionlock { $helix_packages:
    ensure  => present,
    version => $versionrelease[0],
    release => "${versionrelease[1]}${_version_suffix}.*",
    epoch   => 0,
    arch    => 'x86_64',
  }

  class { 'perforce':
    user              => $_user,
    service_root      => $service_root,
    service_name      => 'perforce',
    service_ssldir    => if $ssl { $_service_ssldir },
    service_port      => $service_port,
    license_content   => undef,
    service_password  => $service_password,
    service_log       => $log_file,
    service_log_level => 1,
    version           => $version,
    # FIXME: remove this
    packages          => [
      'helix-p4dctl',
      'helix-proxy',
      'helix-broker',
      'helix-cli',
      'helix-p4d',
    ],
    install_root      => '/opt/perforce',
    var_dir           => '/var/lib/perforce',
  }

  file { $_service_ssldir:
    ensure => directory,
    owner  => $_user,
    group  => 'root',
    mode   => 'a=,ug+rX',
    before => Service['p4d'],
  }

  firewall { '100 allow perforce':
    proto => 'tcp',
    dport => $service_port,
    jump  => 'accept',
  }

  if $log_file =~ Stdlib::Absolutepath {
    logrotate::rule { 'perforce':
      ensure        => 'present',
      path          => "${log_dir}/*.log",
      rotate_every  => 'day',
      rotate        => 180,
      compress      => true,
      copy          => false,
      create        => false,
      delaycompress => true,
      missingok     => true,
    }
  }

  # for `chronic` and `ts`
  package::install('moreutils')

  $_cron_p4_base = "chronic p4 -u ${operator_user} -p localhost:1666"
  $_cron_ts = 'ts "%FT%TZ"'

  package { 'perforce-p4d-backup':
    ensure => 'latest',
  }

  file { $backup_dir:
    ensure => directory,
    owner  => $_user,
    group  => 'root'
  }

  profile::system::cron::job { 'p4d checkpoint and snapshot':
    command => "chronic /opt/obmondo/bin/perforce-p4d-backup --log-dir '${log_dir}' --backup-target-dir '${backup_dir}' --all --keep-days 7 --delete", # lint:ignore:140chars
    hour    => 3,
    minute  => 0,
    require => [ Package['perforce-p4d-backup'], File[$backup_dir] ]
  }
}
