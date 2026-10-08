# @summary Provides an interface to create a firewall rule
#
# @example add a rule named 'myhttp' to the 'default_in' chain to allow incoming traffic to TCP port 80
#  nftables::rule {
#    'default_in-myhttp':
#      content => 'tcp dport 80 accept',
#  }
#
# @example add a rule named 'count' to the 'PREROUTING6' chain in table 'ip6 nat' to count traffic
#  nftables::rule {
#    'PREROUTING6-count':
#      content => 'counter',
#      table   => 'ip6-nat'
#  }
#
# @example Redirect port 443 to port 8443
#  nftables::rule { 'PREROUTING-redirect':
#    content => 'tcp dport 443 redirect to :8443',
#    table   => 'ip-nat',
#  }
#  nftables::rule{'PREROUTING6-redirect':
#    content => 'tcp dport 443 redirect to :8443',
#    table   => 'ip6-nat',
#  }
#
# @param ensure
#   Should the rule be created.
#
# @param rulename
#   The symbolic name for the rule and to what chain to add it. The
#   format is defined by the Nftables::RuleName type.
#
# @param order
#   A number representing the order of the rule.
#
# @param table
#   The name of the table to add this rule to.
#
# @param content
#   The raw statements that compose the rule represented using the nftables
#   language.
#
# @param source
#   Same goal as content but sourcing the value from a file.
define nftables::rule (
  Enum['present','absent'] $ensure = 'present',
  Nftables::RuleName $rulename = $title,
  Pattern[/^\d\d$/] $order = '50',
  String $table = 'inet-filter',
  Optional[String] $content = undef,
  Optional[Variant[String,Array[String,1]]] $source = undef,
) {
  if $ensure == 'present' {
    $data = split($rulename, '-')

    if $data[2] {
      $fragment = "nftables-${table}-chain-${data[0]}-rule-${data[1]}-${data[2]}"
    } else {
      $fragment = "nftables-${table}-chain-${data[0]}-rule-${data[1]}"
    }

    concat::fragment { "${fragment}_header":
      content => "#   Start of fragment order:${order} rulename:${rulename}",
      order   => "${order}-${fragment}-a",
      target  => "nftables-${table}-chain-${data[0]}",
    }

    concat::fragment {
      $fragment:
        order  => "${order}-${fragment}-b",
        target => "nftables-${table}-chain-${data[0]}",
    }

    if $content {
      Concat::Fragment[$fragment] {
        content => "  ${content}",
      }
    } else {
      Concat::Fragment[$fragment] {
        source => $source,
      }
    }
  }
}
