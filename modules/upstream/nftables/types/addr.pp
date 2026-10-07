# @summary
#   Represents an address expression to be used within a rule.
type Nftables::Addr = Variant[
  Stdlib::IP::Address::V6,
  Stdlib::IP::Address::V4,
  Nftables::Addr::Set,
  Array[Stdlib::IP::Address::V6],
  Array[Stdlib::IP::Address::V4],
  Array[Nftables::Addr::Set]
]
