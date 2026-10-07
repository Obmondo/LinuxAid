# @summary
#   Represents a simple rule name to be used in a rule created via nftables::simplerule
type Nftables::SimpleRuleName = Pattern[/^[a-zA-Z0-9_]+(-\d+)?$/]
