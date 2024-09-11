# Declare an IP Set.
#
# @param set IP set content or source.
# @param ensure Should the IP set be created or removed ?
# @param type Type of IP set.
# @param options IP set options.
# @param ignore_contents If ``true``, only the IP set declaration will be
#   managed, but not its content.
# @param keep_in_sync If ``true``, Puppet will update the IP set in the kernel
#   memory. If ``false``, it will only update the IP sets on the filesystem.
#
# @example An IP set containing individual IP addresses, specified in the code.
#   ipset::set { 'a-few-ip-addresses':
#     set => ['10.0.0.1', '10.0.0.2', '10.0.0.42'],
#   }
#
# @example An IP set containing IP networks, specified with Hiera.
#   ipset::set { 'hiera-networks':
#     set  => lookup('foo', IP::Address::V4::CIDR),
#     type => 'hash:net',
#   }
#
# @example An IP set of IP addresses, based on a file stored in a module.
#   ipset::set { 'from-puppet-module':
#     set => "puppet:///modules/${module_name}/ip-addresses",
#   }
#
# @example An IP set of IP networks, based on a file stored on the filesystem.
#   ipset::set { 'from-filesystem':
#     set => 'file:///path/to/ip-addresses',
#   }
#
# @example setup multiple ipsets based on a hiera hash with multiple arrays and multiple IPv4/IPv6 prefixes. Use the voxpupuli/ferm module to create suitable iptables rules.
#   $ip_ranges = lookup('ip_net_vlans').flatten.unique
#   $ip_ranges_ipv4 = $ip_ranges.filter |$ip_range| { $ip_range =~ Stdlib::IP::Address::V4 }
#   $ip_ranges_ipv6 = $ip_ranges.filter |$ip_range| { $ip_range =~ Stdlib::IP::Address::V6 }
#
#   ipset::set{'v4':
#     ensure => 'present',
#     set    => $ip_ranges_ipv4,
#     type   => 'hash:net',
#   }
#
#   ipset::set{'v6':
#     ensure  => 'present',
#     set     => $ip_ranges_ipv6,
#     type    => 'hash:net',
#     options => {
#       'family' => 'inet6',
#     },
#   }
#
#   ferm::ipset{'INPUT':
#     ip_version => 'ip6',
#     sets       => {
#       'v6' => 'ACCEPT',
#     },
#   }
#
#   ferm::ipset{'INPUT':
#     ip_version => 'ip',
#     sets       => {
#       'v4' => 'ACCEPT',
#     },
#   }
#
define ipset::set (
  IPSet::Settype $set,
  Enum['present', 'absent'] $ensure = 'present',
  IPSet::Type $type = 'hash:ip',
  IPSet::Options $options = {},
  # do not touch what is inside the set, just its header (properties)
  Boolean $ignore_contents = false,
  # keep definition file and in-kernel runtime state in sync
  Boolean $keep_in_sync = true,
) {

  assert_type(String[1, 26], $title) |$expected, $actual| {
    fail("the title of an `ipset::set` needs to be 26 chars or less, but we got ${actual}")
  }

  include ipset

  $config_path = $ipset::config_path

  $default_options = {
    'family'   => 'inet',
    'hashsize' => '1024',
    'maxelem'  => '65536',
  }

  $actual_options = merge($default_options, $options)

  if $ensure == 'present' {
    # assert "present" target

    $opt_string = inline_template('<%= (@actual_options.sort.map { |k,v| k.to_s + " " + v.to_s }).join(" ") %>')

    # header
    file { "${config_path}/${title}.hdr":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => "create ${title} ${type} ${opt_string}\n",
      notify  => Exec["sync_ipset_${title}"],
    }

    # content
    case $set {
      IPSet::Set::Array: { # lint:ignore:unquoted_string_in_case
        $new_set = join($set, "\n")
        # create file with ipset, one record per line
        file { "${config_path}/${title}.set":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => "${new_set}\n",
        }
      }
      IPSet::Set::Puppet_URL: { # lint:ignore:unquoted_string_in_case
        # passed as puppet file
        file { "${config_path}/${title}.set":
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0640',
          source => $set,
        }
      }
      IPSet::Set::File_URL: { # lint:ignore:unquoted_string_in_case
        # passed as target node file
        file { "${config_path}/${title}.set":
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0640',
          source => regsubst($set, '^.{7}', ''),
        }
      }
      String: {
        # passed directly as content string (from template for example)
        file { "${config_path}/${title}.set":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => $set,
        }
      }
      default: {
        fail('Typing prevent reaching this branch')
      }
    }

    # add switch to script, if we
    if $ignore_contents {
      $ignore_contents_opt = ' -n'
    } else {
      $ignore_contents_opt = ''
    }

    # sync if needed by helper script
    exec { "sync_ipset_${title}":
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin', '/usr/local/bin', '/usr/local/sbin' ],
      # use helper script to do the sync
      command => "ipset_sync -c '${config_path}'    -i ${title}${ignore_contents_opt}",
      # only when difference with in-kernel set is detected
      unless  => "ipset_sync -c '${config_path}' -d -i ${title}${ignore_contents_opt}",
      require => Package['ipset'],
    }

    if $keep_in_sync {
      File["${config_path}/${title}.set"] ~> Exec["sync_ipset_${title}"]
    }
  } elsif $ensure == 'absent' {
    # ensuring absence

    # do not contain config files
    file { ["${config_path}/${title}.set", "${config_path}/${title}.hdr"]:
      ensure  => absent,
    }

    # clear ipset from kernel
    exec { "ipset destroy ${title}":
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      command => "ipset destroy ${title}",
      onlyif  => "ipset list ${title}",
      require => Package['ipset'],
    }
  } else {
    fail('Typing prevent reaching this branch')
  }
}
