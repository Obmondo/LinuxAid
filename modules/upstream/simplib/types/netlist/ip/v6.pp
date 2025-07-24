# Matches all possible lists of IPv6 Network Addresses
type Simplib::Netlist::IP::V6 = Array[Variant[
    Simplib::IP::V6,
    Simplib::IP::V6::CIDR,
    Simplib::IP::V6::Port
  ]
]
