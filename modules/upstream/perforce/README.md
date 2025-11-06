# perforce
[![Build Status](https://travis-ci.org/mmarseglia/puppet-perforce.svg?branch=master)](https://travis-ci.org/mmarseglia/puppet-perforce)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with perforce](#setup)
    * [What perforce affects](#what-perforce-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with perforce](#beginning-with-perforce)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Install and configure the revision control system Helix, by Perforce.

## Setup

### What perforce affects **OPTIONAL**

This module will install the perforce service, p4d. It will create a systemd unit file to manage the service.

### Setup Requirements **OPTIONAL**

At a minimum you must create the perforce root directory (which holds the p4d databases) and a user account to run the
service (default user is perforce).

### Beginning with perforce

```puppet
$user = 'perforce'
$service_root = '/opt/perforce/p4root'

user { $user :
  ensure     => present,
  home       => $service_root,
  system     => true,
}

file { ['/opt/perforce', $service_root ] :
  ensure  => directory,
  owner   => $user,
  mode    => '0750',
  require => User[$user],
}

class { 'perforce':
  require => File[$service_root],
}
```

## Usage

### Just Install Packages

If you don't want the module to manage perforce's configuration you can install just the packages.

```puppet
class { ::perforce::repository: }
-> class { ::perforce::install: }
```

### Configuring Perforce for SSL/TLS

This module will configure the p4d service for SSL by setting `service_ssldir` to a fully qualified path.  You must also
provide a private key and certificate.  p4d requires these files are named `privatekey.txt` and `certificate.txt`.

```puppet
$service_ssldir = '/opt/perforce/p4ssldir'
$private_key = "-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDHYb8MmF7Bimo5
XubrQyTOcJmJORiK0eTbGJGm/nhTa4Kv1GB0+g+9+nSQwcxK3An+zMfwY7Ej269u
PwI+KlwtgvOCr22hQoO14KUHzqGAxjKB+vfLssMcaXs1mLndVmWJM9wVA9O1nzYs
iA6tfd0yOHUXxUqktTVB9JHGA5/6nQb63Snhk1rOHddSjDoO+iL6lmXZFG6x4IEq
odS1wG1MQueTB+KzgeT8m0JYX6uYx5KsmRKEO2l/YMLEOIj303NRIORUZU6OTUtP
Jx17ZdhDcm1Pn/6OlyqMuZqzJrYJIlJ7zsRWtzjP6XBKd3OrKLlyaGRThPUDGqKn
eM54KthDAgMBAAECggEBAIOjr8YbHATg5H14gTI3pKeAhH6rad7N8jIOKKx/Ouap
ByIcMItLRvWB1VB2A/IxEZBfmGrJB33LYCqEA3ET+sQ5v5k7RkDAb8G3zn43GT6y
nUpgbxbYsiWiJy0d5ymSD3vk95wQaMlzkwsX0ckOXur3h6foJP5WfhFL7qs0XX3S
4PALYbS//N2rKBk117Wnqiub0KjVjssWhICizZgvKJNET8//WoZ5TG51kp/mEgUY
XsrBgQa/hhYNGvBzUTJDafmRcnA9EDO4srr+iDDF2wbFgjSKUj5LBPEldbHtNg3i
UPlHODkUNYWla8CkaCvscXLk+G5KBueDdTBPyp0Cw7ECgYEA6jz9ZEL74uyFE+fT
3lCbj/nixRBiW5lCZ3bQT+fCe93ywmQpNNRI1HLijm2SSBQpC3baksJHxXHBXZW0
/4R1ETXpu2g6EIeB8zM0cs3VduRNG0QA0OsMnyWTJFwIONl1mD1f6ms0BWsbJbLr
9W0OQPwcIqDyg4s7hlrrVVhJo50CgYEA2ee/gXZl2yvYvnf5HPloB5IdEUX9lMRE
OMewiiu84e12N2dREAZp7Z8FMdT0fwixfBquWUa5E3LVEwGhheQ5pC+eUS3d7Mpi
Fv7qNg8o3oi1+B3jaaaKCk6zmPRbsxblF+PdUvds6pCCme4BXY8MD+OI4SKsENVf
B4u+wzpUVV8CgYAlFr0kh/qsRrkXmsiQVgEbvfxrKZn5WP4LteNsE41W4aDTqNph
dA+IHBzFYpIb+Z06JHqdbEfC+q0cbVz4bHfA3uGAfBNdlKc94+i1GORo6+NNouni
KqWX+XIf+raOkdgt3+H1Ez5scTYeNQNpm/f60DCARy2/KGencXP70nvufQKBgFEa
0gvUzrqSCl1yeDVRm2fd+ZW5UFYz6xSbNtlmyCnrYanjeaeWS40XOC7BDbPOv4jq
wWQXT8GuZyJo4/7a4J1839dlVAnTlkjq3q/6WoLhraFJNqDXTN/jRTO0GAGDjwei
V3mPAGoaGZJDpRx2ps2vKf5qElM9p94+JGWz6znPAoGBAIwLT8MEiUvLL87F4G1z
ImwI2+x3uJro6y977dax/20rjOa6TvGo4kIrVAgH7cjBVqzGvFFfGlQKytRJ9vDG
hkBHT7KEoypcPrbwu3fSStr/5qvq5mETOD3LAJsXC3kTa2mfmZii2KBQ0Fn7TOis
98tGyMeMVjTW2b6WqwW6DtA7
-----END PRIVATE KEY-----"
$certificate = "-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAObn29SUorldMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMTgwNTMwMjAwODEyWhcNMTkwNTMwMjAwODEyWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAx2G/DJhewYpqOV7m60MkznCZiTkYitHk2xiRpv54U2uCr9RgdPoPvfp0
kMHMStwJ/szH8GOxI9uvbj8CPipcLYLzgq9toUKDteClB86hgMYygfr3y7LDHGl7
NZi53VZliTPcFQPTtZ82LIgOrX3dMjh1F8VKpLU1QfSRxgOf+p0G+t0p4ZNazh3X
Uow6Dvoi+pZl2RRuseCBKqHUtcBtTELnkwfis4Hk/JtCWF+rmMeSrJkShDtpf2DC
xDiI99NzUSDkVGVOjk1LTycde2XYQ3JtT5/+jpcqjLmasya2CSJSe87EVrc4z+lw
Sndzqyi5cmhkU4T1Axqip3jOeCrYQwIDAQABo1AwTjAdBgNVHQ4EFgQUB+oUrgz5
RiBnRE9hSjlS8pjGNb8wHwYDVR0jBBgwFoAUB+oUrgz5RiBnRE9hSjlS8pjGNb8w
DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAcvzyiNgYYRffoO5lzMjg
eOyO0F8+FZdZRDUwijAC8eRsBDD7vfJIhYdIp2wyqbLXFd4oA/8Lw4f92ETiUfdV
E7oG94dNzbk4sIZCtQWIiPiFeqEDGM+465goiuNeb+N0zHO5/4xO+tF8RW7MV2gc
ekQx4dzFV6CatsLkzQKMZHqDyRMXkebp36FdKmEbg/VH2P04JKIMQo0wc0L82dxn
SUSxBKdUCRIml+kXJZPE0CC+DtPcv1pzPAFLCDNQwdreurKk+KE985RKanx9iZdS
7RyghSDie7e/KhwfQjfreCUXSfV/3sAKajYv3LyWCc3WAE11Ugg8DUK+i55WikjC
WA==
-----END CERTIFICATE-----"

file { $service_ssldir :
  ensure => directory,
  owner  => 'perforce',
  mode   => '0700',
}

file {
  default:
    ensure  => file,
    owner   => 'perforce',
    mode    => '0600',
    require => File[$service_ssldir],
    before  => Class['perforce'],
    ;;

  "${service_ssldir}/privatekey.txt":
    content => $private_key,
    ;;

  "${service_ssldir}/certificate.txt":
    content => $certificate,
}

class { 'perforce':
  service_ssldir => $service_ssldir
}
```

## Reference


## Limitations

* Developed and tested on CentOS 7 and RHEL7.
* Requires systemd.

## Development

Fork and submit a PR.

## Release Notes/Contributors/Etc. **Optional**
