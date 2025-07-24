# Matches all possible lists of IPv4 Network Addresses
type Simplib::Netlist::IP::V4 = Array[Variant[
    Simplib::IP::V4,
    Simplib::IP::V4::CIDR,
    Simplib::IP::V4::DDQ,
    Simplib::IP::V4::Port
  ]
]
