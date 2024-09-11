# journal-remote
class role::monitoring::journal_remote (
  Boolean          $remote_enable = false,
  Boolean          $manage_output = true,
  Stdlib::Unixpath $output        = '/var/log/journal/remote',
) inherits ::role::monitoring {

  include 'profile::monitoring::journal_remote'
}
