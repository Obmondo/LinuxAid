# @summary Base sssd class
#
# Installs and configures SSSD
#
# @example Declaring the class
#   include ::sssd
#
# @param ensure Ensure if the sssd config file is to be present or absent.
#
# @param config Hash containing entire SSSD config.
#
# @param sssd_package Name of the sssd package. Only set this if your platform
#   is not supported or you know what you're doing.
#
# @param sssd_package_ensure Sets the ensure parameter of the sssd package.
#
# @param sssd_service Name of the sssd service.
#
# @param extra_packages Array of extra packages.
#
# @param extra_packages_ensure Value of ensure parameter for extra packages.
#
# @param config_file Path to the sssd config file.
#
# @param config_template Defines the template used for the sssd config.
#
# @param mkhomedir Whether or not to manage auto-creation of home directories on
#   user login.
#
# @param manage_oddjobd Whether or not to manage the oddjobd service.
#
# @param service_ensure Ensure if services should be running/stopped.
#
# @param service_dependencies Array of service resource names to manage before
#   managing sssd related services. Intended to be used to manage messagebus
#   service to prevent `Error: Could not start Service[oddjobd]`.
#
# @param enable_mkhomedir_flags Array of flags to use with authconfig
#   or authselect to enable auto-creation of home directories.
#
# @param disable_mkhomedir_flags Array of flags to use with authconfig
#   or authselect to disable auto-creation of home directories.
#
# @param pam_mkhomedir_umask Umask to set for pam_mkhomedir (oddjobd-mkhomedir on RedHat uses UMASK from login.defs)
#
# @param ensure_absent_flags Array of flags to use with authconfig when service
#   is disabled.
#
# @param authselect_profile  Name of authselect profile to use
#
class sssd (
  Enum['present', 'absent'] $ensure = 'present',
  Hash $config = {
    'sssd'               => {
      'domains'             => $::domain,
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    "domain/${::domain}" => {
      'access_provider'    => 'simple',
      'simple_allow_users' => ['root'],
    },
  },
  String $sssd_package = 'sssd',
  String $sssd_package_ensure = 'present',
  String $sssd_service = 'sssd',
  Array $extra_packages = [],
  String $extra_packages_ensure = 'present',
  Stdlib::Absolutepath $config_file = '/etc/sssd/sssd.conf',
  String $config_template = 'sssd/sssd.conf.erb',
  Boolean $mkhomedir = true,
  Boolean $manage_oddjobd = false,
  Variant[Boolean, Enum['running', 'stopped']] $service_ensure = 'running',
  Array $service_dependencies = [],
  Array $enable_mkhomedir_flags = [
    '--enablesssd',
    '--enablesssdauth',
    '--enablemkhomedir',
  ],
  Array $disable_mkhomedir_flags = [
    '--enablesssd',
    '--enablesssdauth',
    '--disablemkhomedir',
  ],
  String $pam_mkhomedir_umask = '0022',
  Array $ensure_absent_flags = [
    '--disablesssd',
    '--disablesssdauth',
  ],
  String $authselect_profile='sssd',
) {

  # Warn on unsupported platforms
  if ($::facts['os']['family'] == 'RedHat') {
    if ($::facts['os']['name'] == 'Amazon') and !($::facts['os']['release']['major'] in ['2']) {
      warning("osname Amazon's os.release.major is <${::facts['os']['release']['major']}> and must be 2.")
    }
    if !($::facts['os']['name'] == 'RedHat') and !($::facts['os']['release']['major'] in ['6', '7', '8']) {
      warning("osname RedHat's os.release.major is <${::facts['os']['release']['major']}> and must be 6, 7 or 8.")
    }
  }

  if $::facts['os']['family'] == 'Suse' {
    if !($::facts['os']['release']['major'] in ['11', '12']) {
      warning("osfamily Suse's os.release.major is <${::facts['os']['release']['major']}> and must be 11 or 12.")
    }
    if ($::facts['os']['release']['major'] == '11') and !($::facts['os']['release']['minor'] in ['3', '4']) {
      warning("Suse 11's os.release.minor is <${::facts['os']['release']['minor']}> and must be 3 or 4.")
    }
  }

  if ($::facts['os']['family'] == 'Debian') and !($::facts['os']['release']['major'] in ['8', '9', '14.04', '16.04', '18.04']) {
    warning("osfamily Debian's os.release.major is <${::facts['os']['release']['major']}> and must be 8 or 9 for Debian and 14.04, 16.04 or 18.04 for Ubuntu.")
  }

  # Manually set service provider to systemd on Amazon Linux 2
  # which is based off el7 and includes systemd.
  # See issue PUP-8248 - https://tickets.puppetlabs.com/browse/PUP-8248
  if ($::facts['os']['name'] == 'Amazon') and ($::facts['os']['release']['major'] == '2') {
    $service_provider = 'systemd'
  } else {
    $service_provider = undef
  }

  $service_enable = $service_ensure ? {
    'stopped' => false,
    default   => true,
  }

  ensure_packages($sssd_package,
    {
      ensure => $sssd_package_ensure,
    }
  )
  Package[$sssd_package] -> File['sssd.conf']

  if $extra_packages {
    ensure_packages($extra_packages,
      {
        ensure  => $extra_packages_ensure,
      }
    )
    Package[$sssd_package] -> Package[$extra_packages]
  }

  if ! empty($service_dependencies) {
    if $mkhomedir and $manage_oddjobd {
      $before = 'Service[oddjobd]'
    } else {
      $before = undef
    }

    ensure_resource('service', $service_dependencies,
      {
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        enable     => $service_enable,
        before     => $before,
      }
    )
  }

  if $mkhomedir and $manage_oddjobd {
    ensure_resource('service', 'oddjobd',
      {
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasstatus  => true,
        hasrestart => true,
        provider   => $service_provider,
        require    => Package[$extra_packages],
      }
    )
  }

  $file_ensure = $ensure ? {
    'present' => 'file',
    default   => $ensure,
  }

  file { 'sssd.conf':
    ensure  => $file_ensure,
    path    => $config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template($config_template),
  }

  case $::osfamily {
    'RedHat': {
      if ($::facts['os']['name'] == 'Fedora' and versioncmp($::facts['os']['release']['major'], '28') >= 0) or
      ( $::facts['os']['name'] == 'Redhat' and versioncmp($::facts['os']['release']['major'], '8') >= 0) {
        if $ensure == 'present' {
          $authselect_options = join(
            concat(
              [$authselect_profile],
              $mkhomedir ? {
                true  => $enable_mkhomedir_flags,
                false => $disable_mkhomedir_flags,
              }
            ),
            ' ',
          )
        } else {
          $authselect_options = join(concat([$authselect_profile],$ensure_absent_flags), ' ')
        }
        $authselect_exec = '/bin/authselect'

        # The --force option is required in the event that the
        # previous configuration contained in /etc/pam.d was not
        # created by authselect. This condition is true on fresh
        # installations.
        exec { 'authselect-mkhomedir':
          command => "${authselect_exec} select ${authselect_options} --force",
          unless  => "/usr/bin/test \"`${authselect_exec} current --raw`\" = \"${authselect_options}\"",
          require => File['sssd.conf'],
        }
      } else {
        if $ensure == 'present' {
          $authconfig_flags = $mkhomedir ? {
            true  => join($enable_mkhomedir_flags, ' '),
            false => join($disable_mkhomedir_flags, ' '),
          }
        }
        else {
          $authconfig_flags = join($ensure_absent_flags, ' ')
        }

        $authconfig_update_cmd = "/usr/sbin/authconfig ${authconfig_flags} --update"
        $authconfig_test_cmd   = "/usr/sbin/authconfig ${authconfig_flags} --test"
        $authconfig_check_cmd  = "/usr/bin/test \"`${authconfig_test_cmd}`\" = \"`/usr/sbin/authconfig --test`\""

        exec { 'authconfig-mkhomedir':
          command => $authconfig_update_cmd,
          unless  => $authconfig_check_cmd,
          require => File['sssd.conf'],
        }
      }
    }
    'Debian': {
      if $mkhomedir {
        file { '/usr/share/pam-configs/pam_mkhomedir':
          ensure  => 'file',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('sssd/pam_mkhomedir.erb'),
          notify  => Exec['pam-auth-update'],
        }

        exec { 'pam-auth-update':
          path        => '/bin:/usr/bin:/sbin:/usr/sbin',
          refreshonly => true,
          require     => Package[$sssd_package],
        }
      }
    }
    'Suse': {
      $pamconfig_mkhomedir_check_cmd  = '/usr/sbin/pam-config -q --mkhomedir | grep session:'
      $pamconfig_mkhomedir_umask_check_cmd  = "/usr/sbin/pam-config -q --mkhomedir | grep umask=${pam_mkhomedir_umask}"
      $pamconfig_check_cmd  = '/usr/sbin/pam-config -q --sss | grep session:'

      if $mkhomedir {

        exec { 'pam-config -a --mkhomedir':
          path   => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless => $pamconfig_mkhomedir_check_cmd,
        }
        exec { "pam-config -a --mkhomedir-umask=${pam_mkhomedir_umask}":
          path   => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless => $pamconfig_mkhomedir_umask_check_cmd,
        }
      }

      exec { 'pam-config -a --sss':
        path   => '/bin:/usr/bin:/sbin:/usr/sbin',
        unless => $pamconfig_check_cmd,
      }
    }
    default: { }
  }

  $service_ensure_real = $sssd::ensure ? {
    'absent' => 'stopped',
    default  => $sssd::service_ensure,
  }

  ensure_resource('service', $sssd_service,
    {
      ensure     => $service_ensure_real,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => File['sssd.conf'],
    }
  )
}
