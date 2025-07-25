# Generates a LDAP Base DN from a domain
#
# @param domain
#   The domain to convert, defaults to the ``domain`` fact
#
# @param downcase_attributes
#   Whether to downcase the LDAP attributes
#
#     * Different tools have bugs where they cannot, handle
#       both upcased and downcased LDAP attribute elements
#
# @return [String]
#
# @example Generate LDAP Base DN with uppercase attributes
#
#   $ldap_dn = simplib::ldap::domain_to_dn('test.local')
#
#   returns $ldap_dn = 'DC=test,DC=local'
#
# @example Generate LDAP Base DN with lowercase attributes
#
#   $ldap_dn = simplib::ldap::domain_to_dn('test.local', true)
#
#   returns $ldap_dn = 'dc=test,dc=local'
#
function simplib::ldap::domain_to_dn (
  String $domain               = $facts['networking']['domain'],
  Boolean $downcase_attributes = false
) {
  if $downcase_attributes {
    $_dc = 'dc'
  }
  else {
    $_dc = 'DC'
  }

  join(split($domain,'\.').map |$x| { "${_dc}=${x}" }, ',')
}
