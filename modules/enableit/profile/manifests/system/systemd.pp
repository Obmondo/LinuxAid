#
class profile::system::systemd (
  Boolean $manage_journald = $common::system::systemd::manage_journald,
  Boolean $manage_resolved = $common::system::systemd::manage_resolved,
  Boolean $manage_networkd = $common::system::systemd::manage_networkd,

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
    # Enable when asked for explicitly (common::system::systemd::manage_networkd),
    # or when common::network manages the interfaces through systemd-networkd
    manage_networkd   => $manage_networkd or (
      (lookup('common::network::service_name') == 'systemd-networkd')
      and
      (lookup('common::network::manage', Boolean, undef, false))
    ),
    manage_timesyncd  => false,
    manage_logind     => false,
  }

  # systemd before 258 only has the 2017 root key (KSK 20326) built in. The root
  # zone is signed with KSK 38696 since 2026-10-11, so with DNSSEC validation on
  # systemd-resolved rejects every answer: "DNSSEC validation failed: missing-key".
  # A positive trust anchor file replaces the built-in anchor, so it lists both keys.
  # Digests are from https://data.iana.org/root-anchors/root-anchors.xml
  $_systemd_version = $facts['systemd_version']

  if $_resolved_settings['dnssec'] and $_systemd_version and versioncmp(String($_systemd_version), '258') < 0 {
    $_root_trust_anchors = @(EOT)
      ; Managed by Puppet
      . IN DS 20326 8 2 E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
      . IN DS 38696 8 2 683D2D0ACB8C9B712A1948B27F741219298D0A450D612C483AF444A4C0FB2B16
      | EOT

    file { '/etc/dnssec-trust-anchors.d':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { '/etc/dnssec-trust-anchors.d/root.positive':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $_root_trust_anchors,
      notify  => Service['systemd-resolved'],
    }
  }
}
