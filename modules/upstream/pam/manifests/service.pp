# @summary Manage PAM file for specific service. The `pam::service` resource is
# reversible, so that any service that Puppet has locked using PAM can be
# unlocked by setting the resource ensure to absent and waiting for the next
# puppet run.
#
# @example
#   pam::service { 'sudo':
#     content => 'auth     required       pam_unix2.so',
#   }
#
# @param ensure
#   Specifies if a PAM service file should (`present`) or should not (`absent`)
#   exist. The default is set to 'present'
#
# @param pam_config_dir
#   Path to PAM files.
#
# @param content
#   Content of the PAM file for the service. The `content` and `lines`
#   parameters are mutually exclusive. Not setting either of these parameters
#   will result in an empty service definition file.
#
# @param lines
#   Provides content for the PAM service file as an array of lines. The
#   `content` and `lines` parameters are mutually exclusive. Not setting either
#   of these parameters will result in an empty service definition file.
#
define pam::service (
  Enum['present', 'absent'] $ensure     = 'present',
  Stdlib::Absolutepath $pam_config_dir  = '/etc/pam.d',
  Optional[String] $content             = undef,
  Optional[Array] $lines                = undef
) {
  include pam

  case $ensure {
    'present': {
      $file_ensure = 'file'
    }
    default: {
      $file_ensure = 'absent'
    }
  }

  if $content and $lines {
    fail('pam::service expects one of the lines or contents parameters to be provided, but not both')
  } elsif $content {
    $my_content = $content
  } elsif $lines {
    $my_content = template('pam/service.erb')
  } else {
    $my_content = undef
  }

  file { "pam.d-service-${name}":
    ensure  => $file_ensure,
    path    => "${pam_config_dir}/${name}",
    content => $my_content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
