# puppet-netbackup  

[![Build Status](https://travis-ci.org/andskli/puppet-netbackup.svg?branch=master)](https://travis-ci.org/andskli/puppet-netbackup)

#### Table of Contents

- [Module Description](#module-description)
  * [What netbackup affects](#what-netbackup-affects)
  * [Setup Requirements](#setup-requirements)
- [Classes](#classes)
  * [Client](#client)
    + [Example usage](#example-usage)
  * [Server](#server)
    + [Example usage](#example-usage-1)
- [Facts](#facts)
- [Limitations and Known Issues](#limitations-and-known-issues)
- [Development](#development)
- [TODO](#todo)
- [Contributors](#contributors)

## Module Description

The netbackup module aims to automate the Netbackup Installation by leveraging the installation methods provided by the vendor.
However, this does not exclude the possibility of an installation method where package managers provide the neccessay rpms/debs/pkgs, yet that feature is still to be implemented.

### What netbackup affects

Everything that is affected by the Interactive Netbackup Installation (creates /usr/openv and populates with the right content)

### Setup Requirements

netbackup requires:  

- puppetlabs-stdlib (>= 4.7.0)
- saz/limits (>= 2.1.0)
- thias/sysctl (>= 1.0.0)
- spiette/selinux (>= 0.5.4)

## Classes

The netbackup module provides the following classes of interest

- `netbackup::client` - used for client installation and management
- `netbackup::server::prepare` - used for master/media server preparation. Applies best practices for tuning such as changing sysctl and ulimit parameters.
- `netbackup::server::tune` - applying values to the "touch files" used in netbackup for buffer settings etc, reasonable values set by default

### Client

Installs the client as neccessary on UNIX/Linux hosts, unfortunately using
quite ugly expect script.

The `netbackup::client` class is used for management of NetBackup
client. If no NetBackup client is present, it will try to run the NetBackup
installer located at `installer` (should preferably be an NFS mount).

- `installer` - full path to the install binary provided from NetBackup DVD
- `version` - run install unless a client of this version is already installed
- `masterserver` - which masterserver should be entered upon installation of client
- `mediaservers` - mediaservers which has access to a client
- `service_enabled` - start netbackup, true or false?
- `excludes` - array of excludes to put in exclude list

#### Example usage

Sample definition:

    class { 'netbackup::client':
        installer       => '/path/to_nfs_share/NetBackup_7.6.0.1_CLIENTS2/install',
        version         => '7.7.2',
        service_enabled => true,
        masterserver    => 'netbackup.xyz.com',
        mediaservers    => ['mediasrv1.xyz.com', 'mediasrv2.xyz.com'],
        excludes        => ['/tmp', '/other/excluded/path'],
    }

The same configuration using Hiera,

```yaml
---
netbackup::client::version:         '7.7.2'  
netbackup::client::service_enabled: true  
netbackup::client::masterserver:    'netbackup.xyz.com'
netbackup::client::mediaservers:
  - 'mediasrv1.xyz.com'
  - 'mediasrv2.xyz.com'
netbackup::client::excludes:
  - '/tmp'
  - '/other/excluded/path'
```

### Server

Only handles preparation for NetBackup Master/media installation for now, see `netbackup::server::prepare`.

#### Example usage

	class { 'netbackup::server::prepare': }


## Facts

- `netbackup_client_name` - returns the client name from `/usr/openv/netbackup/bin/nbgetconfig`
- `netbackup_serverlist` - returns a list of servers retreived from `/usr/openv/netbackup/bin/nbgetconfig`
- `netbackup_version` - returns a string containing version information found in `/usr/openv/netbackup/bin/version`, `nil` if the file is not found or it does not contain a version string

## Limitations and Known Issues

The installer must be present (and reachable) on the Puppet Client. For most of the cases, The Netbackup Installation folder is Shared trhough NFS and mounted on the Nodes (May also leverage on autofs to automount that shared NFS).

Only tested on Linux (RHEL/CentOS/Ubuntu) for now.

## Development
I happily accept bug reports and pull requests via github,  
https://github.com/andskli/puppet-netbackup

- Fork it
- Create a feature branch
- Write a failing test
- Write the code to make that test pass
- Refactor the code
- Submit a pull request

## TODO

- Server installation of master/media
- Tuning/parameterizing of master/media
- Policy creation/modification via puppet?
- Server facts
- Client facts
- Client upgrades
- ??


## Contributors

The module is written and being mainly maintained by: 
- [andskli](https://github.com/andskli) 
- [stivesso](https://github.com/stivesso)
