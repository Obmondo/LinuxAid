#
# @summary type to allow a file on the puppetserver as source for ip addresses for ipsets
#
type IPSet::Set::Puppet_URL = Pattern[/^puppet:\/\//]
