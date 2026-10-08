# Valid Hostnames
#
# Complies with the host name restrictions of RFC 1123, Section 2.1:
#
#  * only ASCII alpha + numbers + hyphens are allowed
#  * labels can't begin or end with hyphens
#  * the highest-level label cannot be all-numeric, so that a host name can
#    never be confused with a dotted-decimal IP address
#  * a DNS label may be no more than 63 octets long
#  * a host name may be no more than 253 octets long
#  * host names may end with a period
#
# May not match Unicode and does not validate against the TLD registry
#
type Simplib::Hostname = Pattern['\A(?i-mx:(?=.{1,253}\z)((?!-)[a-z0-9-]{1,63}(?<!-)\.)*(?!-|\d+\.?\z)([a-z0-9-]{1,63})(?<!-)\.?)\z']
