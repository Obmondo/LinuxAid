# @summary
#   Represents a rule name to be used in a raw rule created via nftables::rule.
#   It's a dash separated string. The first component describes the chain to
#   add the rule to, the second the rule name and the (optional) third a number.
#   Ex: 'default_in-sshd', 'default_out-my_service-2'.
type Nftables::RuleName = Pattern[/^[a-zA-Z0-9_]+-[a-zA-Z0-9_]+(-\d+)?$/]
