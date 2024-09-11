# @summary This module manages PAM.
#
# @example Declaring the class
#   include pam
#
# @param allowed_users
#   String, Array or Hash of strings and/or arrays to configure users and
#   origins in access.conf. The default allows the root user/group from origin
#   'ALL'.
#
# @param manage_accesslogin
#   Boolean to manage the inclusion of the pam::accesslogin class.
#   Can be useful if /etc/security/access.conf is managed externally.
#   Defaults to true.
#
# @param login_pam_access
#   Control module to be used for pam_access.so for login. Valid values are
#   'required', 'requisite', 'sufficient', 'optional' and 'absent'.
#
# @param sshd_pam_access
#   Control module to be used for pam_access.so for sshd. Valid values are
#   'required', 'requisite', 'sufficient', 'optional' and 'absent'.
#
# @param limits_fragments
#   Hash of fragments to pass to pam::limits::fragments
#
# @param limits_fragments_hiera_merge
#   Boolean to control merges of all found instances of pam::limits_fragments
#   in Hiera. This is useful for specifying fragments at different levels of
#   the hierarchy and having them all included in the catalog.
#
# @param manage_faillock
#   Controls whether to manage faillock.conf
#
# @param manage_pwquality
#   Controls whether to manage pwquality.conf and pwquality.conf.d
#
# @param package_name
#   String or Array of packages providing the pam functionality. If undef,
#   parameter is set based on the OS version.
#
# @param pam_conf_file
#   Absolute path to pam.conf.
#
# @param services
#   Hash of pam::service entries to be created.
#
# @param pam_d_login_oracle_options
#   Allow array of extra lines at the bottom of pam.d/login for oracle systems
#   on EL5.
#
# @param pam_d_login_path
#   Absolute path to PAM login file.
#
# @param pam_d_login_owner
#   Owner of $pam_d_login_path.
#
# @param pam_d_login_group
#   Group of $pam_d_login_path.
#
# @param pam_d_login_mode
#   Mode of $pam_d_login_path.
#
# @param pam_d_login_template
#   Content template of $pam_d_login_path. If undef, parameter is set based on
#   the OS version.
#
# @param pam_d_sshd_path
#   PAM sshd path.
#
# @param pam_d_sshd_owner
#   Owner of $pam_d_sshd_path.
#
# @param pam_d_sshd_group
#   Group of $pam_d_sshd_path.
#
# @param pam_d_sshd_mode
#   Mode of $pam_d_sshd_path.
#
# @param pam_d_sshd_template
#   Content template of $pam_d_sshd_path. If undef, parameter is set based on
#   the OS version. For cases where a full customization of the sshd PAM
#   configuration is required, set pam_d_sshd_template to use
#   pam/sshd.custom.erb that is provided with this module. pam/sshd.custom.erb
#   must be further configured with the parameters pam_sshd_auth_lines,
#   pam_sshd_account_lines, pam_sshd_password_lines and pam_sshd_session_lines.
#   Note that the pam_d_sshd_template parameter is a no-op on Solaris.
#
# @param pam_sshd_auth_lines
#   An ordered array of strings that define the content for PAM sshd auth.
#   This setting is required and only valid if pam_d_sshd_template is
#   configured to use the pam/sshd.custom.erb template.
#
# @param pam_sshd_account_lines
#   An ordered array of strings that define the content for PAM sshd account.
#   This setting is required and only valid if pam_d_sshd_template is
#   configured to use the pam/sshd.custom.erb template.
#
# @param pam_sshd_password_lines
#   An ordered array of strings that define the content for PAM sshd password.
#   This setting is required and only valid if pam_d_sshd_template is
#   configured to use the pam/sshd.custom.erb template.
#
# @param pam_sshd_session_lines
#   An ordered array of strings that define the content for PAM sshd session.
#   This setting is required and only valid if pam_d_sshd_template is
#   configured to use the pam/sshd.custom.erb template.
#
# @param pam_auth_lines
#   An ordered array of strings that define the content for PAM auth. If
#   undef, parameter is set based on the OS version.
#
# @param pam_account_lines
#   An ordered array of strings that define the content for PAM account. If
#   undef, parameter is set based on the OS version.
#
# @param pam_password_lines
#   An ordered array of strings that define the content for PAM password. If
#   undef, parameter is set based on the OS version.
#
# @param pam_session_lines
#   An ordered array of strings that define the content for PAM session. If
#   undef, parameter is set based on the OS version.
#
# @param other_file
#   Path to PAM other file. Used on Suse 9 and Solaris.
#
# @param common_auth_file
#   Path to PAM common-auth file. Used on Debian/Ubuntu and Suse.
#
# @param common_auth_pc_file
#   Path to PAM common-auth-pc file. Used on Suse.
#
# @param common_account_file
#   Path to PAM common-account file. Used on Suse.
#
# @param common_account_pc_file
#   Path to PAM common-account-pc file. Used on Suse.
#
# @param common_password_file
#   Path to PAM common-password file. Used on Suse.
#
# @param common_password_pc_file
#   Path to PAM common-password-pc file. Used on Suse.
#
# @param common_session_file
#   Path to PAM common-session file. Used on Suse.
#
# @param common_session_pc_file
#   Path to PAM common-session-pc file. Used on Suse.
#
# @param common_session_noninteractive_file
#   Path to PAM common-session-noninteractive file, which is the same as
#   common-session-pc used on Suse. Used on Ubuntu 12.04 LTS.
#
# @param system_auth_file
#   Path to PAM system-auth file. Used on RedHat.
#
# @param system_auth_ac_file
#   Path to PAM system-auth-ac file. Used on RedHat.
#
# @param password_auth_file
#   Path to PAM password-auth file. Used on RedHat.
#
# @param password_auth_ac_file
#   Path to PAM password-auth-ac file. Used on RedHat.
#
# @param pam_password_auth_lines
#   Array of lines used in content template of $password_auth_ac_file. If
#   undef, parameter is set based on defaults for the detected platform.
#
# @param pam_password_account_lines
#   Array of lines used in content template of $password_auth_ac_file. If
#   undef, parameter is set based on defaults for the detected platform.
#
# @param pam_password_password_lines
#   Array of lines used in content template of $password_auth_ac_file. If
#   undef, parameter is set based on defaults for the detected platform.
#
# @param pam_password_session_lines
#   Array of lines used in content template of $password_auth_ac_file. If
#   undef, parameter is set based on defaults for the detected platform.
#
# @param manage_nsswitch
#   Boolean to manage the inclusion of the nsswitch class.
#
# @param common_files
#   Private, do not specify. Manage pam files where the entries match existing
#   template names. These common_files* parameters are used internally to
#   specify which files and names are needed. The data is coming out of Hiera
#   in `data/os/`.
#
# @param common_files_create_links
#   Private, do not specify. If true, then symlinks are created from the
#   suffixed files to the originals without the suffix.
#
# @param common_files_suffix
#   Suffix added to the common_files entries for the filename.
#
class pam (
  Variant[Array, Hash, String] $allowed_users               = 'root',
  Boolean $manage_accesslogin                               = true,
  Enum['absent', 'optional', 'required', 'requisite', 'sufficient']
  $login_pam_access                                       = 'required',
  Enum['absent', 'optional', 'required', 'requisite', 'sufficient']
  $sshd_pam_access                                        = 'required',
  Optional[Variant[Array, String]] $package_name            = undef,
  Stdlib::Absolutepath $pam_conf_file                       = '/etc/pam.conf',
  Optional[Hash] $services                                  = undef,
  Optional[Hash] $limits_fragments                          = undef,
  Boolean $limits_fragments_hiera_merge                     = false,
  Boolean $manage_faillock                                  = false,
  Boolean $manage_pwquality                                 = false,
  Array $pam_d_login_oracle_options                         = [],
  Stdlib::Absolutepath $pam_d_login_path                    = '/etc/pam.d/login',
  String $pam_d_login_owner                                 = 'root',
  String $pam_d_login_group                                 = 'root',
  Stdlib::Filemode $pam_d_login_mode                        = '0644',
  Optional[String] $pam_d_login_template                    = undef,
  Stdlib::Absolutepath $pam_d_sshd_path                     = '/etc/pam.d/sshd',
  String $pam_d_sshd_owner                                  = 'root',
  String $pam_d_sshd_group                                  = 'root',
  Stdlib::Filemode $pam_d_sshd_mode                         = '0644',
  Optional[String] $pam_d_sshd_template                     = undef,
  Optional[Array] $pam_sshd_auth_lines                      = undef,
  Optional[Array] $pam_sshd_account_lines                   = undef,
  Optional[Array] $pam_sshd_password_lines                  = undef,
  Optional[Array] $pam_sshd_session_lines                   = undef,
  Optional[Array] $pam_auth_lines                           = undef,
  Optional[Array] $pam_account_lines                        = undef,
  Optional[Array] $pam_password_lines                       = undef,
  Optional[Array] $pam_session_lines                        = undef,
  Stdlib::Absolutepath $other_file                          = '/etc/pam.d/other',
  Stdlib::Absolutepath $common_auth_file                    = '/etc/pam.d/common-auth',
  Stdlib::Absolutepath $common_auth_pc_file                 = '/etc/pam.d/common-auth-pc',
  Stdlib::Absolutepath $common_account_file                 = '/etc/pam.d/common-account',
  Stdlib::Absolutepath $common_account_pc_file              = '/etc/pam.d/common-account-pc',
  Stdlib::Absolutepath $common_password_file                = '/etc/pam.d/common-password',
  Stdlib::Absolutepath $common_password_pc_file             = '/etc/pam.d/common-password-pc',
  Stdlib::Absolutepath $common_session_file                 = '/etc/pam.d/common-session',
  Stdlib::Absolutepath $common_session_pc_file              = '/etc/pam.d/common-session-pc',
  Stdlib::Absolutepath $common_session_noninteractive_file  = '/etc/pam.d/common-session-noninteractive',
  Stdlib::Absolutepath $system_auth_file                    = '/etc/pam.d/system-auth',
  Stdlib::Absolutepath $system_auth_ac_file                 = '/etc/pam.d/system-auth-ac',
  Stdlib::Absolutepath $password_auth_file                  = '/etc/pam.d/password-auth',
  Stdlib::Absolutepath $password_auth_ac_file               = '/etc/pam.d/password-auth-ac',
  Optional[Array] $pam_password_auth_lines                  = undef,
  Optional[Array] $pam_password_account_lines               = undef,
  Optional[Array] $pam_password_password_lines              = undef,
  Optional[Array] $pam_password_session_lines               = undef,
  Boolean $manage_nsswitch                                  = true,
  Array $common_files                                       = [],
  Boolean $common_files_create_links                        = false,
  Optional[String] $common_files_suffix                     = undef,
) {
  # Fail on unsupported platforms
  if $facts['os']['family'] == 'RedHat' and !($facts['os']['release']['major'] in ['2','5','6','7','8', '9']) {
    fail("osfamily RedHat's os.release.major is <${::facts['os']['release']['major']}> and must be 2, 5, 6, 7, 8 or 9")
  }

  if $facts['os']['family'] == 'Solaris' and !($facts['kernelrelease'] in ['5.9','5.10','5.11']) {
    fail("osfamily Solaris' kernelrelease is <${facts['kernelrelease']}> and must be 5.9, 5.10 or 5.11")
  }

  if $facts['os']['family'] == 'Suse' and !($facts['os']['release']['major'] in ['9','10','11','12','13','15']) {
    fail("osfamily Suse's os.release.major is <${::facts['os']['release']['major']}> and must be 9, 10, 11, 12, 13 or 15")
  }

  if $facts['os']['name'] == 'Debian' and !($facts['os']['release']['major'] in ['7','8','9','10', '11']) {
    fail("Debian's os.release.major is <${facts['os']['release']['major']}> and must be 7, 8, 9, 10 or 11")
  }

  if $facts['os']['name'] == 'Ubuntu' and !($facts['os']['release']['major'] in ['12.04', '14.04', '16.04', '18.04', '20.04', '22.04', '24.04']) {
    fail("Ubuntu's os.release.major is <${facts['os']['release']['major']}> and must be 12.04, 14.04, 16.04, 18.04, 20.04, 22.04 or 24.04")
  }

  if $pam_d_sshd_template == 'pam/sshd.custom.erb' {
    unless $pam_sshd_auth_lines and
    $pam_sshd_account_lines and
    $pam_sshd_password_lines and
    $pam_sshd_session_lines {
      fail('pam_sshd_[auth|account|password|session]_lines required when using the pam/sshd.custom.erb template')
    }
  } else {
    if $pam_sshd_auth_lines or
    $pam_sshd_account_lines or
    $pam_sshd_password_lines or
    $pam_sshd_session_lines {
      fail('pam_sshd_[auth|account|password|session]_lines are only valid when pam_d_sshd_template is configured with the pam/sshd.custom.erb template') # lint:ignore:140chars
    }
  }

  if ($facts['os']['family'] in ['RedHat','Suse','Debian']) {
    if $manage_accesslogin {
      include pam::accesslogin
    }
    include pam::limits

    package { $package_name:
      ensure => installed,
    }

    file { 'pam_d_login':
      ensure  => file,
      path    => $pam_d_login_path,
      content => template($pam_d_login_template),
      owner   => $pam_d_login_owner,
      group   => $pam_d_login_group,
      mode    => $pam_d_login_mode,
    }

    file { 'pam_d_sshd':
      ensure  => file,
      path    => $pam_d_sshd_path,
      content => template($pam_d_sshd_template),
      owner   => $pam_d_sshd_owner,
      group   => $pam_d_sshd_group,
      mode    => $pam_d_sshd_mode,
    }
  }

  if $manage_faillock {
    include pam::faillock
  }

  if $manage_pwquality {
    include pam::pwquality
  }

  if $manage_nsswitch {
    include nsswitch
  }

  if $services {
    $services.each |$key,$value| {
      ::pam::service { $key:
        * => $value,
      }
    }
  }

  if $limits_fragments {
    if $limits_fragments_hiera_merge {
      $limits_fragments_real = lookup('pam::limits_fragments', Hash, 'deep', {})
    } else {
      $limits_fragments_real = $limits_fragments
    }
    $limits_fragments_real.each |$key,$value| {
      ::pam::limits::fragment { $key:
        * => $value,
      }
    }
  }

  $common_files.each |$_common_file| {
    # Solaris specific group
    $_real_group = $facts['os']['family'] ? {
      'Solaris' => 'sys',
      default   => 'root',
    }
    # Solaris 9 & 10 specific configuration file path and name
    case $facts['kernelrelease'] {
      '5.9','5.10': {
        $_resource_name = 'pam_conf'
        $_real_path     = $pam_conf_file
      }
      default: {
        $_resource_name = "pam_${_common_file}${common_files_suffix}"
        $_real_path     = getvar("${_common_file}${common_files_suffix}_file")
      }
    }

    file { $_resource_name:
      ensure  => file,
      path    => $_real_path,
      content => template("pam/${_common_file}.erb"),
      owner   => 'root',
      group   => $_real_group,
      mode    => '0644',
      require => Package[$package_name],
    }

    if $common_files_create_links == true {
      file { "pam_${_common_file}":
        ensure  => link,
        path    => getvar("${_common_file}_file"),
        target  => getvar("${_common_file}${common_files_suffix}_file"),
        owner   => 'root',
        group   => $_real_group,
        require => Package[$package_name],
      }
    }
  }
}
