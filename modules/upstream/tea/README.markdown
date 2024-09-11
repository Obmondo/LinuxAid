#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

:tea: Types: Abstracted & Extracted

This module provides a set of Puppet 4.4+ compatible datatypes for use of validation in defined types and class declarations.

## Module Description

The basic idea behind this module is to retire [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)'s `validate_XYZ()` functions. Unlike `validate_()`, these datatypes can be verified by the parser, instead of being validated during compilation.

Installing this module will make it so that puppet [auto-loads](https://docs.puppet.com/puppet/4.4/reference/release_notes.html#type-aliases) all types defined in `types/`

## Reference

### Network related types

* type HTTPUrl -- matches http/https URLs
* type HTTPSUrl -- matches https URLs
* type Port -- all valid TCP/UDP ports
* type Privilegedport  -- ports which need rootly power to bind to
* type Unprivilegedport  -- ports which do not need rootly power

### Filesystem types

* type UnixPath  -- paths on Unix-like operating systems

### Other types

* type AWSRegion -- valid AWS region name (eg 'us-east-1')
* type EmailAddress -- somewhat naive email validator
* type Syslogfacility -- valid syslog facilities: see `man syslog(3)` for a complete list
* type Syslogpriority -- valid syslog priorities: see `man syslog(3)` for a complete list

## Limitations

This module is compatible with any platform puppet 4.4+ is compatible with.

## Development

Please see CONTRIBUTING.md for how this module is developed, and how you can help.
