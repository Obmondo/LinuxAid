#
class profile::system::sshd (
  Boolean                                $manage                  = $common::system::sshd::manage,
  Variant[Boolean, Enum['no-noop']]      $distribute_hostkeys     = $common::system::sshd::distribute_hostkeys,
  Eit_types::Package::Version::Installed $version                 = $common::system::sshd::version,
  Array[Stdlib::Port]                    $ports                   = $common::system::sshd::ports,
  Array[Eit_types::IPPort]               $listenaddresses         = $common::system::sshd::listenaddresses,
  Boolean                                $managed_users_only      = $common::system::sshd::managed_users_only,
  Boolean                                $compression             = $common::system::sshd::compression,
  Boolean                                $password_authentication = $common::system::sshd::password_authentication,
  Boolean                                $tcp_forwarding          = $common::system::sshd::tcp_forwarding,
  Boolean                                $permit_user_rc          = $common::system::sshd::permit_user_rc,
  Integer[0,default]                     $max_auth_tries          = $common::system::sshd::max_auth_tries,
  Integer[0,default]                     $max_sessions            = $common::system::sshd::max_sessions,
  Integer[0,default]                     $login_grace_time        = $common::system::sshd::login_grace_time,

  Array[Stdlib::Absolutepath] $hostkeys                = $common::system::sshd::hostkeys,
  Enum[
    'QUIET',
    'FATAL',
    'ERROR',
    'INFO',
    'VERBOSE',
    'DEBUG',
    'DEBUG1',
    'DEBUG2',
    'DEBUG3'
  ] $log_level                                         = $common::system::sshd::log_level,

  Array[Eit_types::Ssh::Kexalgorithms] $kexalgorithms  = $common::system::sshd::kexalgorithms,
  Array[Eit_types::Ssh::Ciphers]       $ciphers        = $common::system::sshd::ciphers,
  Array[Eit_types::Ssh::Macs]          $macs           = $common::system::sshd::macs,

  Hash[Eit_types::SimpleString, String]
  $subsystems                          = $common::system::sshd::subsystems,

  Variant[
    Boolean,
    Enum['forced-commands-only', 'prohibit-password']
  ] $permit_root_login                     = $common::system::sshd::permit_root_login,

  Boolean $x11_forwarding    = $common::system::sshd::x11_forwarding,
  Boolean $x11_use_localhost = $common::system::sshd::x11_use_localhost,
  Hash    $client_options    = $common::system::sshd::client_options,

  Array[String]                      $accept_env = $common::system::sshd::accept_env,
  Hash[String, Hash[String, Any]] $match      = $common::system::sshd::match,
) {

  File { '/etc/ssh/sshd_config' :
    noop => false,
  }

  if $manage {

    $_semver_version = case $facts['ssh_server_version_full'] {
      /^(\d\.\d\.\d).+/: {
        regsubst(
          $facts['ssh_server_version_full'],
          '^(\d\.\d\.\d).+',
          '\1')
      }
      /^(\d\.\d).+/: {
        regsubst(
          $facts['ssh_server_version_full'],
          '^(\d\.\d).+',
          '\1.0')
      }
      undef: {
        # Use a low version number to make sure the sshd actually comes up
        '5.0.0'
      }
      default: {
        fail('Sorry not sure what to do')
      }
    }
    $_ssh_version = SemVer($_semver_version)

    $_version_specific_settings = {
      SemVer('5.0.0') => {
        'UsePrivilegeSeparation' => 'yes',
      },
      SemVer('6.7.0') => {
        'PermitUserRC' => to_yesno($permit_user_rc),
      },
      SemVer('7.2.0') => {
        'UsePrivilegeSeparation' => 'sandbox',
      },
      SemVer('7.5.0') => {
        'UsePrivilegeSeparation' => undef,
      },
    }

    $_settings = $_version_specific_settings.reduce({}) |$acc, $x| {
      [$version, $values] = $x
      if $_ssh_version >= $version {
        merge($acc, $values)
      } else {
        $acc
      }
    }

    $_subsystems = $subsystems.reduce([]) |$acc, $_ss| {
      [$subsystem_name, $subsystem_arguments] = $_ss

      [] + ["${subsystem_name} ${subsystem_arguments}"]
    }

    $default_settings = [
      {
        'AllowTcpForwarding'      => to_yesno($tcp_forwarding),
        'Ciphers'                 => join($ciphers, ','),
        'Compression'             => to_yesno($compression),
        'HostbasedAuthentication' => 'no',
        'HostKey'                 => $hostkeys,
        'ListenAddress'           => $listenaddresses,
        'LoginGraceTime'          => $login_grace_time,
        # `LogLevel` should be `VERBOSE` or above to log key fingerprints
        'LogLevel'                => $log_level,
        'MACs'                    => join($macs, ','),
        'MaxAuthTries'            => $max_auth_tries,
        'PasswordAuthentication'  => to_yesno($password_authentication),
        'PermitRootLogin'         => $permit_root_login,
        'Port'                    => $ports,
        'PrintLastLog'            => 'yes',
        'PrintMotd'               => 'yes',
        'Protocol'                => '2',
        'PubkeyAuthentication'    => 'yes',
        'StrictModes'             => 'yes',
        'Subsystem'               => $_subsystems,
        'TCPKeepAlive'            => 'yes',
        'UseDNS'                  => 'yes',
        'X11Forwarding'           => to_yesno($x11_forwarding),
        'X11UseLocalhost'         => to_yesno($x11_use_localhost),
      },
      if $kexalgorithms.size {
        {
          'KexAlgorithms' => join($kexalgorithms, ','),
        }
      },
    ].delete_undef_values.merge_hashes

    $_client_options = deep_merge($client_options, {
        'Host *' => {
          'ForwardX11' => to_yesno($x11_forwarding),
        },
    }).reduce({}) |$acc, $x| {
      [$k, $v] = $x

      $_coerced_x = {
        $k => profile::ssh_config_value($v),
      }

      $acc.merge($_coerced_x)
    }

    class { 'ssh':
      version              => $version,
      storeconfigs_enabled => false,
      client_options       => $_client_options,
      server_options       => [
        $default_settings,
        $_settings,
        if $accept_env.count {
          { 'AcceptEnv' => $accept_env.join(' '), }
        },
        $match.filter |$_k, $_v| {
          $_k !~ /^!!/
        }.map |$_conditional, $_config| {
          {
            "Match ${_conditional}" => $_config.map |$_config_item| {
              [$_config_name, $_config_value] = $_config_item
              # Prefix with spaces so it looks nice when rendered
              "  ${_config_name} ${_config_value.profile::ssh_config_value}"
            }.join("\n").then |$x| {"\n${x}"}
          }
        }.merge_hashes,
      ].delete_undef_values.merge_hashes,
    }

    if $distribute_hostkeys {
      Sshkey {
        noop => !($distribute_hostkeys == 'no-noop'),
      }

      class { 'ssh::hostkeys':
        exclude_interfaces => [
          'docker0',
        ],
        export_ipaddresses => true,
        storeconfigs_group => $::obmondo['customer_id'],
      }

      class { 'ssh::knownhosts':
        collect_enabled    => true,
        storeconfigs_group => $::obmondo['customer_id'],
      }
    }
  }
}

