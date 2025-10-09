#
# Manages a Wildfly module (`$WILDFLY_HOME/modules`).
#
# @param source Sets the source for this module, either a local file `file://`, a remote one `http://` or `puppet://`.
# @param dependencies Sets the dependencies for this module e.g. `javax.transaction`.
# @param system Whether this is a system (`system/layers/base`) module or not.
define wildfly::config::module(
  Variant[Pattern[/^file:\/\//], Pattern[/^puppet:\/\//], Stdlib::Httpsurl, Stdlib::Httpurl] $source,
  Optional[Boolean] $system = true,
  Optional[Array] $dependencies = []) {

  require wildfly::install

  $namespace_path = regsubst($title, '[.]', '/', 'G')

  if $system {
    $module_dir = 'system/layers/base'
  }

  $dir_path = "${wildfly::dirname}/modules/${module_dir}/${namespace_path}/main"

  exec { "Create Parent Directories: ${title}":
    path    => ['/bin','/usr/bin', '/sbin'],
    command => "mkdir -p ${dir_path}",
    unless  => "test -d ${dir_path}",
    user    => $wildfly::user,
    before  => [File[$dir_path]],
  }

  file { $dir_path:
    ensure => directory,
    owner  => $wildfly::user,
    group  => $wildfly::group,
  }

  if $source == '.' {
    $file_name = '.'
  } else {
    $file_name = inline_template('<%= File.basename(URI::parse(@source).path) %>')
  }

  file { "${dir_path}/${file_name}":
    ensure => 'file',
    owner  => $wildfly::user,
    group  => $wildfly::group,
    mode   => '0655',
    source => $source,
  }

  file { "${dir_path}/module.xml":
    ensure  => file,
    owner   => $wildfly::user,
    group   => $wildfly::group,
    content => epp('wildfly/module.xml', {
      'file_name'    => $file_name,
      'dependencies' => $dependencies,
      'name'         => $title,
    }),
  }

}
