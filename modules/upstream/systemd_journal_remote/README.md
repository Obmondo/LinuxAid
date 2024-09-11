# systemd journal remote

[![Build Status](https://github.com/gibbs/puppet-systemd_journal_remote/workflows/CI/badge.svg)](https://github.com/gibbs/puppet-systemd_journal_remote/actions?query=workflow%3ACI)
[![Release](https://github.com/gibbs/puppet-systemd_journal_remote/workflows/Release/badge.svg)](https://github.com/gibbs/puppet-systemd_journal_remote/actions?query=workflow%3ARelease)
[![Puppet Forge](https://img.shields.io/puppetforge/v/genv/systemd_journal_remote.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/genv/systemd_journal_remote)
[![Apache-2 License](https://img.shields.io/github/license/gibbs/puppet-systemd_journal_remote.svg)](LICENSE)

## Overview

This module installs, configures and manages the following remote journald
services:

- `systemd-journal-remote`
- `systemd-journal-upload`
- `systemd-journal-gatewayd`

## Package Management

By default, depending on the distribution, the `systemd-journal-remote` package
is managed. The `::systemd_journal_remote` class is required by all other
services managed by this module.

```puppet
# Default package management
class { '::systemd_journal_remote':
  manage_package => true,
  package_name   => 'systemd-journal-remote',
  package_ensure => present,
}
```

## Example Usage

### Remote Service

The `systemd-journal-remote` service can be used to receive journal messages
over the network with the `::systemd_journal_remote::remote` class.

```puppet
include ::systemd_journal_remote::remote
```

By default, to ensure the service runs without configuration, `journal-remote`
listens over HTTP and outputs to `/var/log/journal/remote/`.

To receive over HTTPS (recommended) and use trusted connections with Puppet
certificates:

```puppet
# Passive configuration example
class { '::systemd_journal_remote::remote':
  command_flags => {
    'listen-https' => '0.0.0.0:19532',
    'compress'     => 'yes',
    'output'       => '/var/log/journal/remote/',
  },
  options       => {
    'SplitMode'              => 'host',
    'ServerKeyFile'          => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
    'ServerCertificateFile'  => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    'TrustedCertificateFile' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
  }
}
```

To pull data from another source in:

```puppet
# Active configuration example
class { '::systemd_journal_remote::remote':
  command_flags => {
    'url'    => 'https://some.host:19531/',
    'getter' => "'curl \"-HAccept: application/vnd.fdo.journal\" https://some.host:19531/'",
    'output' => '/var/log/journal/remote/',
  },
  options       => {
    'SplitMode' => 'host',
  }
}
```

The `command_flags` and `options` parameters available mirror those documented
in `man systemd-journal-remote` and `man journal-remote.conf`.

### Upload Service

The `systemd-journal-upload` service can be used to upload (send) journal
messages over the network with the `::systemd_journal_remote::upload` class.

By default this class is configured to upload over HTTP to
`http://0.0.0.0:19532` and save its current state to
`/var/lib/systemd/journal-upload/state`.

To send journal events over HTTPS using Puppet certificates:

```puppet
# Upload over HTTPS with Puppet certificates
class { '::systemd_journal_remote::upload':
  command_flags => {
    'save-state' => '/var/lib/systemd/journal-upload/state',
  },
  options       => {
    'URL'                    => 'https://0.0.0.0:19532',
    'ServerKeyFile'          => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
    'ServerCertificateFile'  => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    'TrustedCertificateFile' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    'NetworkTimeoutSec'      => '30',
  }
}
```

### Gateway Daemon Service

The `systemd-journal-gatewayd` service can be used as a HTTP server to request
journal logs as server-sent events, binary or in text/JSON using the
`::systemd_journal_remote::gatewayd` class.

By default the server listens on all interfaces over HTTP on port 19531. To use
HTTPS add the `cert` option.

```puppet
# Expect HTTPS connection using Puppet certificates
class { '::systemd_journal_remote::gatewayd':
  command_flags => {
    'key'   => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
    'cert'  => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    'trust' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
  }
}
```

## Limitations

SSL certificates are *not* managed by this module. You will need to ensure
the `systemd-journal-(remote|upload|gateway)` users have the correct access
to the necessary files.

This module only manages the `systemd-journal-(remote|upload|gatewayd)` systemd
service `ExecStart`, `journal-remote.conf` and `journal-upload.conf`
configuration files and the initial package installation.
