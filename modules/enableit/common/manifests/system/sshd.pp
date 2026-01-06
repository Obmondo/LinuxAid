# @summary Class for managing the common SSHD configuration
#
# @param manage Whether to manage the sshd configuration. Defaults to false.
#
# @param distribute_hostkeys Whether to distribute host keys. Defaults to false.
#
# @param version The version of the SSHD package to ensure is installed. Defaults to 'latest'.
#
# @param ports Array of ports for SSHD to listen on. Defaults to [22].
#
# @param listenaddresses Array of addresses SSHD should listen on. Defaults to empty array.
#
# @param managed_users_only Restrict SSHD to manage only specified users. Defaults to true.
#
# @param compression Enable compression. Defaults to true.
#
# @param password_authentication Enable password authentication. Defaults to false.
#
# @param tcp_forwarding Enable TCP forwarding. Defaults to true.
#
# @param permit_user_rc Permit user rc files. Defaults to true.
#
# @param max_auth_tries Maximum authentication attempts. Defaults to 4.
#
# @param max_sessions Maximum sessions. Defaults to 10.
#
# @param login_grace_time Login grace time in seconds. Defaults to 30.
#
# @param hostkeys Array of host key file paths. Defaults to ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key', '/etc/ssh/ssh_host_ecdsa_key'].
#
# @param log_level Logging level. Defaults to 'VERBOSE'.
#
# @param kexalgorithms Array of key exchange algorithms. Defaults include 'curve25519-sha256@libssh.org', 'ecdh-sha2-nistp521', etc.
#
# @param ciphers Array of cipher algorithms. Defaults include 'chacha20-poly1305@openssh.com', 'aes256-gcm@openssh.com', etc.
#
# @param macs Array of MAC algorithms. Defaults include 'hmac-sha2-512-etm@openssh.com', 'hmac-sha2-256-etm@openssh.com', etc.
#
# @param subsystems Hash of subsystem commands. Defaults to {'sftp' => '/usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO'}.
#
# @param permit_root_login Root login permission. Defaults to 'forced-commands-only'.
#
# @param x11_forwarding Enable X11 forwarding. Defaults to false.
#
# @param x11_use_localhost Use localhost for X11 forwarding. Defaults to true.
#
# @param client_options Hash of client options. Defaults to {'Host *' => {'HashKnownHosts' => true, 'SendEnv' => 'LANG LC_*'}}.
#
# @param accept_env Array of accepted environment variables. Defaults to ['LANG', 'LC_*'].
#
# @param match Hash of match conditions. Defaults to empty hash.
#
# @groups management manage, distribute_hostkeys, managed_users_only, permit_root_login
#
# @groups network ports, listenaddresses, tcp_forwarding, x11_forwarding, x11_use_localhost
#
# @groups security compression, password_authentication, max_auth_tries, max_sessions, login_grace_time
#
# @groups config version, log_level, client_options, accept_env, match
#
# @groups crypto hostkeys, kexalgorithms, ciphers, macs
#
# @groups subsystems subsystems, permit_user_rc
#
class common::system::sshd (
  Boolean                                $manage                  = false,
  Variant[Boolean, Enum['no-noop']]     $distribute_hostkeys     = false,
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
