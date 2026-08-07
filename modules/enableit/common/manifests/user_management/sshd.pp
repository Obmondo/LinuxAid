# @summary Class for managing the common SSHD configuration
#
# @param manage Whether to manage the sshd configuration. Defaults to false.
#
# @param distribute_hostkeys Whether to distribute host keys. Defaults to false.
#
# @param managed_users_only Restrict SSHD to manage only specified users. Defaults to true.
#
# @param password_authentication Enable password authentication. Defaults to false.
#
# @param hostkeys Array of host key file paths.
# Defaults to ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key', '/etc/ssh/ssh_host_ecdsa_key'].
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
# @param match Hash of match conditions. Defaults to empty hash.
#
# @groups management manage, distribute_hostkeys, managed_users_only, permit_root_login
#
# @groups network x11_forwarding, x11_use_localhost
#
# @groups security password_authentication
#
# @groups config client_options, match
#
# @groups crypto hostkeys, kexalgorithms, ciphers, macs
#
# @groups subsystems subsystems
#
class common::user_management::sshd (
  Boolean                                $manage                  = false,
  Variant[Boolean, Enum['no-noop']]      $distribute_hostkeys     = false,
  Boolean                                $managed_users_only      = true,
  Boolean                                $password_authentication = false,

  Array[Stdlib::Absolutepath] $hostkeys     = [
    '/etc/ssh/ssh_host_ed25519_key',
    '/etc/ssh/ssh_host_rsa_key',
    '/etc/ssh/ssh_host_ecdsa_key',
  ],
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
  Hash[String, Hash[String, Any]] $match = {},
) inherits common::system {
  if $manage {
    include ::profile::system::sshd
  }
}
