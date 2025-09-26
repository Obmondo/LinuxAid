# Netbird Client Setup
# Servers runs on atat

# @summary Class for managing Netbird Agent
#
# @param setup_key The setup key used for authentication.
#
# @param enable Boolean to enable or disable the Netbird agent. Defaults to false.
#
# @param noop_value Optional boolean to enable no-operation mode.
#
# @param server The HTTPS URL of the Netbird server. Defaults to 'https://netbird.obmondo.com:443'.
#
# @param version The Netbird version to install. The default is the type Eit_types::Version.
#
# @param install_method The method to install Netbird. The default is to download via their GitHub repo releases.
#
class profile::network::netbird (
  Boolean                 $enable         = $common::network::netbird::enable,
  Optional[Boolean]       $noop_value     = $common::network::netbird::noop_value,
  String                  $setup_key      = $common::network::netbird::setup_key,
  Stdlib::HTTPSUrl        $server         = $common::network::netbird::server,
  Eit_types::Version      $version        = $common::network::netbird::version,
  Enum['package', 'repo'] $install_method = $common::network::netbird::install_method,
) {
  # Include archive module for download capabilities
  include archive

  $_kernel = $facts['kernel'].downcase
  $_arch   = profile::netbird_arch

  # Download and extract NetBird binary from GitHub releases
  archive { 'netbird':
    ensure       => ensure_present($enable),
    source       => "https://github.com/netbirdio/netbird/releases/download/v${version}/netbird_${version}_${_kernel}_${_arch}.tar.gz",
    extract      => true,
    extract_path => '/tmp',
    creates      => '/usr/bin/netbird',
    cleanup      => true,
    user         => 'root',
    group        => 'root',
    noop         => $noop_value,
  }

  # creates sysvinit script for OpenWRT
  $_service_file = $facts['init_system'] ? {
    'sysvinit' => '/etc/init.d/netbird',
    'default' => '/etc/systemd/system/netbird.service',
  }

  # Install NetBird service
  exec { 'netbird_service_install':
    command   => 'netbird service install',
    path      => '/usr/bin:/usr/sbin:/bin',
    creates   => $_service_file,
    onlyif    => $enable,
    noop      => $noop_value,
    subscribe => Archive['netbird'],
  }

  if $facts['init_system'] == 'systemd' {
    Exec <| tag == 'systemd-netbird.service-systemctl-daemon-reload' |> {
      noop => $noop_value,
      subscribe => Exec['netbird_service_install'],
    }
  }

  if $enable {
    exec { 'netbird up':
      command     => 'netbird up',
      noop        => $noop_value,
      path        => '/usr/bin:/usr/sbin:/bin',
      environment => [
        "NB_SETUP_KEY=${setup_key}",
        "NB_MANAGEMENT_URL=${server}",
      ],
      unless      => "netbird status -d | grep -i 'Management: Connected'",
      subscribe   => Exec['netbird_service_install'],
      notify      => Service['netbird'],
    }
  }

  service { 'netbird':
    ensure => ensure_service($enable),
    noop   => $noop_value,
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
