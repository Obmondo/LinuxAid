# systemd
class common::system::systemd (
  Boolean                   $manage_journald,
  Boolean                   $manage_resolved,
  Systemd::JournaldSettings $journald_settings,
) {

  confine($facts['init_system'] != 'systemd',
          'Init system must be systemd')

  include ::profile::system::systemd
}
