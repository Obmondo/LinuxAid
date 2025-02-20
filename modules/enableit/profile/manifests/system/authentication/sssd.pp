# SSSD Profile
# https://jhrozek.wordpress.com/2015/03/11/anatomy-of-sssd-user-lookup/
# https://wiki.samba.org/index.php/Samba_Member_Server_Troubleshooting
class profile::system::authentication::sssd (
  Boolean                                     $enable                = $common::system::authentication::sssd::enable,
  Optional[Array]                             $extra_packages,
  Array[Eit_types::Sssd::Service]             $services              = $common::system::authentication::sssd::services,
  # variable in hiera as it may depend on distribution
  Array[Eit_types::Sssd::Service]             $_available_services   = $common::system::authentication::sssd::_available_services,
  Eit_types::Sssd::Domains                    $domains               = $common::system::authentication::sssd::domains,
  Optional[Eit_types::Domain]                 $default_domain_suffix = $common::system::authentication::sssd::default_domain_suffix,
  Optional[Eit_types::Sssd::Debug_Level]      $debug_level           = $common::system::authentication::sssd::debug_level,
  Boolean                                     $manage_oddjobd        = $common::system::authentication::sssd::manage_oddjobd,
  Eit_types::Sssd::Full_name_format           $full_name_format      = $common::system::authentication::sssd::full_name_format,
  Optional[Eit_types::Sssd::Override_homedir] $override_homedir      = $common::system::authentication::sssd::override_homedir,
  Hash                                        $override_config       = $common::system::authentication::sssd::override_config,
  Optional[Boolean]                           $noop_value            = $common::system::authentication::sssd::noop_value,
  Array                                       $required_packages     = $common::system::authentication::sssd::required_packages,
) {

  confine($enable, !lookup('common::system::authentication::manage_pam', Boolean),
          'PAM must be managed for SSSD to work')

  $_enable = !empty($domains) and $enable

  File {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }
  Package {
    noop => $noop_value,
  }

  # Remove the monitoring setup, once sssd is disabled
  class { 'monitor::system::service::sssd':
    enable => $_enable,
  }

  # The SSSD class wants to manage a lot of files as soon as it's included, so
  # we have to do it this way.
  if $_enable {

    $_is_systemd = $facts.dig('init_system') == 'systemd'
    $_is_using_ad = $domains.reduce(false) |$acc, $x| {
      $acc or ($x[1]['id_provider'] == 'ad')
    }

    if $_is_using_ad {
      package::install($required_packages, {
        before => Class['sssd'],
      })
    }

    if 'sudo' in $services {
      package::install('libsss-sudo', {
        before => Class['sssd'],
      })
    }

    $_domain_names = join(keys($domains), ', ')

    # pam-priv is not a real sssd service; sssd will fail if we add it to the
    # config
    $_sssd_config_services = $services - ['pam-priv']

    $_sssd_config = [
      {
        'config_file_version'   => 2,
        'domains'               => $_domain_names,
        'full_name_format'      => $full_name_format,
        'debug_timestamps'      => true,
        'default_domain_suffix' => $default_domain_suffix,
        # The list of services is optional on systemd platforms, but we might as
        # well include it anyway.
        'services'              => $_sssd_config_services,
        'debug_level'           => $debug_level,
      },
    ].merge_hashes

    # we do this trick to ensure that the realmd_tags array we have is turned
    # into strings
    $_domains = $domains.reduce({}) |$acc, $x| {
      [$name, $domain] = $x
      $_realmd_tags = $domain['realmd_tags']

      $_domain = stdlib::merge(
        $domain,
        if size($_realmd_tags) {
          { 'realmd_tags' => join($_realmd_tags, ' '), }
        },
      )

      stdlib::merge($acc, { "domain/${name}" => $_domain })
    }

    $_config = {
      'sssd' => $_sssd_config,
      'nss' => {
        'override_homedir' => $override_homedir,
      },
    } + $_domains + $override_config

    class { 'sssd':
      ensure                => ensure_present($_enable),
      sssd_package_ensure   => ensure_present($_enable),
      # NOTE: These packages gets installed by sssd and does not get removed
      # when sssd is removed
      extra_packages        => $extra_packages,
      extra_packages_ensure => ensure_present($_enable),
      service_dependencies  => [
        'dbus'                  # Needed for oddjob to start
      ],
      manage_oddjobd        => ($manage_oddjobd and $_enable),
      service_ensure        => ensure_service($_enable),
      config                => $_config,
    }

    if $_is_systemd {

      package { 'obmondo-sssd-status-check':
        ensure  => ensure_latest($enable),
        require => Package['sssd-dbus'],
      }

      $textfile_directory = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)

      file { "${textfile_directory}/sssd.prom" :
        ensure  => ensure_present($enable),
        require => Package['obmondo-sssd-status-check'],
      }

      common::services::systemd { 'sssd-status-check.timer':
        ensure     => $enable,
        enable     => $enable,
        noop_value => $noop_value,
        timer      => {
          'OnBootSec'  => '5min',
          'OnCalendar' => systemd_make_timespec({
            'year'   => '*',
            'month'  => '*',
            'day'    => '*',
            'hour'   => 0,
            'minute' => 0,
            'second' => 0,
          }),
          'Unit'       => 'sssd-status-check.service',
        },
        install    => {
          'WantedBy' => 'timers.target',
        },
        require    => [
          Package['obmondo-sssd-status-check'],
          File["${textfile_directory}/sssd.prom"],
        ],
      }

      common::services::systemd { 'sssd-status-check.service':
        ensure     => 'stopped',
        enable     => false,
        noop_value => $noop_value,
        unit       => {
          'Wants'    => 'sssd-status-check.timer',
        },
        service    => {
          'Type'      => 'oneshot',
          'ExecStart' => "/bin/sh -c '/opt/obmondo/bin/sssd_status_check > ${textfile_directory}/sssd.prom'",
        },
        install    => {
          'WantedBy' => 'multi-user.target',
        },
        require    => [
          Package['obmondo-sssd-status-check'],
          File["${textfile_directory}/sssd.prom"],
        ],
      }

      # On systemd all `sssd-*.socket` services are disabled by default; we have
      # to enable them manually. Likewise, we have to disable any socket services
      # that we do not want to use.
      #
      # systemd socket units for sssd are not present in xenial or bionic
      #
      # we make a numerical comparison by converting the OS release number to a 4
      # digit integer
      $_sssd_sockets_supported = $facts['os']['family'] ? {
        'Debian' => $facts['os']['release']['major'].regsubst(/[^0-9]/, '', 'G').then |$_x| { Integer($_x) } >= 2004,
        'RedHat' => $facts['os']['release']['major'].then |$_x| { Integer($_x) } >= 7,
        default => false,
      }
    }

    if $_is_systemd {

      common::services::systemd { 'sssd.service':
        ensure     => true,
        override   => true,
        unit       => {
          'ConditionPathExists' => '/etc/krb5.keytab',
        },
        noop_value => $noop_value,
      }

      if $_sssd_sockets_supported {
        $_enable_socket_services = ensure_service($enable)

        $_unit_names = $services.map |$_service| {
          "sssd-${_service}"
        }

        $_service_socket_names = $_unit_names.map |$_service| {
          "${_service}.socket"
        }

        # disable all the socket services; sssd will handle them
        service { $_service_socket_names:
          ensure => false,
          enable => false,
        }

        $_service_unit_names = $_unit_names.map |$service| {
          "${service}.service"
        }

        # Necessary to set other user as the unit defaults to using sssd:sssd, but
        # files are owned by root:
        # https://bugzilla.redhat.com/show_bug.cgi?id=1636002
        common::services::systemd { $_service_unit_names:
          ensure     => false,
          enable     => false,
          override   => true,
          service    => {
            'User'  => 'root',
            'Group' => 'root',
          },
          noop_value => $noop_value,
        }

      }
    }

    file { '/var/log/sssd':
      ensure => 'directory',
      before => Service['sssd'],
    }

  } else {
    service { 'sssd' :
      ensure => 'stopped',
      enable => false,
    }

    service { [
      'sssd-status-check.timer',
      'sssd-status-check.service'
    ] :
      ensure => 'stopped',
      enable => false,
      noop   => $noop_value,
    }

  }

}
