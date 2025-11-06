# Class: samba::server
#
# Samba server.
#
# For all main options, see the smb.conf(5) and samba(7) man pages.
# For the SELinux related options, see smbd_selinux(8).
#
# Sample Usage :
#  include samba::server
#
class samba::server (
  Array[String]                              $services,
  Variant[Enum['present', 'latest'], String] $version                   = 'latest',
  Array[String]                              $packages                  = [
    'samba'
  ],
  Stdlib::Absolutepath                       $config_file               = '/etc/samba/smb.conf',
  Boolean                                    $manage_winbind            = false,
  Boolean                                    $enable_winbind            = false,
  Array[String]                              $winbind_packages          = [],
  Array[String]                              $winbind_services          = [],
  Boolean                                    $manage_libwbclient        = false,
  Array[String]                              $sssd_libwbclient_packages = [],

  # Main smb.conf options
  String                         $workgroup              = 'MYGROUP',
  String                         $server_string          = 'Samba Server Version %v',
  String                         $netbios_name           = '',
  Array[String]                  $interfaces             = [],
  Array                          $hosts_allow            = [],
  Stdlib::Absolutepath           $log_file               = '/var/log/samba/log.%m',
  Integer                        $max_log_size_kilobytes = 10000,
  String                         $passdb_backend         = 'tdbsam',
  Optional[String]               $realm                  = undef,
  Optional[Boolean]              $load_printers          = undef,
  Optional[Stdlib::Absolutepath] $printcap_name          = undef,
  Boolean                        $disable_spoolss        = true,

  Boolean                        $domain_master          = false,
  Boolean                        $domain_logons          = false,
  Boolean                        $local_master           = true,
  String                         $security               = 'user',
  Enum[
    'Never',
    'Bad User',
    'Bad Password',
    'Bad Uid'
  ]                                        $map_to_guest           = 'Never',
  Eit_types::Username                      $guest_account          = 'nobody',
  Integer[0,255]                           $os_level               = 20,
  Optional[Variant[Boolean, Enum['auto']]] $preferred_master       = undef,
  Hash                                     $global_options         = {},
  Hash                                     $shares                 = {},

  # SELinux options
  Boolean              $selinux_enable_home_dirs = false,
  Boolean              $selinux_export_all_rw    = false,

  Array $idmap_config = [],

  # # LDAP options
  # Optional[String]     $passdb_ldapsam_url       = undef,
  # Optional[Stdlib::Absolutepath] $passdb_tdbsam_path = undef,
  # Variant[String, Enum['off']]               $ldap_ssl                 = 'off',
  # Optional[String]               $ldap_admin_dn            = undef,
  # Optional[String]               $ldap_admin_dn_pwd        = undef,
  # String               $ldap_group_suffix        = undef,
  # String               $ldap_machine_suffix      = undef,
  # String               $ldap_user_suffix         = undef,
) {

  # Main package and service
  package { $packages:
    ensure => $version,
  }

  service { $services:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => File[$config_file],
  }

  if $manage_libwbclient {
    # sssd-libwbclient is required, see
    # https://github.com/sous-chefs/samba/issues/88
    package { $sssd_libwbclient_packages:
      ensure => 'present',
      before => Service[$services],
    }
  }

  if $manage_winbind {
    package { $winbind_packages:
      ensure => if $enable_winbind { 'present' },
    }

    service { 'winbind':
      ensure  => if $enable_winbind { 'running' } else { 'stopped' },
      name    => $winbind_services,
      enable  => $enable_winbind,
      require => if $enable_winbind {
        Package[$winbind_packages]
      },
      before  => Service[$services],
    }
  }

  file { $config_file:
    ensure  => 'file',
    require => Package[$packages],
    content => template('samba/smb.conf.erb'),
  }

  # if $ldap_admin_dn_pwd {
  #   package { 'tdb-tools' : ensure => 'installed' }

  #   exec { 'samba::server smbpasswd':
  #     command => "/usr/bin/smbpasswd -w \"${ldap_admin_dn_pwd}\"",
  #     unless  => "/usr/bin/tdbdump ${::samba::params::secretstdb} | /bin/grep -e '^data([0-9]\\+) = \"${ldap_admin_dn_pwd}\\\\00\"$'",
  #     require => [
  #       File[$::samba::params::config_file],
  #       Package['tdb-tools'],
  #     ],
  #     notify  => Service[$::samba::params::service],
  #   }
  # }

  if $facts['os']['selinux']['enabled'] {
    Selboolean { persistent => true, }

    if $selinux_enable_home_dirs {
      selboolean { 'samba_enable_home_dirs': value => 'on' }
    }

    if $selinux_export_all_rw {
      selboolean { 'samba_export_all_rw': value => 'on' }
    }
  }

}
