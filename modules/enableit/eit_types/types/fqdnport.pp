# Port regex is copied from here
# https://github.com/puppetlabs/puppetlabs-stdlib/blob/main/types/fqdn.pp
# and IP address with no subnet is copied from stdlib
# https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/types/ip/address/v4/nosubnet.pp

type Eit_types::FQDNPort = Pattern[/\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9]):((6553[0-5])|(655[0-2][0-9])|(65[04][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$/] #lint:ignore:140chars
