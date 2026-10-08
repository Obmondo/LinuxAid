# disable outgoing ssh
class nftables::rules::out::ssh::remove inherits nftables::rules::out::ssh {
  Nftables::Rule['default_out-ssh'] {
    ensure => absent,
  }
}
