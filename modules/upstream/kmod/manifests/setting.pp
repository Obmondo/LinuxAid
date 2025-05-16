# @summary Manage kernel module settings
#
# @param file File to manage
# @param category Setting type
# @param option Key to manage
# @param value Value to manage
# @param module Module to manage
# @param ensure State of the setting
#
# @example
#   kmod__setting { 'kmod::option bond0 mode':
#     ensure   => 'present',
#     module   => 'bond0',
#     category => 'options',
#     file     => '/etc/modprobe.d/bond0.conf',
#     option   => 'mode',
#     value    => '1',
#   }
define kmod::setting (
  Stdlib::Unixpath          $file,
  String[1]                 $category,
  Optional[String]          $option = undef,
  Optional[Scalar]          $value  = undef,
  String[1]                 $module = $name,
  Enum['present', 'absent'] $ensure = 'present',
) {
  include kmod

  ensure_resource(
    'file',
    $file,
    {
      'ensure' => 'file',
      'owner'  => $kmod::owner,
      'group'  => $kmod::group,
      'mode'   => $kmod::file_mode,
    }
  )

  case $ensure {
    'present': {
      if $option {
        $changes = [
          "set ${category}[. = '${module}'] ${module}",
          "set ${category}[. = '${module}']/${option} ${value}",
        ]
      } else {
        $changes = [
          "set ${category}[. = '${module}'] ${module}",
        ]
      }
    }

    'absent': {
      $changes = "rm ${category}[. = '${module}']"
    }

    default: { fail ( "unknown ensure value ${ensure}" ) }
  }

  augeas { "kmod::setting ${title} ${module}":
    incl    => $file,
    lens    => 'Modprobe.lns',
    changes => $changes,
    require => File[$file],
  }
}
