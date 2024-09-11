# puppet-limits [![Build Status](https://secure.travis-ci.org/saz/puppet-limits.png)](http://travis-ci.org/saz/puppet-limits)

Manage user and group limits via Puppet

This module manages the limits of the PAM module pam_limits.

It creates files in `/etc/security/limits.d` and does not manage the file `/etc/security/limits.conf`

## How to use


### Set limits using title pattern:

```puppet
    limits::limits{'*/nofile':
      hard => 1048576,
      soft => 1048576,
    }
    limits::limits{'root/nofile': both => 1048576; }
```

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

This module has been tested to work with Puppet v3 (with and without the future
parser) and v4 with Ruby versions 1.8.7 (Puppet v3 only), 1.9.3, 2.0.0 and
2.1.0.

### Purge limits.d directory

The class `limits` will purge the limits.d directory as default.
You can explicit change this with the parameter `purge_limits_d_dir`
or just do not call the class.

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
of `/etc/security/limits.d` can be disabled by way of the `manage_limits_d_dir`
class parameter:

```puppet
class { 'limits':
  manage_limits_d_dir => false,
}
```
