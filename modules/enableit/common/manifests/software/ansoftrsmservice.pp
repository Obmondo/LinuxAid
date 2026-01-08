# @summary Class for managing the Ansoft Remote Simulation Manager (RSM) Service
#
# This class installs and manages the Ansoft RSM systemd service,
# including setting up environment variables and configuring
# the service startup command.
#
# @param enable
#   Whether to enable and manage the service. Defaults to value from
#   `common::software::ansoftrsmservice::enable`.
#
# @param environment
#   A hash of environment variables to set in `/etc/default/ansoftrsmservice`.
#   Defaults to value from `common::software::ansoftrsmservice::environment`.
#
# @param ansysrsm_path
#   The base installation path of the Ansoft RSM software.
#   Used in both environment variables and ExecStart.
#   Defaults to value from `common::software::ansoftrsmservice::ansysrsm_path`.
#
# @param env Environment variables
#
# @groups service enable, manage.
#
# @groups configuration env, ansysrsm_path.
#
class common::software::ansoftrsmservice (
  Boolean $enable        = true,
  Boolean $manage        = false,
  Hash    $env           = {},
  String  $ansysrsm_path = undef,
) {

  if $manage {
    contain profile::software::ansoftrsmservice
  }
}
