#
# Manages a Wildfly module (`$WILDFLY_HOME/modules`).
#
# @param source Sets the source for this module, either a local file `file://`, a remote one `http://` or `puppet://`.
# @param template Sets the EPP template to module.xml file. Default to 'wildfly/module.xml'.
# @param dependencies Sets the dependencies for this module e.g. `javax.transaction`.
# @param system Whether this is a system (`system/layers/base`) module or not.
# @param custom_file Sets a file source for module.xml. If set, template is ignored.
define wildfly::config::module (
  Variant[
    Pattern[/^\./],
    Pattern[/^file:\/\//],
    Pattern[/^puppet:\/\//],
    Stdlib::Httpsurl,
    Stdlib::Httpurl
  ]                 $source,
  String            $template     = 'wildfly/module.xml',
  Boolean           $system       = true,
  Array             $dependencies = [],
  Optional[String]  $custom_file  = undef,
) {
  require wildfly::install

  $namespace_path = regsubst($title, '[.]', '/', 'G')

  if $system {
    $module_dir = 'system/layers/base'
  }

  File {
    owner => $wildfly::user,
    group => $wildfly::group,
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
    $file_name = basename($source)
  }

  case $source {
    '.': {
    }
    /^(file:|puppet:)/: {
      file { "${dir_path}/${file_name}":
        ensure => file,
        owner  => $wildfly::user,
        group  => $wildfly::group,
        mode   => '0655',
        source => $source,
      }
    }
    default : {
      exec { "download module from ${source}":
        command  => "wget -N -P ${dir_path} ${source} --max-redirect=5",
        path     => ['/bin','/usr/bin', '/sbin'],
        loglevel => 'notice',
        creates  => "${dir_path}/${file_name}",
        require  => File[$wildfly::dirname],
      }

      file { "${dir_path}/${file_name}":
        ensure  => file,
        owner   => $wildfly::user,
        group   => $wildfly::group,
        mode    => '0655',
        require => Exec["download module from ${source}"],
      }
    }
  }

  if $custom_file {
    file { "${dir_path}/module.xml":
      ensure  => file,
      owner   => $wildfly::user,
      group   => $wildfly::group,
      content => file($custom_file),
    }
  } else {
    $params = {
      'file_name'    => $file_name,
      'dependencies' => $dependencies,
      'name'         => $title,
    }

    file { "${dir_path}/module.xml":
      ensure  => file,
      owner   => $wildfly::user,
      group   => $wildfly::group,
      content => epp($template, $params),
    }
  }
}
