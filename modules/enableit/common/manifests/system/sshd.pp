# Common SSHD module
class common::system::sshd (
  Boolean                                $manage                  = false,
  Variant[Boolean, Enum['no-noop']]      $distribute_hostkeys     = false,
  Eit_types::Package::Version::Installed $version                 = 'latest',
  Array[Stdlib::Port]                    $ports                   = [22],
  Array[Eit_types::IPPort]               $listenaddresses         = [],
  Boolean                                $managed_users_only      = true,
  Boolean                                $compression             = true,
  Boolean                                $password_authentication = false,
  Boolean                                $tcp_forwarding          = true,
  Boolean                                $permit_user_rc          = true,
  Integer[0,default]                     $max_auth_tries          = 4,
  Integer[0,default]                     $max_sessions            = 10,
  Integer[0,default]                     $login_grace_time        = 30,

  Array[Stdlib::Absolutepath] $hostkeys     = [
    '/etc/ssh/ssh_host_ed25519_key',
    '/etc/ssh/ssh_host_rsa_key',
    '/etc/ssh/ssh_host_ecdsa_key',
  ],

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
  ] $log_level = 'VERBOSE',

  Array[Eit_types::Ssh::Kexalgorithms] $kexalgorithms = [
    'curve25519-sha256@libssh.org',
    'ecdh-sha2-nistp521',
    'ecdh-sha2-nistp384',
    'ecdh-sha2-nistp256',
    'diffie-hellman-group-exchange-sha256',
  ],

  Array[Eit_types::Ssh::Ciphers] $ciphers = [
    'chacha20-poly1305@openssh.com',
    'aes256-gcm@openssh.com',
    'aes128-gcm@openssh.com',
    'aes256-ctr',
    'aes192-ctr',
    'aes128-ctr',
  ],

  Array[Eit_types::Ssh::Macs] $macs = [
    'hmac-sha2-512-etm@openssh.com',
    'hmac-sha2-256-etm@openssh.com',
    'umac-128-etm@openssh.com',
    'hmac-sha2-512',
    'hmac-sha2-256',
    'umac-128@openssh.com',
  ],

  Hash[Eit_types::SimpleString, String] $subsystems = {
    'sftp' => '/usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO',
  },

  Variant[
    Boolean,
    Enum['forced-commands-only', 'prohibit-password']
  ] $permit_root_login                     = 'forced-commands-only',

  Boolean $x11_forwarding    = false,
  Boolean $x11_use_localhost = true,
  Hash    $client_options = {
    'Host *' => {
      'HashKnownHosts' => true,
      'SendEnv'        => 'LANG LC_*',
    },
  },

  Array[String] $accept_env = [
    'LANG',
    'LC_*',
  ],
  Hash[String, Hash[String, Any]] $match = {},
) inherits common::system {

  if $manage {
    include ::profile::system::sshd
  }
}
