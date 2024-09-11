# Journal Class
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
