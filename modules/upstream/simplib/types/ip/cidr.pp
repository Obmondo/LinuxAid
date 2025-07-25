# Matches valid CIDR IP addresses
#
type Simplib::IP::CIDR = Variant[Simplib::IP::V4::CIDR, Simplib::IP::V6::CIDR]
