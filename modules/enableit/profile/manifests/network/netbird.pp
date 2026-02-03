# Netbird Client Setup
# Servers runs on atat

# @summary Class for managing Netbird Agent
#
# @param setup_key The setup key used for authentication.
#
# @param enable Boolean to enable or disable the Netbird agent. Defaults to false.
#
# @param noop_value Eit_types::Noop_Value to enable no-operation mode.
#
# @param server The HTTPS URL of the Netbird server. Defaults to 'https://netbird.obmondo.com:443'.
#
# @param version
#   The Netbird version to install. The default is the type Eit_types::Version.
#   Link to netbird client releases page: https://github.com/netbirdio/netbird/releases
#
# @example Valid Netbird client version  
#   version = "0.59.3"
#
# @param install_method The method to install Netbird. The default is to download via their GitHub repo releases.
#
class profile::network::netbird (
  Boolean                 $enable         = $common::network::netbird::enable,
  Eit_types::Noop_Value   $noop_value     = $common::network::netbird::noop_value,
  String                  $setup_key      = $common::network::netbird::setup_key,
  Stdlib::HTTPSUrl        $server         = $common::network::netbird::server,
  Eit_types::Version      $version        = $common::network::netbird::version,
  Enum['package', 'repo'] $install_method = $common::network::netbird::install_method,
) {
  # Include archive module for download capabilities
  include archive

  $_installed_netbird_version = $facts['netbird_client_version']
  $_os_name                   = $facts['os']['name']
  $_kernel                    = $facts['kernel'].downcase

  # Install NetBird service
  if $enable {
    $_checksum = lookup('common::network::netbird::checksums')
    $_arch = profile::arch()

    if $_os_name == 'TurrisOS' {
      # NOTE: only tested on TurrisOS which has only armv6 packages
      # even though TurrisOS comes with armv7
      if $_arch == 'armv7' {
        $_arch = 'armv6'
      }

      exec { 'update_package_repo':
        command => 'opkg update; opkg install kmod-tun',
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        unless  => 'opkg list-installed | grep kmod-tun >/dev/null',
        noop    => $noop_value,
      }

      # Uncomment the following piece of code when
      # https://github.com/OpenVoxProject/openvox/pull/221 is merged
      # and we've migrated from Puppet to OpenVox.
      # package { 'kmod-tun':
      #   ensure   => ensure_present($enable),
      #   provider => 'opkg',
      #   noop     => $noop_value,
      #   require  => Exec['update_package_repo'],
      # }
    }

    # Download and extract NetBird binary from GitHub releases
    if $_installed_netbird_version != $version {
      archive { 'netbird':
        ensure        => ensure_present($enable),
        source        => "https://github.com/netbirdio/netbird/releases/download/v${version}/netbird_${version}_${_kernel}_${_arch}.tar.gz",
        extract       => true,
        path          => "/tmp/netbird_${version}_${_kernel}_${_arch}.tar.gz",
        extract_path  => '/usr/bin',
        checksum      => $_checksum[$version],
        checksum_type => 'sha256',
        cleanup       => true,
        user          => 'root',
        group         => 'root',
        noop          => $noop_value,
        notify        => Exec['netbird_service_install'],
      }

      # creates sysvinit script for OpenWRT
      $_service_file = $facts['init_system'] ? {
        'sysvinit' => '/etc/init.d/netbird',
        default => '/etc/systemd/system/netbird.service',
      }

      exec { 'netbird_service_install':
        command => 'netbird service install',
        path    => '/usr/bin:/usr/sbin:/bin:/sbin',
        creates => $_service_file,
        noop    => $noop_value,
        notify  => Service['netbird'],
      }

      if $facts['init_system'] == 'systemd' {
        Exec <| tag == 'systemd-netbird.service-systemctl-daemon-reload' |> {
          noop => $noop_value,
          subscribe => Exec['netbird_service_install'],
        }
      }
    }

    exec { 'netbird_up':
      command     => 'netbird up',
      noop        => $noop_value,
      path        => '/usr/bin:/usr/sbin:/bin:/sbin',
      environment => [
        "NB_SETUP_KEY=${setup_key}",
        "NB_MANAGEMENT_URL=${server}",
      ],
      unless      => "netbird status -d | grep -i 'Management: Connected'",
      require     => Service['netbird'],
    }
  }

  service { 'netbird':
    ensure => ensure_service($enable),
    enable => $enable,
    noop   => $noop_value,
    notify => Exec['netbird_up'],
  }

  firewall { '0001 allow netbird turn service':
    ensure => ensure_present($enable),
    proto  => 'udp',
    jump   => 'accept',
    dport  => 3478,
  }

  firewall { '0001 allow netbird turn relay connection':
    ensure => ensure_present($enable),
    proto  => 'udp',
    jump   => 'accept',
    dport  => '49152-65535',
  }
}
