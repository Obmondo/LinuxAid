# @summary
#   Represents a port range expression to be used within a rule.
type Nftables::Port::Range = Pattern[/^\d+-\d+$/]
