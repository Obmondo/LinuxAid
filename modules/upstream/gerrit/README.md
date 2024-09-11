# Gerrit Module

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with gerrit](#setup)
    * [What gerrit affects](#what-gerrit-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gerrit](#beginning-with-gerrit)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

[![Build Status](https://travis-ci.org/tykeal/puppet-gerrit.png)](https://travis-ci.org/tykeal/puppet-gerrit)

This module installs and configures a Gerrit system. It is intended to
work with Puppet >= v3.7 as that is what it is developed against.

## Module Description

The Gerrit module provides an easy way of standing up a
[Gerrit](https://code.google.com/p/gerrit/) server, an open source web
based code review system.

The optional MySQL integration works with the puppetlabs-mysql module to
export a database configuration for automatic pick-up and creation of
the database. If this option is desired the the database server will be
probed to see if it is available before starting the Gerrit service.
Because of this, it's possible to see some failed puppet runs until
everything is operational.

The module may optionally modify the firewall for the web and ssh
services.

You may optionally manage your Gerrit site Header, Footer and CSS as
well as the static resources.

## Setup

### What gerrit affects

* The gerrit service will be installed and managed
* May optionally install java (NOTE: java is required for Gerrit to work)
* May optionally install git (NOTE: git is required for Gerrit to work)
* Gerrit site Header, Footer and CSS may be optionally managed. If they
  are not managed then dummy files will be put in place (also optional)
  so that adding managed files later will not require a restart.
* May optionally install gitweb
* May optionally manage the firewall rules for access to Gerrit
  resources
* May optionally handle setting up the database (potential cross-system
  dependencies)

### Setup Requirements

* `puppetlabs/git` is required for the optional git installation. If you
  wish to manage git via a different module / method make sure to set
  $manage_git to false
* `puppetlabs/java` >= v1.2.0 is required for the optional java
  installation. If you wish to use manage java via a different module /
  method make sure to set $manage_java to false
* `puppetlabs/mysql` >= 3.0.0 is required for the optional MySQL management
  as well as having store configs enabled.
* `puppetlabs/firewall` >= 1.2.0 is required for the optional firewall
  management

### Beginning with gerrit

```puppet
class { 'gerrit': }
```

## Usage


## Reference


## Limitations

Tested against RedHat / CentOS v7
