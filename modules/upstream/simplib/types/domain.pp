# Valid DNS domain names
#
# Complies with TLD restrictions from Section 2 of RFC 3696:
#
#  * only ASCII alpha + numbers + hyphens are allowed
#  * labels can't begin or end with hyphens
#  * TLDs cannot be all-numeric
#  * TLDs must be able to end with a period
#  * A DNS label may be no more than 63 octets long
#  * A domain name may be no more than 253 octets long
#
type Simplib::Domain = Pattern['\A(?i-mx:(?=.{1,253}\z)((?!-)[a-z0-9-]{1,63}(?<!-)\.)*(?!-|\d+\.?\z)([a-z0-9-]{1,63})(?<!-)\.?)\z']
