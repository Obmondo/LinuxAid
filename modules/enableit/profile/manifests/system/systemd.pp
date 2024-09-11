#
class profile::system::systemd (
  Boolean $manage_journald = $common::system::systemd::manage_journald,
  Boolean $manage_resolved = $common::system::systemd::manage_resolved,

  # Jounald Settings
  Systemd::JournaldSettings $journald_settings = $common::system::systemd::journald_settings,
) {

  # The PAM component sets up user dirs in /run, keeps track of user sessions
  # and other handy things
  if $facts['os']['family'] == 'RedHat' {
    package::install('libpam-systemd')
  }

  # NOTE: 5c8565834d add this systemd class which was required when we implemented
  # ipset, but we should be moving our own setup into systemd slowly one by one
  # for now, moving the netword service

  $_resolved_settings = if lookup('common::system::dns::resolver') == 'systemd-resolved' and $manage_resolved {
    {
      resolved_ensure   => 'running',
      dns               => lookup('common::system::dns::nameservers').join(' '),
      domains           => lookup('common::system::dns::searchpath').join(' '),
      llmnr             => false,
      multicast_dns     => false,
      dnssec            => lookup('common::system::dns::dnssec'),
      dnsovertls        => lookup('common::system::dns::dns_over_tls'),
      cache             => true,
      dns_stub_listener => true,
      # https://manpages.ubuntu.com/manpages/bionic/man8/systemd-resolved.service.8.html
      # > This file may be symlinked from
      #   /etc/resolv.conf in order to connect all local clients that bypass local DNS APIs to
      #   systemd-resolved with correct search domains settings. This mode of operation is
      #   recommended.
      use_stub_resolver => true,
    }
  } else {
    {}
  }

  # NOTE: migrated the systemd-journald on 4th Dec 2023
  class{ 'systemd':
    manage_journald   => $manage_journald,
    journald_settings => $journald_settings,
    manage_resolved   => lookup('common::system::dns::resolver') == 'systemd-resolved' and $manage_resolved,
    *                 => $_resolved_settings,
    # Only enable when it manage is true and service_name is set to systemd-networkd
    manage_networkd   => (
      (lookup('common::network::service_name') == 'systemd-networkd')
      and
      (lookup('common::network::manage', Boolean, undef, false))
    ),
    manage_timesyncd  => false,
    manage_logind     => false,
  }
}
