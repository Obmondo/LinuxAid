# Enables either a packaged or custom ZFS Event Daemon "zedlet".
#
# Not specifying either `$content` or `$source` results in the zedlet being
# symlinked from the "installed zedlets" directory.
#
# @example Enabling a packaged zedlet
#   zfs::zed::zedlet { 'scrub.finish-notify.sh': }
#
# @example Enabling a custom zedlet
#   zfs::zed::zedlet { 'scrub.finish-notify.sh':
#     source => 'puppet:///example/scrub.finish-notify.sh',
#   }
#
# @param content Content of custom zedlet
# @param source Source of custom zedlet
# @param zedlet The filename for the zedlet
#
# @see puppet_classes::zfs::zed zfs::zed
#
# @since 2.0.0
define zfs::zed::zedlet (
  Optional[String] $content = undef,
  Optional[String] $source  = undef,
  String           $zedlet  = $title,
) {

  include zfs::zed

  # No content, make a symlink to the system
  if ! ($content and $source) {
    file { "${zfs::zed::conf_dir}/${zedlet}":
      ensure => link,
      target => "${zfs::zed::zedlet_dir}/${zedlet}",
    }
  } elsif ($content or $source) {
    file { "${zfs::zed::conf_dir}/${zedlet}":
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0755',
      content => $content,
      source  => $source,
    }
  } else {
    fail('Only specify content or source.')
  }
}
