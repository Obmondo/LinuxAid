# posix_acl

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
  * [Beginning with posix_acl](#beginning-with-posix_acl)
3. [Usage](#usage)
  * [Using action => set](#using-action-=>-set)
  * [Using action => exact](#using-action-=>-exact)
  * [Using action => unset](#using-action-=>-unset)
  * [Using action => purge](#using-action-=>-purge)
7. [Limitations](#limitations)


## Description
This plugin module provides a way to set POSIX 1.e (and other standards) file ACLs via Puppet.

## Setup

### Beginning with posix_acl
* The `posix_acl` resource `title` is used as the path specifier.
* ACLs are specified in the `permission` property as an array of strings in the same format as is used for `setfacl`.
* The `action` parameter can be one of `set`, `exact`, `unset` or `purge`. These are described in detail below.
* The `provider` parameter allows a choice of filesystem ACL provider. Currently only POSIX 1.e is implemented.
* The `recursive` parameter allows you to apply the ACLs to all files under the specified path.

```
posix_acl { "/var/log/httpd":
  action     => set,
  permission => [
    "user::rwx",
    "group::---",
    "mask::r-x",
    "other::---",
    "group:logview:r-x",
    "default:user::rwx",
    "default:group::---",
    "default:mask::rwx",
    "default:other::---",
    "default:group:logview:r-x",
  ],
  provider   => posixacl,
  require    => [
    Group["logview"],
    Package["httpd"],
    Mount["/var"],
  ],
  recursive  => false,
}
```
## Usage

### Using action => set
The `set` option for the `action` parameter allows you to specify a minimal set of ACLs which will be guaranteed by Puppet. ACLs applied to the path which do not match those specified in the `permission` property will remain unchanged.

#### Initial permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:webadmin:r-x
group:httpadmin:rwx
```

#### Specified acls
```
permission  => [
  'user::rwx',
  'group::r-x',
  'other::r-x',
  'mask::rwx',
  'group:webadmin:rwx',
  'user:apache:rwx',
],
```

#### Updated permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
user:apache:rwx
group:webadmin:rwx
group:httpadmin:rwx
```

### Using action => exact
The `exact` option for the `action` parameter will specify the exact set of ACLs guaranteed and enforced by Puppet. ACLs applied to the path which do not match those specified in the `permission` property will be removed.

#### Initial permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:webadmin:r-x
group:httpadmin:rwx
```

#### Specified acls
```
permission  => [
  'user::rwx',
  'group::r-x',
  'other::r-x',
  'mask::rwx',
  'group:webadmin:r--',
  'user:apache:rwx',
],
```
#### Updated permissions
* `group:httpadmin` permission is removed
* `user:apache` permission is added
* `group:webadmin` permission is updated

```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:webadmin:r--
user:apache:rwx
```

### Using action => unset
The `unset` option for the `action` parameter will specify the set of ACLs guaranteed by Puppet to NOT be applied to the path. ACLs applied to the path which match those specified in the `permission` property will be removed. ACLs applied to the path which do not match those specified in the `permission` property will remain unchanged.

#### Initial permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:webadmin:r-x
group:httpadmin:rwx
```

#### Specified acls
```
permission  => [
  'user::rwx',
  'group::r-x',
  'other::r-x',
  'mask::rwx',
  'group:webadmin:r--',
  'user:apache:rwx',
],
```

#### Updated permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:httpadmin:rwx
```

### Using action => purge
The `purge` option for the `action` parameter will cause Puppet to remove any file ACLs applied to the path.

**NOTE**: Although the `permission` property is unused for this action, it needs to have a valid ACL value for the action to work. This is a known issue.

#### Initial permissions
```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
mask::rwx
group:webadmin:r-x
group:httpadmin:rwx
```

#### Specified acls
See ***note*** above.
```
permission  => [
  'user::rwx',
  'group::r-x',
  'other::r-x',
  'mask::rwx',
  'group:webadmin:r--',
  'user:apache:rwx',
],
```

#### Updated permissions
- All file ACLs are removed.

```
# file /var/www/site1
user::rwx
group::r-x
other::r-x
```

## Limitations
### Conflicts with "file" resource type:
If the path being modified is managed via the `File` resource type, the path's mode bits must match the value specified in the `permission` property of the ACL.

### Mask check
The ACL setter doesn't recalculate the rights mask based on the user/group ACLs specified, so it is possible to specify ACLs on a file for which a more restrictive set of rights is enforced, known as "effective rights". For example, with these `permission` parameters on a file `test`:
```
permission  => [
  'user::rw-',
  'group::---',
  'mask::r--',
  'other::---',
  'user:apache:rwx',
  'group:root:r-x',
  'group:admin:rwx',
],
```

The output of `getfacl test` reveals a more restrictive set of effective rights, which might not be what was expected:
```
# file: test
# owner: root
# group: root
user::rw-
group::---
other::---
mask::r--
user:apache:rwx                 #effective:r--
group:root:r-x                  #effective:r--
group:admin:rwx                 #effective:r--
```
