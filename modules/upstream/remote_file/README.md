# remote_file

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [License](#license)
8. [Contact](#contact)

## Overview

Provides a resource type to download files from remote servers.

## Module Description

The remote_file module provides a utility resource type to download files from
remote servers. This is useful in situations where application content is being
served from a non-package file repository, where a local copy of installation
media for software needs to be retrieved as part of a custom installation
procedure, or any number of other use cases.

Retrieving content from remote servers is a general and very basic
configuration capability.

## Usage

Specify the path to a file that should exist locally, and parameters that
describe where to get it if it does not exist or is not in sync. For example:

```puppet
remote_file { '/etc/myfile':
  ensure => present,
  source => 'http://example.com/file.tar.gz',
}
```

The `path` parameter is the remote_file type's namevar.

```puppet
remote_file { 'app_config_file':
  ensure => present,
  path   => '/etc/myfile',
  source => 'http://example.com/file.tar.gz',
}
```

In the above examples, the `/etc/myfile` resource is considered to be in sync
if it exists. If it does not, it will be downloaded from the specified source
and whatever content is retrieved will be saved in the specified path. On
subsequent runs, so long as that file still exists, the resource will be
considered in sync.

The `remote_file` type supports tighter synchronization tolerances either
through the specification of a checksum, or by checking a remote HTTP server's
Last-Modified header or using the FTP `MDTM` command. For example, the following
resource specifies a checksum:

```puppet
remote_file { '/path/to/your/file':
  ensure   => present,
  source   => 'http://example.com/file.tar.gz',
  checksum => 'd41d8cd98f00b204e9800998ecf8427e'
}
```

The default hash algorithm is md5. The hash algorithm used for checksumming may be
specified using the `checksum_type` parameter:

```puppet
remote_file { '/path/to/your/file':
  ensure        => present,
  source        => 'http://example.com/file.tar.gz',
  checksum      => 'f287b50892d92dfae52c0d32ddcb5b60a9acfa59e9222a0f59969453545e9ca4',
  checksum_type => 'sha256'
}
```

If the remote source provides an HTTP Last-Modified header, the remote_file
type can use that information to determine synchronization. When a file is
downloaded, its mtime is set to match the server's Last-Modified header.
Synchronization is later satisfied if the mtime of the local file matches the
Last-Modified header from the remote server.

```puppet
remote_file { 'jenkins.war':
  ensure   => latest,
  path     => '/opt/apache-tomcat/tomcat8/webapps/jenkins.war',
  source   => 'http://updates.jenkins-ci.org/latest/jenkins.war',
}
```

### Using a Proxy

The `remote_file` type provides several proxy-related parameters. You should
choose between specifying `proxy` or specifying `proxy_host` and `proxy_port`.
The following two examples are equivalent.

Using the `proxy` parameter:

```puppet
remote_file { '/path/to/your/file':
  ensure   => present,
  source   => 'http://example.com/file.tar.gz',
  checksum => 'd41d8cd98f00b204e9800998ecf8427e'
  proxy    => 'http://192.168.12.40:3128',
}
```

Using `proxy_host` and `proxy_port` instead:

```puppet
remote_file { '/path/to/your/file':
  ensure     => present,
  source     => 'http://example.com/file.tar.gz',
  checksum   => 'd41d8cd98f00b204e9800998ecf8427e'
  proxy_host => '192.168.12.40',
  proxy_port => 3128,
}
```

If a username and/or password are required to authenticate to your proxy, you
can specify these either as part of the `proxy` URI, or separately using the
`proxy_username` and `proxy_password` parameters.

Note that `proxy` is not supported for files fetched using FTP.

## Reference

### Type: remote_file

#### Parameters

* `ensure`: Valid values are present, absent, latest.
* `path`: Namevar. The local path to the file, or where to save the remote
  content to.
* `source`: The source location of the file, or where to get it from if it is
  needed. This should be a URI.
* `checksum`: Checksum of this file. Hash function used is specified by the `checksum_type`
  parameter. A new copy of the file will not be downloaded if the local file's
  checksum matches this value.
* `checksum_type`: Hash algorithm to use for checksumming. Supports the same arguments
  as [the checksum parameter of the File type](https://docs.puppetlabs.com/references/latest/type.html#file-attribute-checksum).
* `verify_peer`: Boolean. Whether or not to require verification of the the
  remote server identity.
* `username`: Username to use for basic authentication.
* `password`: Password to use for basic authentication.
* `proxy`: The full URI of an http/https proxy to use, as it would be specified
  in an environment variable; e.g. `http://myproxy.local:3128`.
* `proxy_host`: The host name of an http/https proxy to use. Not required if
  the `proxy` parameter is used.
* `proxy_port`: If using a proxy, the port to use to connect to the proxy. Not
  required if the `proxy` parameter is used.
* `proxy_username`: If using a proxy, the username to use to authenticate to
  the proxy.
* `proxy_password`: If using a proxy, the password to use to authenticate to
  the proxy.
* `headers`: Hash containing extra HTTP headers (can be
  overriden by other conflicting parameters)
* `owner`: owner attribute of the file. See the File type for details.
* `group`: group attribute of the file. See the File type for details.
* `mode`: mode attribute of the file. See the File type for details.

### Provider: ruby

The ruby provider, included with this module, implements the remote_file type
using Net::HTTP from Ruby's standard library.

## Limitations

Currently only http, https, and file URI sources are supported by the default
ruby provider.

## License

Apache License Version 2.0

## Contact

Torbjörn Norinder
