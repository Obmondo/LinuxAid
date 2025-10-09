# Transition

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module provides a Puppet type and provider for describing conditional
transition states. It allows users to describe a scenario where prior to
performing a change, a temporary state should be invoked.

## Module Description

Consider the following scenario.

The desired end state is that the `myapp` service is running, and that the
`myapp.cfg` file has some specific content. In Puppet this can be modeled with
the following code.

````puppet
file { '/etc/myapp/myapp.cfg':
  ensure  => file,
  content => 'enabled=1',
  notify  => Service['myapp'],
}

service { 'myapp':
  ensure => running,
  enable => true,
}
````

The `myapp` service, however, is sensitive to the configuration file being
changed while it is running. In order to ensure consistency, its developers
recommend that the configuration file not be changed while the application is
running.

Puppet is designed to model end state, and by default it cannot model the
desired procedure of shutting down `myapp`, modifying `myapp.cfg`, and then
starting `myapp` back up.

The transition module provides a new type that can be used to express
*intermediate state*, thus modeling transactions such as

1. stop service
2. modify configuration
3. start service

## Usage

Conceptually, the transition type specifies two things. First, it specifies a
desired transition state in the form of a Puppet resource reference and
parameters for that resource. Second, it specifies an array of other resources
in the catalog, for which this temporary transition state should be invoked
prior to changing.

### Example Usage

In relation to the problem laid out above in the Module Description, the
transition type is used used as follows.

````puppet
transition { 'stop myapp service':
  resource   => Service['myapp'],
  attributes => { ensure => stopped },
  prior_to   => File['/etc/myapp/myapp.cfg'],
}

file { '/etc/myapp/myapp.cfg':
  ensure  => file,
  content => 'enabled=1',
  notify  => Service['myapp'],
}

service { 'myapp':
  ensure => running,
  enable => true,
}
````

### Attributes

#### resource

The resource for which a transitional state is being defined. This should be a
resource reference (e.g. `Service['apache']`). This resource will be made to
autorequire the transitional state.

#### attributes

The hash of attributes to set on the resource when applying a transitional
state. Each hash key must be a valid attribute for the resource being
transitioned.

#### prior_to

An array of resources to check for synchronization. If any of these resources
are out of sync (change pending), then the transition state will be applied.
These resources will each be made to autorequire the transitional state.

## Reference

The transition type operates by performing a look-ahead operation on the
catalog to determine whether or not to create and apply a transient
single-resource state.

The type automatically adds a `before` edge to each resource in the `prior_to`
parameter, and a `before` edge to the resource specified in the `resource`
parameter.

When evaluated, the transition provider will retrieve each resource specified
in the `prior_to` hash from the catalog, and for each resource, invoke each
managed property's`insync?` method. If any of the resources are found to have
any properties out of sync, the transition resource will apply the transitional
state defined by the resource and attribute parameters.

By requiring that the `resource` parameter refer to a resource that exists in
the catalog, there should always exist a desired state which is enforced
following the transition.

## Limitations

### The resource parameter must refer to a native type

The `resource` parameter may only refer to a native type, it cannot refer to a
defined type. This is because the transition provider operates on the catalog,
and does not have or assume access to the original Puppet manifest(s) that
build defined types.

### Resources given to `prior_to` should not specify noop

While the transition resource operates correctly with the global noop flag set
either true or false, it does not currently check each individual `prior_to`
resource to determine if the individual resource is noop. Therefore, do not at
this time specify resources in the `prior_to` parameter that use the noop
metaparameter.

### Do not transition resources that use resource generators

The current implementation of the transition type performs resource transitions
by invoking the equivalent of `puppet resource <type> <parameters=values>`.
Notably, this state change operation is done outside the scope of the current
catalog. For most resources and types this works just fine, but resources
invoked in a way that trigger additional resource generation (`generate` and
`eval_generate` methods) may have unexpected behavior if a transition using
them is attempted.

**tl;dr:** DO NOT attempt to transition a file resource that has either
`recurse=true` or `purge=true`. There may exist other conditions under which a
resource should not be transitioned, but we haven't thought of or found them
yet.
