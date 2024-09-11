# puppet-bind

## Disclaimer

This module has been created when Puppet classes did not support parameters.
It shows. Tests and Debian/Ubuntu support are external contributions and are
not as actively maintained as they should be.

The primary focus of this module has always been Enterprise Linux (RHEL, CentOS
and other clones), and it works fine on releases as far back as RHEL5, although
the latest RHEL release is always recommended.

## Overview

Install and enable a BIND DNS server, manage its main configuration and install
and manage its DNS zone files.

* `bind` : Main class to install and enable the server.
* `bind::server::conf` : Main definition to configure the server.
* `bind::server::file` : Definition to manage zone files.
* `bind::package` : Class to install the server package (included from `bind`)
* `bind::service` : Class to manage the server service (included from `bind`)

The split between `bind` and `bind::server::conf` allows to use a static file
or a different template-based file for the main `named.conf` file if needed,
while still using this module for the main package, service and managing zone
files. This is useful if you have a large and/or complex named.conf file.
Note that you may also use the `bind::package` and `bind::service` classes on
their own, though you won't need to if you use the main class, which includes
them both.

## Examples

Here is a typical LAN recursive caching DNS server configuration :

```puppet
include bind
bind::server::conf { '/etc/named.conf':
  listen_on_addr    => [ 'any' ],
  listen_on_v6_addr => [ 'any' ],
  forwarders        => [ '8.8.8.8', '8.8.4.4' ],
  allow_query       => [ 'localnets' ],
  zones             => {
    'myzone.lan' => [
      'type master',
      'file "myzone.lan"',
    ],
    '1.168.192.in-addr.arpa' => [
      'type master',
      'file "1.168.192.in-addr.arpa"',
    ],
  },
}
```

The zone files for the above could then be managed like this :

```puppet
bind::server::file { 'myzone.lan':
  source => 'puppet:///modules/mymodule/dns/myzone.lan',
}
bind::server::file { '1.168.192.in-addr.arpa':
  source => 'puppet:///modules/mymodule/dns/1.168.192.in-addr.arpa',
}
```

Then if all source files are in the same location and named after the zone :

```puppet
bind::server::file { [ 'myzone.lan', '1.168.192.in-addr.arpa' ]:
  source_base => 'puppet:///modules/mymodule/dns/',
}
```

For RHEL5, you might want to use the newest possible bind packages 
(otherwise if you're using `bind-chroot`, you'll need to check
whether the zone files need to be placed inside the chroot, e.g.
`/var/named/chroot/var/named`. Doing this unconditionally will break
the newest versions of BIND if zone files are deployed before `named`
is started for the first time, so be careful):

```puppet
class { '::bind': packagenameprefix => 'bind97' }
```

Since SELinux offers a very high level of protection, chrooting is quite
redundant, so it's disabled by default. You can nevertheless enable it if
you want :

```puppet
class { '::bind': chroot => true }
bind::server::conf { '/etc/named.conf':
  # [... same as before ...]
}
bind::server::file { 'myzone.lan':
  zonedir => '/var/named',
  source  => 'puppet:///files/dns/myzone.lan',
}
```

To avoid repeating the `zonedir` parameter each time, you can also use :

```puppet
Bind::Server::File { zonedir => '/nfs/zones' }
```

The module also supports views, where the main `zones` will be included in all
views, and view-specific `zones` may be declared :

```puppet
bind::server::conf {
  zones => {
    'example.com' => [
      'type master',
      'file "example.com"',
    ],
  },
  views => {
    'trusted' => {
      'match-clients' => [ '192.168.23.0/24' ],
      'zones' => {
        'myzone.lan' => [
          'type master',
          'file "myzone.lan"',
        ],
      },
    },
    'default' => {
      'match-clients' => [ 'any' ],
    },
  },
}
```

