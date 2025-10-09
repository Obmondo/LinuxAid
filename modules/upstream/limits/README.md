# puppet-limits [![CI](https://github.com/saz/puppet-limits/actions/workflows/ci.yml/badge.svg)](https://github.com/saz/puppet-limits/actions/workflows/ci.yml)

Manage user and group limits via Puppet

This module manages the limits of the PAM module pam_limits.

It creates files in `/etc/security/limits.d` and optionally manages the file `/etc/security/limits.conf`

## How to use


### Set limits using title pattern:

```puppet
    limits::limits{'*/nofile':
      hard => 1048576,
      soft => 1048576,
    }
    limits::limits{'root/nofile': both => 1048576; }
```

### Parameters

* `purge_limits_d_dir` (Boolean, default: true) Whether or not to purge the limits.d directory
* `manage_limits_d_dir` (Boolean, default: true) Whether or not to manage the limits.d directory
* `manage_limits_file` (Boolean, default: false) Whether or not to manage the /etc/security/limits.conf file.
* `limits_file` (String, default: /etc/security/limits.conf) The name of the limits file to be managed.
* `limits_dir`: (String) The location of the limits.d directory
* `limits_file_owner`: (String, default: root) The owner of the ${limits_file} file.
* `limits_file_group`: (String, default: root) The group of the ${limits_file} file.
* `limits_file_mode`: (String, defaul: '0644') The file mode of the ${limits_file} file.
* `entries`: (Hash) A hash of limits entries, keys should be the name and the value as a hash made up of;
  * `ensure`: (String, default present) Values can be absent or present
  * `user`: (String) The user that the limit applies to
  * `limit_type` (String) The limit type
  * `hard`: (Integer) the hard value
  * `soft`: (Integer) the soft value
  * `both`: (Integer) the value of both soft and hard
  * `target`: (String) Optional name of file in `limits_dir` to set limit settings to. Will ignore other file naming logic when provided.


### Using hiera

Puppet:

```puppet
    include ::limits
```

Hiera:

```yaml
    limits::entries:
      'root/nofile':
        both: 1048576
      '*/memlock':
        both: unlimited
```

## Compatibility

### Puppet 4.9+

This module is compatible with Puppet 4.9+, and Puppet 5.0+

### Puppet 4.0 - 4.8

To use this module with previous versions of Puppet 4 (prior to Hiera 5) you should update your Hiera data to include the following

```yaml
---
limits::limits_dir: /etc/security/limits.d

lookup_options:
  limits::entries:
    merge: deep
```


### Purge limits.d directory

The class `limits` will purge the limits.d directory by default.
You can explicit change this with the parameter `purge_limits_d_dir`

```puppet
	class { 'limits': }

    limits::limits { 'username_nofile':
      ensure     => present,
      user       => 'username',
      limit_type => 'nofile',
      hard       => 16384,
      soft       => 16384,
    }
```
### Do NOT purge limits.d directory explicitly

```puppet
    class { 'limits':
      purge_limits_d_dir => false,
    }

    limits::limits { 'username_nofile':
      ensure     => present,
      user       => 'username',
      limit_type => 'nofile',
      hard       => 16384,
    }
```

### Set both limit types in one line

```puppet
    limits::limits { 'username_nofile':
      ensure     => present,
      user       => 'username',
      limit_type => 'nofile',
      both       => 16384,
    }
```
One of hard, soft or both must be set!

### Do not manage /etc/security/limits.d

In an effort to make this module compatible with similar modules, e.g.
[puppet-module-pam](https://github.com/ghoneycutt/puppet-module-pam), management
of `/etc/security/limits.d` can be disabled by the `manage_limits_d_dir` class parameter:

```puppet
class { 'limits':
  manage_limits_d_dir => false,
}
```