# Additional settings we might want in the future:
#      'AcceptEnv'                       => ,
#      'AddressFamily'                   => ,
#      'AllowAgentForwarding'            => ,
#      'AllowGroups'                     => ,
#      'AllowStreamLocalForwarding'      => ,
#      'AllowTcpForwarding'              => ,
#      'AllowUsers'                      => ,
#      'AuthenticationMethods'           => ,
#      'AuthorizedKeysCommand'           => ,
#      'AuthorizedKeysCommandUser'       => ,
#      'AuthorizedKeysFile'              => ,
#      'AuthorizedPrincipalsCommand'     => ,
#      'AuthorizedPrincipalsCommandUser' => ,
#      'AuthorizedPrincipalsFile'        => ,
#      'Banner'                          => ,
#      'ChallengeResponseAuthentication' => ,
#      'ChrootDirectory'                 => ,
#      'Ciphers'                         => ,
#      'ClientAliveCountMax'             => ,
#      'ClientAliveInterval'             => ,
#      'Compression'                     => ,
#      'DebianBanner'                    => ,
#      'DenyGroups'                      => ,
#      'DenyUsers'                       => ,
#      'DisableForwarding'               => ,
#      'FingerprintHash'                 => ,
#      'ForceCommand'                    => ,
#      'GSSAPIAuthentication'            => ,
#      'GSSAPICleanupCredentials'        => ,
#      'GSSAPIKeyExchange'               => ,
#      'GSSAPIStoreCredentialsOnRekey'   => ,
#      'GSSAPIStrictAcceptorCheck'       => ,
#      'GatewayPorts'                    => ,
#      'HostCertificate'                 => ,
#      'HostKey'                         => ,
#      'HostKeyAgent'                    => ,
#      'HostKeyAlgorithms'               => ,
#      'HostbasedAcceptedKeyTypes'       => ,
#      'HostbasedAuthentication'         => ,
#      'HostbasedUsesNameFromPacketOnly' => ,
#      'IPQoS'                           => ,
#      'IgnoreRhosts'                    => ,
#      'IgnoreUserKnownHosts'            => ,
#      'KbdInteractiveAuthentication'    => ,
#      'KerberosAuthentication'          => ,
#      'KerberosGetAFSToken'             => ,
#      'KerberosOrLocalPasswd'           => ,
#      'KerberosTicketCleanup'           => ,
#      'KexAlgorithms'                   => ,
#      'ListenAddress'                   => ,
#      'LogLevel'                        => ,
#      'LoginGraceTime'                  => ,
#      'MACs'                            => ,
#      'MaxAuthTries'                    => ,
#      'MaxSessions'                     => ,
#      'MaxStartups'                     => ,
#      'PasswordAuthentication'          => ,
#      'PermitEmptyPasswords'            => ,
#      'PermitOpen'                      => ,
#      'PermitTTY'                       => ,
#      'PermitTunnel'                    => ,
#      'PermitUserEnvironment'           => ,
#      'PermitUserRC'                    => ,
#      'PidFile'                         => ,
#      'Port'                            => ,
#      'PrintLastLog'                    => ,
#      'PrintMotd'                       => ,
#      'PubkeyAcceptedKeyTypes'          => ,
#      'PubkeyAuthentication'            => ,
#      'RekeyLimit'                      => ,
#      'RevokedKeys'                     => ,
#      'StreamLocalBindMask'             => ,
#      'StreamLocalBindUnlink'           => ,
#      'Subsystem'                       => ,
#      'SyslogFacility'                  => ,
#      'TCPKeepAlive'                    => ,
#      'TrustedUserCAKeys'               => ,
#      'UseDNS'                          => ,
#      'UsePAM'                          => ,
#      'UsePrivilegeSeparation'          => ,
#      'VersionAddendum'                 => ,
#      'X11DisplayOffset'                => ,
#      'X11Forwarding'                   => ,
#      'X11UseLocalhost'                 => ,
#      'XAuthLocation'                   => ,
