# translate

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with translate](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors](#contributors)

## Module description

This module provides the `translate` function for Puppet. Wrapping a string in this function will mark it to be picked up by gettext and put into the .pot file for translation purposes. Currently, we are **only marking failures, errors, and warnings** in Puppet Supported modules. Feel free to do what you like with your own. 

## Setup

Install this module with the Puppet Module Tool:
```shell
puppet module install puppetlabs-translate
```

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-translate/blob/master/REFERENCE.md)

## Limitations

We do not yet support pluralization.

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

## Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-translate/graphs/contributors](https://github.com/puppetlabs/puppetlabs-translate/graphs/contributors).
