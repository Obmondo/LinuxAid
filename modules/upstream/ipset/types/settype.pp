#
# @summary different datatypes that provides prefixes for the actual ipset
#
type IPSet::Settype = Variant[
  IPSet::Set::Array,
  IPSet::Set::Puppet_URL,
  IPSet::Set::File_URL,
  String,
]
