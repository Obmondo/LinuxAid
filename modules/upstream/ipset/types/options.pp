#
# @summary list of options you can configure on an ipset
#
# @see http://ipset.netfilter.org/ipset.man.html#lbAI
#
type IPSet::Options = Struct[{
    Optional[family]   => Enum['inet', 'inet6'],
    Optional[hashsize] => Integer[128],
    Optional[maxelem]  => Integer[128],
    Optional[netmask]  => IP::Address,
    Optional[timeout]  => Integer[1],
}]
