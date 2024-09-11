# samba shares
class profile::storage::samba (
  String                            $workgroup         = $::common::storage::samba::workgroup,
  String                            $server_string     = $::common::storage::samba::server_string,
  Enum['ADS']                       $security          = $::common::storage::samba::security,
  Boolean                           $local_master      = $::common::storage::samba::local_master,
  Boolean                           $domain_master     = $::common::storage::samba::domain_master,
  Boolean                           $preferred_master  = $::common::storage::samba::preferred_master,
  Eit_types::Domain                 $realm             = $::common::storage::samba::realm,
  Boolean                           $load_printers     = $::common::storage::samba::load_printers,
  Optional[Stdlib::Absolutepath]    $printcap_name     = $::common::storage::samba::printcap_name,
  Enum['system keytab']             $kerberos_method   = $::common::storage::samba::kerberos_method,
  Eit_types::Storage::Samba::Shares $shares            = $::common::storage::samba::shares,
  Array[String]                     $listen_interfaces = $::common::storage::samba::listen_interfaces,
  Boolean                           $override_dfree    = $::common::storage::samba::override_dfree,

  Array $idmap_config = $::common::storage::samba::idmap_config,

) {

  # NOTE: I'm not sure which Debian/Ubuntu uses wbclient over winbind, so this
  # might not work
  $_use_wbclient_over_winbind = (
    $security == 'ADS'
    and $facts.dig('os', 'family') != 'RedHat'
    or ($facts.dig('os', 'family') == 'RedHat'
        and Integer($facts.dig('os', 'release', 'major')) > 6))

  if $security == 'ADS' and $kerberos_method == 'system keytab' {
    Class['realmd']->Class['samba::server']
  }

  # Convert the booleans to yes/no
  $_shares = $shares.reduce({}) |$acc, $_x| {
    [$_name, $_config] = $_x

    $_config_array = $_config.reduce([]) |$acc, $_option| {
      [$_option_name, $_option_value] = $_option
      $_option_value_formatted = $_option_value ? {
        Array   => $_option_value.join(' '),
        Boolean => to_yesno($_option_value),
        default => $_option_value,
      }
      $_spacified_option_name = regsubst($_option_name, '_', ' ', 'G')
      $acc + "${_spacified_option_name} = ${_option_value_formatted}"
    }

    $acc + {$_name => $_config_array}
  }

  if $override_dfree {
    include ::samba::params

    file { '/usr/local/share/samba':
      ensure => 'directory',
    }

    file { '/usr/local/share/samba/dfree.sh':
      ensure  => 'file',
      source  => 'puppet:///modules/profile/storage/samba/dfree.sh',
      mode    => 'a+x',
      require => File['/usr/local/share/samba'],
      before  => Service[$::samba::params::service],
    }
  }

  class { '::samba::server':
    workgroup          => $workgroup,
    server_string      => $server_string,
    security           => $security,
    local_master       => $local_master,
    domain_master      => $domain_master,
    preferred_master   => $preferred_master,
    realm              => $realm,
    load_printers      => $load_printers,
    printcap_name      => pick($printcap_name, '/dev/null'),
    manage_winbind     => !$_use_wbclient_over_winbind,
    manage_libwbclient => $_use_wbclient_over_winbind,
    global_options     => {
      'kerberos method' => $kerberos_method,
    } + if $override_dfree {
      {
        'dfree command' => '/usr/local/share/samba/dfree.sh',
      }
    }.delete_undef_values,
    shares             => $_shares,
    idmap_config       => $idmap_config,
    interfaces         => $listen_interfaces,
    require            => Class['common::network'],
  }

  firewall_multi {
    default:
      jump    => 'accept',
      # iniface => $_interfaces,
      ;

    '000 samba netbios-ssn':
      proto => 'tcp',
      dport => 139,
      ;

    '000 samba direct':
      proto => ['tcp', 'udp'],
      dport => 445,
      ;
  }


  # class { '::samba::server':
  #   workgroup            => 'HEARING',
  #   server_string        => 'shares',
  #   security             => 'ADS',
  #   local_master         => 'no',
  #   domain_master        => 'no',
  #   preferred_master     => 'no',
  #   realm                => $realm,
  #   load_printers        => 'no',
  #   printcap             => '/dev/null',
  #   extra_global_options => ['kerberos method = system keytab'],
  #   shares               => {
  #     'test' => [
  #       'comment     = Test share',
  #       'path        = /tmp',
  #       'create mask = 0777',
  #       'force create mode = 0777',
  #       'directory mask = 00777',
  #       'force directory mode = 00777',
  #       'public      = no',
  #       'writeable   = yes',
  #       'guest ok    = no',
  #       'browseable  = yes',
  #       # 'valid users = @"OF-US-Drev-KEjd-WeDo@of.kk.dk"',
  #     ],
  #   },
  # }

}
