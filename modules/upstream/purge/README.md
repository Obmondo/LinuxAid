[![Build Status](https://travis-ci.org/crayfishx/puppet-purge.svg?branch=master)](https://travis-ci.org/crayfishx/puppet-purge) 

# purge 

This is a metatype to purge resources from the agent. It behaves in a similar way to the 'resources' type native in Puppet but offers more finite control over the criteria in which resources are purged.

When run without parameters the purge type takes a resource type as a title.  The resource type must be one that has a provider that supports the instances method (eg: package, user, yumrepo).  Any instances of the resource found on the agent that are *not* in the catalog will be purged.  You can also add filter conditions to control the behaviour of purge using the if and unless parameters.

## Differences to the `resources` resource

* Allows fine tuning of which resources get purged
* Not isomorphic, meaning multiple purge resource declarations can purge the same resource type
* Purging doesn't always mean destruction - you can use purge to set other attributes, not just `ensure => absent`


## Examples

Eg:
To remove *all* users found on the system that are not present in the
catalog (caution!):

```puppet
   purge { 'user': }
```

To remove all users found on the system but not in the catalog, unless
the user has a UID below 500:

```puppet
 purge { 'user':
  unless => [ 'uid', '<=', '500' ],
 }
```

You may also use regexes to filter, for example, to remove all unmanaged yumrepos unless they used for RHEL Satellite, you could do something like;

```puppet
  purge { 'yumrepo':
    unless => [ 'baseurl', '=~', '^http://my-satellite-server' ],
  }
```

Theres also some other edge cases that can be solved with this pattern, when you need to make certain resources absent based on a flexible criteria (eg: you don't know the exact titles) you can't just declare them with ensure set to absent, so if you wanted to remove any package based on a pattern match of it's name you'd do

```puppet
  purge { 'package':
    if => [ 'name', '=~', '^acme-devel-' ],
  }
```

## Compatibility and limitations.

Purge is compatible with Puppet 3.6+. although there are some minor limitations between versions, these are explained below.

### Resource relationships

Purge will set the same resource relationships on resources it purges as it has itself.   Eg: `purge { 'yumrepo': notify => Exec['yum_clean_all'] }` will cause all the purged resources to be in state, notifying the exec resource to run after. Due to [PUP-1963](https://tickets.puppetlabs.com/browse/PUP-1963) the resource relationships will be ignored in Puppet versions lower than 4.3.  See "Dependencies" below;

### Configuring from hiera

Purge also has a Puppet class for reading in data from hiera and automatically creating the purge resources.  This requires Puppet 4.x or higher; See "Configure from hiera" below;

### Compatibility summary

| Puppet Version | Purge resource type | Configure from hiera |Dependencies |
| -------------- | ------------------- | -------------------- | ----------- |
| 4.0           | Yes | Yes | No |
| 4.1           | Yes | Yes | No |
| 4.2           | Yes | Yes | No |
| 4.3           | Yes | Yes | Yes |
| 4.4           | Yes | Yes | Yes |
| 4.5+           | Yes | Yes | Yes |
| 5.0+           | Yes | Yes | Yes |





## Parameters

### if / unless

Purge resources only if or unless they meet the criteria.

Criteria is defined as an array of "parameter", "operator", and "value".

```puppet
   if => [ 'name', '==', 'root' ]
```

Operators can support `!=`,`==`,`=~`,`>`,`<`,`<=` and `>=` as an arguments

Value can be a string, integer or regex (without the enclosing slashes) depending on the operator that you are using.  Note that '==' will always be a string comparrason whereas arethmetic operators such as '<=' will attempt to convert the values to integers before comparrison (if possible)

Multiple criterias can be nested in an array, eg:

```puppet
   purge { 'user':
     unless => [
       [ 'name', '==', 'root' ], 
       [ 'name', '=~', '^admin' ]
     ]
  }
```

The value of a criteria can also be an array, when an array, purge will repeat the test once for each element of the array, eg:

```puppet
  if => [ 'name', '==', [ 'admin', 'root', 'nobody' ]]
```

has the same effect as

```puppet
  if => [
    [ 'name', '==', 'root' ],
    [ 'name', '==', 'admin' ],
    [ 'name', '==', 'wheel' ],
  ]
```

This is fairly useful in puppet, especially puppet 3, where you want to exclude based on array, eg:

```puppet
   $exclude_users = [ 'root', 'admin', 'wheel' ]

   purge { 'user':
     unless => [ 'name', '==', $exclude_users ]
   }
```

## Advanced parameters

### `manage_property`

By default, purge will try and purge the resource using the `ensure` parameter.  This attribute allows you to override which property gets managed for the resource type.

### `state`

By default, purge will try and set the attribute defined in `manage_property` to `absent`. This behaviour can be overridden here to set the property with a different value.  When used in conjunction with `manage_property` you can define different behaviours rather than all out destruction of resources.  Eg:

```puppet
  # Don't delete unmanaged mounts, just make sure they are not mounted.

  purge { 'mount':
    'state' => 'unmounted',
  }
```

```puppet
  # If we find users that are not managed by puppet, then we should set the shell to nologin

  purge { 'user':
    'manage_property' => 'shell',
    'state'           => '/bin/nologin',
  }
```

## Configuring from Hiera

Purge contains a Puppet class to read in a hash of `resources` and automatically generate purge resources.  Eg:

```yaml
purge::resources:
  user:
    if: [ 'uid', '>', '500' ]
```

```
include purge
```

## Isomorphism

Purge is not an isomorphic resource, that means that although the resource titles must be unique, you can declare seperate resource declarations to manage the same resource type by using the `resource_type` namevar

```puppet
  purge { 'all users in GID 999':
    resource_type => 'user',
    if => [ 'gid', '==', '999' ],
  }

  purge { 'all users above uid 5000':
    resource_type => 'user',
    if => [ 'uid', '>', '5000' ],
  }
```

## Mixing `if` and `unless`

If you have a mixture of if and unless, then it's important to understand the behaviour.  `unless` is evaluated first, and if a condition is found that matches `unless`, then the resource will not be purged regardless of what you have in `if`.   For example;

```puppet
  purge { 'user':
    if     => [ 'uid', '>', '9000' ],
    unless => [ 'name', '==', 'admin' ],
  }
```

In this example, the admin user will never be purged regardless of it's UID  as it will be evaluated in the `unless` block, any other user that matches the `if` block will be purged.

The exception to this rule is using two separate resource declarations using the non-isomorphic features of the type.  Each resource declaration evaluates independantly, so if you declare the following;

```puppet
  purge { 'above 9000':
    resource_type => 'user',
    if => [ 'uid', '>', '9000' ],
  }

  purge { 'unless admin':
    resource_type => 'user',
    unless => [ 'name', '==', 'admin' ],
  }
```

In the above example, if the user `admin` has a UID above 9000 it will be purged.  This is because the first resource declaration in this example is evaluated separately from the second and identifies the resource as purgable.  The second resource evaluates it as non-purgable, but that is a non-action (eg: do nothing)

   
    

## Safe usage notes

If you've read this far I hope you have an idea of what purging actually does, just to clarify, it removes things from your system.  Further more, it removes things from your system that Puppet had no knowledge about so re-recreating them after the fact may not be so easy.   It's important to verify carefully the values that you pass into if and unless.   Consider this example;

```puppet
class foo ( Optional[Hash] $purge_opts = {} ) {
  purge { 'user':
    * => $purge_opts
  }
}
```

If you are using the above pattern to source the options from Hiera, you probably don't want to be doing things like allowing an empty default.  Consider what's going to happen if you tweak your hiera.yaml in such a way that stops this data from getting looked up?  Such errors normally result in things *not* being configured, in this case, it's quite the oposite.


## Author

Written and maintained by Craig Dunn <craig@craigdunn.org> (@crayfishx)

##

Licensed under the Apache 2.0 license.  See LICENSE for details.
