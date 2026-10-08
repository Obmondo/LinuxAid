# @summary Configure nftables
#
# @example allow dns out and do not allow ntp out
#   class{ 'nftables':
#     out_ntp => false,
#     out_dns => true,
#   }
#
# @example do not flush particular tables, fail2ban in this case
#   class{ 'nftables':
#     noflush_tables => ['inet-f2b-table'],
#   }
#
# @param out_all
#   Allow all outbound connections. If `true` then all other
#   out parameters `out_ntp`, `out_dns`, ... will be assuemed
#   false.
#
# @param out_ntp
#   Allow outbound to ntp servers.
#
# @param out_http
#   Allow outbound to http servers.
#
# @param out_dns
#   Allow outbound to dns servers.
#
# @param out_https
#   Allow outbound to https servers.
#
# @param out_icmp
#   Allow outbound ICMPv4/v6 traffic.
#
# @param in_ssh
#   Allow inbound to ssh servers.
#
# @param in_icmp
#   Allow inbound ICMPv4/v6 traffic.
#
# @param inet_filter
#   Add default tables, chains and rules to process traffic.
#
# @param nat
#   Add default tables and chains to process NAT traffic.
#
# @param nat_table_name
#   The name of the 'nat' table.
#
# @param purge_unmanaged_rules
#   Prohibits in-memory rules that are not declared in Puppet
#   code. Setting this to true activates a check that reloads nftables
#   if the rules in memory have been modified without Puppet.
#
# @param inmem_rules_hash_file
#   The name of the file where the hash of the in-memory rules
#   will be stored.
#
# @param chains
#   Allows sourcing chain definitions directly from Hiera.
#
# @param sets
#   Allows sourcing set definitions directly from Hiera.
#
# @param rules
#   Specify hashes of `nftables::rule`s via hiera
#
# @param log_prefix
#   String that will be used as prefix when logging packets. It can contain
#   two variables using standard sprintf() string-formatting:
#    * chain: Will be replaced by the name of the chain.
#    * comment: Allows chains to add extra comments.
#
# @param log_discarded
#   Allow to log discarded packets
#
# @param log_limit
#  String with the content of a limit statement to be applied
#  to the rules that log discarded traffic. Set to false to
#  disable rate limiting.
#
# @param log_group
#  When specified, the Linux kernel will pass the packet to nfnetlink_log
#  which will send the log through a netlink socket to the specified group.
#
# @param reject_with
#   How to discard packets not matching any rule. If `false`, the
#   fate of the packet will be defined by the chain policy (normally
#   drop), otherwise the packet will be rejected with the REJECT_WITH
#   policy indicated by the value of this parameter.
#
# @param in_out_conntrack
#   Adds INPUT and OUTPUT rules to allow traffic that's part of an
#   established connection and also to drop invalid packets.
#
# @param in_out_drop_invalid
#   Drops invalid packets in INPUT and OUTPUT
#
# @param fwd_conntrack
#   Adds FORWARD rules to allow traffic that's part of an
#   established connection and also to drop invalid packets.
#
# @param fwd_drop_invalid
#   Drops invalid packets in FORWARD
#
# @param firewalld_enable
#   Configures how the firewalld systemd service unit is enabled. It might be
#   useful to set this to false if you're externaly removing firewalld from
#   the system completely.
#
# @param noflush_tables
#   If specified only other existings tables will be flushed.
#   If left unset all tables will be flushed via a `flush ruleset`
#
#   This only governs the flush performed inside the module's own config. It
#   has no effect on a `flush ruleset` present in the OS provided
#   `configuration_path`; set `clobber_default_config` to `true` to remove
#   that. See `clobber_default_config` for details.
#
# @param configuration_path
#   The absolute path to the principal nftables configuration file. The default
#   varies depending on the system, and is set in the module's data.
#
# @param nft_path
#   Path to the nft binary
#
# @param echo
#   Path to the echo binary
#
# @param default_config_mode
#   The default file & dir mode for configuration files and directories. The
#   default varies depending on the system, and is set in the module's data.
#
# @param clobber_default_config
#   Should the existing OS provided rules in the `configuration_path` be removed? If
#   they are not being removed this module will add all of its configuration to the end of
#   the existing rules.
#
class nftables (
  Stdlib::Unixpath $echo,
  Stdlib::Unixpath $configuration_path,
  Stdlib::Unixpath $nft_path,
  Stdlib::Filemode $default_config_mode,
  Boolean $clobber_default_config = false,
  Boolean $in_ssh = true,
  Boolean $in_icmp = true,
  Boolean $out_ntp = true,
  Boolean $out_dns = true,
  Boolean $out_http = true,
  Boolean $out_https = true,
  Boolean $out_icmp = true,
  Boolean $out_all = false,
  Boolean $in_out_conntrack = true,
  Boolean $in_out_drop_invalid = $in_out_conntrack,
  Boolean $fwd_conntrack = false,
  Boolean $fwd_drop_invalid = $fwd_conntrack,
  Boolean $inet_filter = true,
  Boolean $nat = true,
  Boolean $purge_unmanaged_rules = false,
  Hash $chains = {},
  Hash $rules = {},
  Hash $sets = {},
  String $log_prefix = '[nftables] %<chain>s %<comment>s',
  Optional[Integer[0]] $log_group = undef,
  String[1] $nat_table_name = 'nat',
  Stdlib::Unixpath $inmem_rules_hash_file = '/var/tmp/puppet-nft-memhash',
  Boolean $log_discarded = true,
  Variant[Boolean[false], String] $log_limit = '3/minute burst 5 packets',
  Variant[Boolean[false], Pattern[/icmp(v6|x)? type .+|tcp reset/]] $reject_with = 'icmpx type port-unreachable',
  Variant[Boolean[false], Enum['mask']] $firewalld_enable = 'mask',
  Optional[Array[Pattern[/^(ip|ip6|inet|arp|bridge|netdev)-[-a-zA-Z0-9_]+$/],1]] $noflush_tables = undef,
) {
  package { 'nftables':
    ensure => installed,
  }

  # /etc/services file is needed, on newer OSes this is a dependency on nftables
  if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '20.04' {
    package { 'netbase':
      ensure => present,
    }
  }

  if $clobber_default_config {
    file { $configuration_path:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => $default_config_mode,
      content => "#Puppet Managed\ninclude \"/etc/nftables/puppet.nft\"\n",
      require => Package['nftables'],
      before  => File['/etc/nftables'],
      notify  => Service['nftables'],
    }
  } else {
    file_line { 'enable_nftables':
      line    => 'include "/etc/nftables/puppet.nft"',
      path    => $configuration_path,
      require => Package['nftables'],
      before  => File['/etc/nftables'],
      notify  => Service['nftables'],
    }
  }

  file {
    default:
      owner => 'root',
      group => 'root',
      mode  => $default_config_mode;
    '/etc/nftables':
      ensure => directory,
      mode   => $default_config_mode;
    '/etc/nftables/puppet-preflight':
      ensure  => directory,
      mode    => $default_config_mode,
      purge   => true,
      force   => true,
      recurse => true;
    '/etc/nftables/puppet-preflight.nft':
      ensure  => file,
      content => epp('nftables/config/puppet.nft.epp', {
          'inet_filter' => $inet_filter,
          'nat'         => $nat,
          'noflush'     => $noflush_tables
        }
      );
  } ~> exec {
    'nft validate':
      refreshonly => true,
      command     => "${nft_path} -I /etc/nftables/puppet-preflight -c -f /etc/nftables/puppet-preflight.nft || ( ${echo} '#CONFIG BROKEN' >> /etc/nftables/puppet-preflight.nft && /bin/false)"; # lint:ignore:check_unsafe_interpolations
  } -> file {
    default:
      owner => 'root',
      group => 'root',
      mode  => $default_config_mode;
    '/etc/nftables/puppet.nft':
      ensure  => file,
      content => epp('nftables/config/puppet.nft.epp', {
          'inet_filter' => $inet_filter,
          'nat'         => $nat,
          'noflush'     => $noflush_tables
        }
      );
    '/etc/nftables/puppet':
      ensure  => directory,
      mode    => $default_config_mode,
      purge   => true,
      force   => true,
      recurse => true;
  } ~> service { 'nftables':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    restart    => 'PATH=/usr/bin:/bin systemctl reload nftables',
  }

  if $purge_unmanaged_rules {
    # Reload nftables ruleset from disk if running state not match last service change hash, or is absent (-s required to ignore counters)
    exec { 'nftables_memory_state_check':
      command  => ['echo', 'reloading_nftables'],
      path     => $facts['path'],
      provider => shell,
      unless   => ["test -s ${inmem_rules_hash_file} -a \"$(nft -s list ruleset | sha1sum)\" = \"$(cat ${inmem_rules_hash_file})\""],
      notify   => Service['nftables'],
    }

    # Generate nftables hash upon changes to the nftables service
    exec { 'nftables_generate_hash':
      command     => ["nft -s list ruleset | sha1sum > ${inmem_rules_hash_file}"],
      path        => $facts['path'],
      provider    => shell,
      subscribe   => Service['nftables'],
      refreshonly => true,
    }
  }

  systemd::dropin_file { 'puppet_nft.conf':
    ensure  => present,
    unit    => 'nftables.service',
    content => epp('nftables/systemd/puppet_nft.conf.epp',
      {
        'configuration_path' => $configuration_path,
        'nft_path'           => $nft_path,
      },
    ),
    notify  => Service['nftables'],
  }

  # firewalld.enable can be mask or false depending upon if firewalld is installed or not
  # https://tickets.puppetlabs.com/browse/PUP-10814
  service { 'firewalld':
    ensure => stopped,
    enable => $firewalld_enable,
  }

  if $inet_filter {
    include nftables::inet_filter
  }

  if $nat {
    include nftables::ip_nat
  }

  # inject custom chains e.g. from hiera
  $chains.each |$n,$v| {
    nftables::chain {
      $n:
        * => $v,
    }
  }

  # inject custom rules e.g. from hiera
  $rules.each |$n,$v| {
    nftables::rule {
      $n:
        * => $v,
    }
  }

  # inject custom sets e.g. from hiera
  $sets.each |$n,$v| {
    nftables::set {
      $n:
        * => $v,
    }
  }
}
