# @summary Class for managing systemd configuration
#
# @param manage_journald Whether to manage journald service. Defaults to undef.
#
# @param manage_resolved Whether to manage resolved service. Defaults to undef.
#
# @param manage_networkd Whether to manage the systemd-networkd service. Defaults to false.
#
# @param journald_settings Settings for journald configuration. Defaults to undef.
#
# @groups management manage_journald, manage_resolved, manage_networkd
# 
# @groups settings journald_settings
# 
class common::system::systemd (
  Boolean                   $manage_journald,
  Boolean                   $manage_resolved,
  Boolean                   $manage_networkd,
  Systemd::JournaldSettings $journald_settings,
) {
  confine($facts['init_system'] != 'systemd', 'Init system must be systemd')
  include ::profile::system::systemd
}
