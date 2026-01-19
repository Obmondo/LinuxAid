# Systemd_journal_remote
# https://dangibbs.uk/projects/puppet-systemd-journal-remote/
class profile::monitoring::journal_remote (
  Boolean          $enable        = $role::monitoring::journal_remote::remote_enable,
  Boolean          $manage_output = $role::monitoring::journal_remote::manage_output,
  Stdlib::Unixpath $output        = $role::monitoring::journal_remote::output,
) {

  confine($facts['init_system'] != 'systemd', 'Only systemd is supported')

  user { [
    'systemd-journal-remote',
    'systemd-journal-gatewayd',
  ]:
    ensure => ensure_present($enable),
  }

  class { '::systemd_journal_remote::remote':
    manage_service => $enable,
    manage_output  => $manage_output,
    service_ensure => ensure_service($enable),
    command_flags  => {
      'listen-http' => -3,
      'compress'    => 'yes',
      'split-mode'  => 'host',
      'output'      => $output,
    },
  }

  firewall_multi { '200 allow access to journald-remote':
    ensure => ensure_present($enable),
    proto  => 'tcp',
    dport  => 19532,
    jump   => 'accept',
  }

  logrotate::rule { 'journal-remote':
    ensure        => 'present',
    path          => '/var/log/journal/remote/*.journal',
    rotate_every  => 'week',
    rotate        => 6,
    compress      => true,
    delaycompress => false,
    missingok     => true,
    create        => false
  }
}
