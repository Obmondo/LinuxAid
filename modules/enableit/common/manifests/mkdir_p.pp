# @summary Class for providing `mkdir -p` functionality for a directory
#
# @param name The path of the directory to create. This parameter is required.
#
define common::mkdir_p () {
  validate_absolute_path($name)

  exec { "mkdir_p-${name}":
    command => "mkdir -p ${name}",
    unless  => "test -d ${name}",
    path    => '/bin:/usr/bin',
  }
}
