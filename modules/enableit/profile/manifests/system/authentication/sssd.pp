# SSSD Profile
# https://jhrozek.wordpress.com/2015/03/11/anatomy-of-sssd-user-lookup/
# https://wiki.samba.org/index.php/Samba_Member_Server_Troubleshooting
class profile::system::authentication::sssd (
  Boolean                                     $enable                = $common::user_management::authentication::sssd::enable,
  Optional[Array]                             $extra_packages,
  Array[Eit_types::Sssd::Service]             $services              = $common::user_management::authentication::sssd::services,
  # variable in hiera as it may depend on distribution
  Array[Eit_types::Sssd::Service]             $_available_services   = $common::user_management::authentication::sssd::_available_services,
  Eit_types::Sssd::Domains                    $domains               = $common::user_management::authentication::sssd::domains,
  Optional[Eit_types::Domain]                 $default_domain_suffix = $common::user_management::authentication::sssd::default_domain_suffix,
  Optional[Eit_types::Sssd::Debug_Level]      $debug_level           = $common::user_management::authentication::sssd::debug_level,
  Boolean                                     $manage_oddjobd        = $common::user_management::authentication::sssd::manage_oddjobd,
  Eit_types::Sssd::Full_name_format           $full_name_format      = $common::user_management::authentication::sssd::full_name_format,
  Optional[Eit_types::Sssd::Override_homedir] $override_homedir      = $common::user_management::authentication::sssd::override_homedir,
  Hash                                        $override_config       = $common::user_management::authentication::sssd::override_config,
  Eit_types::Noop_Value                       $noop_value            = $common::user_management::authentication::sssd::noop_value,
  Array                                       $required_packages     = $common::user_management::authentication::sssd::required_packages,
) {

  confine($enable, !lookup('common::user_management::authentication::manage_pam', Boolean),
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

      $_sssd_timer_content = @("EOT"/)
        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
        [Unit]
        Description=SSSD status check timer

        [Timer]
        OnBootSec=5min
        OnCalendar=*-*-* 00:00:00
        Unit=sssd-status-check.service

        [Install]
        WantedBy=timers.target
        | EOT

      $_sssd_service_content = @("EOT"/)
        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
        [Unit]
        Description=SSSD status check service
        Wants=sssd-status-check.timer

        [Service]
        Type=oneshot
        ExecStart=/bin/sh -c '/opt/obmondo/bin/sssd_status_check > ${textfile_directory}/sssd.prom'

        [Install]
        WantedBy=multi-user.target
        | EOT

      systemd::timer { 'sssd-status-check.timer':
        ensure          => ensure_present($enable),
        active          => $enable,
        enable          => $enable,
        noop            => $noop_value,
        timer_content   => $_sssd_timer_content,
        service_content => $_sssd_service_content,
        require         => [
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

      $_sssd_override_content = @("EOT"/)
        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
        [Unit]
        ConditionPathExists=/etc/krb5.keytab
        | EOT

      # Create the drop-in override for sssd
      systemd::unit_file { 'sssd.service':
        ensure  => 'present',
        content => $_sssd_override_content,
        path    => '/etc/systemd/system/sssd.service.d/override.conf',
        noop    => $noop_value,
        notify  => Service['sssd'],
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
        $_service_unit_names.each |$unit_name| {
          $_root_override_content = @("EOT"/)
            # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
            [Service]
            User=root
            Group=root
            | EOT

          # Create the drop-in override for each service in the list
          systemd::unit_file { "${unit_name}":
            ensure  => 'absent', # ensure => false in original maps to absent
            path    => "/etc/systemd/system/${unit_name}.service.d/override.conf",
            content => $_root_override_content,
            noop    => $noop_value,
            notify  => Service[$unit_name],
          }

          # Ensure the service state is managed accordingly
          service { $unit_name:
            ensure => 'stopped',
            enable => false,
            noop   => $noop_value,
          }
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
