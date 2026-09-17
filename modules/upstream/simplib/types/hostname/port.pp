# Valid Hostnames with ports
#
# The host name portion complies with the host name restrictions of RFC 1123,
# Section 2.1. See Simplib::Hostname for the full list.
#
# May not match Unicode and does not validate against the TLD registry
#
type Simplib::Hostname::Port = Pattern['\A(?i-mx:(?=[^:]{1,253}:)((?!-)[a-z0-9-]{1,63}(?<!-)\.)*(?!-|\d+\.?:)([a-z0-9-]{1,63})(?<!-)\.?):([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z']
