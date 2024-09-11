# @summary Manage PAM limits.conf
#
# @example
#   This class is included by the pam class for platforms which use it.
#
# @param config_file
#   Path to limits.conf.
#
# @param config_file_mode
#   Mode for config_file.
#
# @param config_file_lines
#   Ordered array of limits that should be placed into limits.conf. Useful for
#   Suse 10 which does not use limits.d.
#
# @param config_file_source
#   String with source path to a limits.conf
#
# @param limits_d_dir
#   Path to limits.d directory.
#
# @param limits_d_dir_mode
#   Mode for limits_d_dir.
#
# @param purge_limits_d_dir
#   Boolean to purge the limits.d directory.
#
# @param purge_limits_d_dir_ignore
#   A glob or array of file names to ignore when purging limits.d
#
class pam::limits (
  Stdlib::Absolutepath $config_file    = '/etc/security/limits.conf',
  Optional[Array] $config_file_lines   = undef,
  Optional[String] $config_file_source = undef,
  Stdlib::Filemode $config_file_mode   = '0640',
  Stdlib::Absolutepath $limits_d_dir   = '/etc/security/limits.d',
  Stdlib::Filemode $limits_d_dir_mode  = '0750',
  Boolean $purge_limits_d_dir          = false,
  Optional[Variant[String[1], Array[String[1]]]] $purge_limits_d_dir_ignore = undef,
) {
  include pam

  if $config_file_lines or $config_file_source {
    # config_file_lines takes priority over config_file_source
    if $config_file_lines {
      $config_file_source_real = undef
      $content = template('pam/limits.conf.erb')
    } else {
      $content = undef
      $config_file_source_real = $config_file_source
    }
  } else {
    $content = template('pam/limits.conf.erb')
    $config_file_source_real = undef
  }
  if $facts['os']['family'] == 'Suse' and $facts['os']['release']['major'] == '10' {
    # do nothing
  } else {
    exec { "mkdir_p-${limits_d_dir}":
      command => "mkdir -p ${limits_d_dir}",
      unless  => "test -d ${limits_d_dir}",
      path    => '/bin:/usr/bin',
    }

    file { 'limits_d':
      ensure  => directory,
      path    => $limits_d_dir,
      owner   => 'root',
      group   => 'root',
      mode    => $limits_d_dir_mode,
      purge   => $purge_limits_d_dir,
      recurse => $purge_limits_d_dir,
      ignore  => $purge_limits_d_dir_ignore,
      require => [
        Package[$pam::package_name],
        Exec["mkdir_p-${limits_d_dir}"],
      ],
    }
  }

  file { 'limits_conf':
    ensure  => file,
    path    => $config_file,
    source  => $config_file_source_real,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => $config_file_mode,
    require => Package[$pam::package_name],
  }
}
