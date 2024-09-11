# puppet-dnsmasq [![CI Build Status](https://github.com/saz/puppet-dnsmasq/actions/workflows/ci.yml/badge.svg)](https://github.com/saz/puppet-dnsmasq/actions/workflows/ci.yml)

Manage dnsmasq via Puppet

### Supported Puppet versions
* Puppet >= 4
* Last version supporting Puppet 3: v1.3.1

## How to use

```
    dnsmasq::conf { 'local-dns':
      ensure => present,
      source => 'puppet:///files/dnsmasq/local-dns',
    }
```

or

```
    dnsmasq::conf { 'another-config':
      ensure  => present,
      content => 'dhcp-range=192.168.0.50,192.168.0.150,12h',
    }
```

## Hiera usage

```
    class { '::dnsmasq':
      configs_hash    => {},
      hosts_hash      => {},
      dhcp_hosts_hash => {},
    }
```

purge unmanaged files in $config_dir:

```
    class { '::dnsmasq':
      purge_config_dir => true,
    }
```

```
    class { '::dnsmasq':
      configs_hash => {
        'another-config' => {
          content => 'dhcp-range=192.168.0.50,192.168.0.150,12h',
        },
      },
    }
```

## class params and default values

```
    class { '::dnsmasq':
      configs_hash     => {},
      hosts_hash       => {},
      dhcp_hosts_hash  => {},
      package_ensure   => 'installed',
      service_control  => true,
      purge_config_dir => true,
    }
```
