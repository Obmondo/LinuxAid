# Matches all possible lists of IP Network Addresses
type Simplib::Netlist::IP = Array[Variant[
    Simplib::IP::V4,
    Simplib::IP::V4::CIDR,
    Simplib::IP::V4::DDQ,
    Simplib::IP::V4::Port,
    Simplib::IP::V6,
    Simplib::IP::V6::CIDR,
    Simplib::IP::V6::Port
  ]
]
