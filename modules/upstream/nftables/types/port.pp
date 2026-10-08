# @summary
#   Represents a port expression to be used within a rule.
type Nftables::Port = Variant[
  Array[Variant[Nftables::Port::Range, Stdlib::Port], 1],
  Stdlib::Port,
  Nftables::Port::Range,
]
