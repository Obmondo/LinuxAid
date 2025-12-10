# @summary Class for setting up common configurations
#
# @param noop_value Boolean value to control noop execution mode. Defaults to false.
#
# @param $__conf_dir
# Absolute path to the configuration directory. Defaults to '/etc/obmondo'.
#
# @param $__opt_dir
# Absolute path to the optional directory. Defaults to '/opt/obmondo'.
#
# @param $__bin_dir
# Absolute path to the binary directory. Defaults to '/opt/obmondo/bin'.
#
class common::setup (
  Eit_types::Noop_Value $noop_value = undef,
  Stdlib::Absolutepath  $__conf_dir = '/etc/obmondo',
  Stdlib::Absolutepath  $__opt_dir  = '/opt/obmondo',
  Stdlib::Absolutepath  $__bin_dir  = '/opt/obmondo/bin',
) {
  # Create Obmondo group for exporter to run under this group
  group { 'obmondo':
    ensure => present,
    system => true,
    noop   => $noop_value,
  }

  file {
    default:
      ensure => ensure_dir($::obmondo_monitor), #lint:ignore:top_scope_facts
      noop   => $noop_value,
      ;

    [
      $__conf_dir,
      $__bin_dir,
      $__opt_dir,
      "${__opt_dir}/home",
      "${__opt_dir}/share",
      "${__opt_dir}/etc",
      "${__conf_dir}/sudoers.d",
    ]:
      ;
  }
}
