# Port regex is copied from here
# https://stackoverflow.com/a/41371546/1530269
# and IP address with no subnet is copied from stdlib
# https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/types/ip/address/v4/nosubnet.pp

type Eit_types::IPv4Port = Pattern[/\A([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])){3}:((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$/] #lint:ignore:140chars
