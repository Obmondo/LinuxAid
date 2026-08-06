# @summary Class for managing the Journal Remote role
#
# @param remote_enable Whether to enable the remote journal. Defaults to false.
#
# @param manage_output Whether to manage the output settings. Defaults to true.
#
# @groups settings remote_enable, manage_output.
#
class role::monitoring::journal_remote (
  Boolean          $remote_enable = false,
  Boolean          $manage_output = true,
) inherits ::role::monitoring {

  include 'profile::collector::journal_remote'
}
