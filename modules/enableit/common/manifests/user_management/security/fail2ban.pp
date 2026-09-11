# @summary Class for managing fail2ban (SSH brute-force protection)
#
# Thin wrapper around the upstream `fail2ban` module (dhoppe/voxpupuli).
# Disabled by default; enable it per host from linuxaid-config hiera with
# `common::user_management::security::fail2ban::enable: true`.
#
# @param enable Whether to install, configure and run fail2ban. Defaults to false.
#
# @param jails Which jails to enable. Defaults to ['ssh'], which turns on the
#   sshd jail in the upstream template.
#
# @param bantime How long a host stays banned. Integer seconds or a fail2ban
#   abbreviation string (e.g. '1h', '1d'). Defaults to '1h'.
#
# @param maxretry Number of failed attempts before a host is banned. Defaults to 5.
#
# @param ignoreip Extra addresses/networks that must never be banned. Loopback,
#   the RFC1918 10.0.0.0/8 space (covers the WireGuard tunnels) and the netbird
#   100.64.0.0/10 range are always whitelisted on top of this list.
#
# @param banaction Action used to ban an address. Defaults to 'iptables-multiport'.
#
# @param action Composite action fail2ban runs on a match. Defaults to 'action_'
#   (ban only, no mail) so the service does not depend on a working local MTA.
#   Set to 'action_mw' / 'action_mb' from hiera to also send mail.
#
# @param email Optional address notified about bans. Only relevant when `action`
#   is one of the mail variants. When unset the upstream module default is used.
#
# @param package_ensure Passed through to the fail2ban package. Defaults to 'present'.
#
# @param custom_jails Passed straight through to the upstream `fail2ban` class's
#   `custom_jails` param — one hash entry per jail, each fully defining its own
#   filter (`filter_failregex`, etc.) and jail settings (`logpath`, `port`,
#   `maxretry`, `findtime`, `bantime`, ...). See `fail2ban::jail` in the vendored
#   module for the full set of keys. Defaults to {} (no custom jails).
#
# @groups management enable
#
# @groups configuration jails, bantime, maxretry, ignoreip, banaction, action, email, package_ensure, custom_jails
#
class common::user_management::security::fail2ban (
  Boolean                                       $enable         = false,
  Array[String[1]]                              $jails          = ['ssh'],
  Fail2ban::Time                                $bantime        = '1h',
  Integer[1]                                    $maxretry       = 5,
  Array[String[1]]                              $ignoreip       = [],
  String[1]                                     $banaction      = 'iptables-multiport',
  String[1]                                     $action         = 'action_',
  Optional[String[1]]                           $email          = undef,
  Enum['absent', 'latest', 'present', 'purged'] $package_ensure = 'present',
  Hash[String[1], Hash]                         $custom_jails   = {},
) inherits ::common::user_management::security {

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
