## 1.2.0

### New features

* Purge resource now passes on it's metaparameters (notify, before...etc) to the resources it purges.  Note due to PUP-1963 this will not have an effect in Puppet < 4.3

* Purge now supports two new attributes, `state` and `manage_property`.  `state` can be used to define a state other than `absent` for a resource, for example, to unmount mounts instead of deleting them from the config.  You can now use purge to set any desired state of a resource by combining `manage_property` with `state` to manage other properties.  See the README for more details.

* Purge puppet class added to enable auto generation of purge resources from Hiera data

### Enhancements

* Purge will now use the `.should=()` method of the types property to change the state, This means that user defined values will be passed through the types property validation.  For example if you try and set a state for a resource that it doesnt support, Puppet will correctly error;

```
Puppet::Error: Invalid value :obliterated. Valid values are present, absent, role.
```

* The purge resource itself now signals a changed state when it purges resources, rather than remaining silent and unchanged.  This is useful output to make it obvious that purge has altered resources

```
Notice: /Stage[main]/Main/Purge[user]/ensure: ensure changed 'purgable' to 'purged'
```
 
## 1.1.0

* Added support for array values to criteria https://github.com/crayfishx/puppet-purge/pull/3

### 1.0.1

* Ruby 1.8.7 support

# 1.0.0

* Added many more spec tests
* Namevar changed from `name` to `resource_type`
* Added non-isomorphic behaviour
* Documentation updates



