# A defined type to be used as a macro for setting host based firewall
# rules.  This is not intended to be used by a user (who should use the
# API provided by cassandra::firewall_ports instead) but is documented
# here for completeness.
# @param ports [integer] The number(s) of the port(s) to be opened.
define cassandra::private::firewall_ports::rule (
  $ports,
) {
  $array_var1 = split($title, '_')
  $rule_number = $array_var1[0]
  $rule_description = $array_var1[1]
  $source = $array_var1[2]

  if size($ports) > 0 {
    firewall { "${rule_number} - Cassandra (${rule_description}) - ${source}":
      action => 'accept',
      dport  => $ports,
      proto  => 'tcp',
      source => $source,
    }
  }
}
