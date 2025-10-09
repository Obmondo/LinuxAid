#
# @summary type to allow a static file on the target system as source for ipsets
#
type IPSet::Set::File_URL = Pattern[/^file:\/\/\//]
