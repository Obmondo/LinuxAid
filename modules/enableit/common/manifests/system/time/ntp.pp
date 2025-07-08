# @summary Class for managing NTP configuration
#
# @param ntp_client The NTP client to use. Can be 'chrony', 'ntpd', or 'systemd-timesyncd'.
#
# @param manage Whether to manage the NTP service. Defaults to the value of $common::system::time::manage_ntp.
#
# @param servers Array of NTP server hostnames or IPs. Defaults to an empty array.
#
# @param noop_value Optional parameter for noop mode. Defaults to undef.
#
class common::system::time::ntp (
  Enum['chrony', 'ntpd', 'systemd-timesyncd'] $ntp_client,
  Boolean $manage = $common::system::time::manage_ntp,
  Array[Stdlib::Host] $servers = [],
  Optional[Boolean] $noop_value = undef,
) inherits common::system::time {

  confine($ntp_client == 'systemd-timesyncd',
          $facts['init_system'] != 'systemd',
          '`$ntp_client=systemd-timesyncd` can only be used with systemd systems')

  confine($manage, $servers.size == 0,
          '`$servers` must contain one or more hosts')

  if $manage {
    contain profile::system::time::ntp
    contain common::monitor::exporter::ntp
  }
}
