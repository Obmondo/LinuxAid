# @summary  manage a named set
#
# @example simple set
#  nftables::set{'my_set':
#    type       => 'ipv4_addr',
#    flags      => ['interval'],
#    elements   => ['192.168.0.1/24', '10.0.0.2'],
#    auto_merge => true,
#  }
#
# @param ensure should the set be created.
# @param setname name of set, equal to to title.
# @param order concat ordering.
# @param type type of set.
# @param table table or array of tables to add the set to.
# @param flags specify flags for set
# @param timeout timeout in seconds
# @param gc_interval garbage collection interval.
# @param elements initialize the set with some elements in it.
# @param size limits the maximum number of elements of the set.
# @param policy determines set selection policy.
# @param auto_merge automatically merge adjacent/overlapping set elements (only valid for interval sets)
# @param content specify content of set.
# @param source specify source of set.
define nftables::set (
  Enum['present','absent'] $ensure = 'present',
  Pattern[/^[-a-zA-Z0-9_]+$/] $setname = $title,
  Pattern[/^\d\d$/] $order = '10',
  Optional[Enum['ipv4_addr', 'ipv6_addr', 'ether_addr', 'inet_proto', 'inet_service', 'mark']] $type = undef,
  Variant[String, Array[String, 1]] $table = 'inet-filter',
  Array[Enum['constant', 'dynamic', 'interval', 'timeout'], 0, 4] $flags = [],
  Optional[Integer] $timeout = undef,
  Optional[Integer] $gc_interval = undef,
  Optional[Array[String]] $elements = undef,
  Optional[Integer] $size = undef,
  Optional[Enum['performance', 'memory']] $policy = undef,
  Boolean $auto_merge = false,
  Optional[String] $content = undef,
  Optional[Variant[String,Array[String,1]]] $source = undef,
) {
  if $size and $elements {
    if length($elements) > $size {
      fail("Max size of set ${setname} of ${size} is not being respected")
    }
  }

  $_tables = Array($table, true)

  if $ensure == 'present' {
    $_tables.each |Integer $index, String $_table| {
      concat::fragment {
        "nftables-${_table}-set-${setname}":
          order  => $order,
          target => "nftables-${_table}",
      }

      if $content {
        Concat::Fragment["nftables-${_table}-set-${setname}"] {
          content => "  ${content}",
        }
      } elsif $source {
        Concat::Fragment["nftables-${_table}-set-${setname}"] {
          source => $source,
        }
      } else {
        if $type == undef {
          fail('The way the resource is configured must have a type set')
        }
        Concat::Fragment["nftables-${_table}-set-${setname}"] {
          content => epp('nftables/set.epp',
            {
              'name'        => $setname,
              'type'        => $type,
              'flags'       => $flags,
              'timeout'     => $timeout,
              'gc_interval' => $gc_interval,
              'elements'    => $elements,
              'size'        => $size,
              'policy'      => $policy,
              'auto_merge'  => $auto_merge,
            }
          )
        }
      }
    }
  }
}
