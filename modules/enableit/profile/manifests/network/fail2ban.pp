# @summary Class for managing fail2ban (SSH brute-force protection)
#
# Thin wrapper around the upstream `fail2ban` module (voxpupuli/puppet-fail2ban).
# See common::network::fail2ban for the hiera-facing parameters.
#
# @param enable Whether to install, configure and run fail2ban.
#
# @param jails Which jails to enable.
#
# @param bantime How long a host stays banned.
#
# @param maxretry Number of failed attempts before a host is banned.
#
# @param ignoreip Extra addresses/networks that must never be banned.
#
# @param banaction Action used to ban an address.
#
# @param action Composite action fail2ban runs on a match.
#
# @param email Optional address notified about bans.
#
# @param package_ensure Passed through to the fail2ban package.
#
# @param custom_jails Passed straight through to the upstream `fail2ban` class's
#   `custom_jails` param.
#
class profile::network::fail2ban (
  Boolean                                       $enable         = $common::network::fail2ban::enable,
  Array[String[1]]                              $jails          = $common::network::fail2ban::jails,
  Fail2ban::Time                                $bantime        = $common::network::fail2ban::bantime,
  Integer[1]                                    $maxretry       = $common::network::fail2ban::maxretry,
  Array[String[1]]                              $ignoreip       = $common::network::fail2ban::ignoreip,
  String[1]                                     $banaction      = $common::network::fail2ban::banaction,
  String[1]                                     $action         = $common::network::fail2ban::action,
  Optional[String[1]]                           $email          = $common::network::fail2ban::email,
  Enum['absent', 'latest', 'present', 'purged'] $package_ensure = $common::network::fail2ban::package_ensure,
  Hash[String[1], Hash]                         $custom_jails   = $common::network::fail2ban::custom_jails,
) {
  if $enable {
    $_base_ignoreip = [
      '127.0.0.1/8',
      '::1',
      '10.0.0.0/8',
      '100.64.0.0/10',
    ]

    $_email = pick($email, "fail2ban@${facts['networking']['domain']}")

    class { 'fail2ban':
      package_ensure => $package_ensure,
      jails          => $jails,
      bantime        => $bantime,
      maxretry       => $maxretry,
      banaction      => $banaction,
      action         => $action,
      email          => $_email,
      whitelist      => unique($_base_ignoreip + $ignoreip),
      custom_jails   => $custom_jails,
    }
  }
}
