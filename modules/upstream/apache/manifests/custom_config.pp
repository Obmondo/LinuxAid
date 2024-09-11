# @summary
#   Adds a custom configuration file to the Apache server's `conf.d` directory. 
#
# If the file is invalid and this defined type's `verify_config` parameter's value is 
# `true`, Puppet throws an error during a Puppet run.
#
# @param ensure
#   Specifies whether the configuration file should be present.
#
# @param confdir
#   Sets the directory in which Puppet places configuration files.
#
# @param content
#   Sets the configuration file's content. The `content` and `source` parameters are exclusive 
#   of each other.
#
# @param filename
#   Sets the name of the file under `confdir` in which Puppet stores the configuration.
#
# @param priority
#   Sets the configuration file's priority by prefixing its filename with this parameter's 
#   numeric value, as Apache processes configuration files in alphanumeric order.<br />
#   To omit the priority prefix in the configuration file's name, set this parameter to `false`.
#
# @param source
#   Points to the configuration file's source. The `content` and `source` parameters are 
#   exclusive of each other.
#
# @param verify_command
#   Specifies the command Puppet uses to verify the configuration file. Use a fully qualified 
#   command.<br />
#   This parameter is used only if the `verify_config` parameter's value is `true`. If the 
#   `verify_command` fails, the Puppet run deletes the configuration file and raises an error, 
#   but does not notify the Apache service.
#   Command can be passed through as either a String, i.e. `'/usr/sbin/apache2ctl -t'`
#   An array, i.e. `['/usr/sbin/apache2ctl', '-t']`
#   Or an array of arrays with each one having to pass succesfully, i.e. `[['/usr/sbin/apache2ctl', '-t'], '/usr/sbin/apache2ctl -t']`
#
# @param verify_config
#   Specifies whether to validate the configuration file before notifying the Apache service.
#
# @param owner
#   File owner of configuration file
#
# @param group
#   File group of configuration file
#
# @param file_mode
#   File mode of configuration file
#
# @param show_diff
#   show_diff property for configuration file resource
#
define apache::custom_config (
  Enum['absent', 'present'] $ensure                                    = 'present',
  Stdlib::Absolutepath $confdir                                        = $apache::confd_dir,
  Optional[Variant[Sensitive, String]] $content                        = undef,
  Apache::Vhost::Priority $priority                                    = 25,
  Optional[String] $source                                             = undef,
  Variant[String, Array[String], Array[Array[String]]] $verify_command = $apache::params::verify_command,
  Boolean $verify_config                                               = true,
  Optional[String] $filename                                           = undef,
  Optional[String] $owner                                              = undef,
  Optional[String] $group                                              = undef,
  Optional[Stdlib::Filemode] $file_mode                                = undef,
  Boolean $show_diff                                                   = true,
) {
  if $content and $source {
    fail('Only one of $content and $source can be specified.')
  }

  if $ensure == 'present' and ! $content and ! $source {
    fail('One of $content and $source must be specified.')
  }

  if $filename {
    $_filename = $filename
  } else {
    if $priority {
      $priority_prefix = "${priority}-"
    } else {
      $priority_prefix = ''
    }

    ## Apache include does not always work with spaces in the filename
    $filename_middle = regsubst($name, ' ', '_', 'G')
    $_filename = "${priority_prefix}${filename_middle}.conf"
  }

  if ! $verify_config or $ensure == 'absent' {
    $notifies = Class['Apache::Service']
  } else {
    $notifies = undef
  }

  $_file_path = "${confdir}/${_filename}"
  $_file_mode = pick($file_mode, $apache::file_mode)

  file { "apache_${name}":
    ensure    => $ensure,
    path      => $_file_path,
    owner     => $owner,
    group     => $group,
    mode      => $_file_mode,
    content   => $content,
    source    => $source,
    show_diff => $show_diff,
    require   => Package['httpd'],
    notify    => $notifies,
  }

  if $ensure == 'present' and $verify_config {
    exec { "syntax verification for ${name}":
      command     => $verify_command,
      subscribe   => File["apache_${name}"],
      refreshonly => true,
      notify      => Class['Apache::Service'],
      before      => Exec["remove ${name} if invalid"],
      require     => Anchor['::apache::modules_set_up'],
    }

    $remove_command = ['/bin/rm', $_file_path]
    exec { "remove ${name} if invalid":
      command     => $remove_command,
      unless      => [$verify_command],
      subscribe   => File["apache_${name}"],
      refreshonly => true,
    }
  }
}
