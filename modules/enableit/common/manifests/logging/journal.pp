# @summary Class for managing the journal configuration
#
# @param manage Whether to manage the journal service. Defaults to true.
#
# @param upload_enable Whether to enable journal upload. Defaults to false.
#
# @param package_name The name of the journal package. Defaults to 'systemd-journal-remote'.
#
# @param remote_url Optional URL for remote journal storage. Defaults to undef.
#
# @param noop_value Optional noop value for testing. Defaults to undef.
#
class common::logging::journal (
  Boolean                  $manage        = true,
  Boolean                  $upload_enable = false,
  String                   $package_name  = 'systemd-journal-remote',
  Optional[Eit_types::URL] $remote_url    = undef,
  Optional[Boolean]        $noop_value    = undef,
) inherits ::common::system::systemd {
  if $manage {
    include ::profile::logging::journal
  }
}
