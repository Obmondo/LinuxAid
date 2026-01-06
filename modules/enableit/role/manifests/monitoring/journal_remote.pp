
# @summary Class for managing the Journal Remote role
#
# @param remote_enable Whether to enable the remote journal. Defaults to false.
#
# @param manage_output Whether to manage the output settings. Defaults to true.
#
# @param output The path for the output journal. Defaults to '/var/log/journal/remote'.
#
# @groups settings remote_enable, manage_output.
#
# @groups paths output
#
class role::monitoring::journal_remote (
  Boolean          $remote_enable = false,
  Boolean          $manage_output = true,
  Stdlib::Unixpath $output        = '/var/log/journal/remote',
) inherits ::role::monitoring {

  include 'profile::monitoring::journal_remote'
}
