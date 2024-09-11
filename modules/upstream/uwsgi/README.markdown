# Uwsgi Puppet Module

[![Build Status](https://travis-ci.org/cwood/puppet-uwsgi.svg)](https://travis-ci.org/cwood/puppet-uwsgi)
![Puppet Forge Version](https://img.shields.io/puppetforge/v/cwood/uwsgi.svg)
![Puppet Forge Score](https://img.shields.io/puppetforge/f/cwood/uwsgi.svg)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with uwsgi](#setup)
    * [What uwsgi affects](#what-uwsgi-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with uwsgi](#beginning-with-uwsgi)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module will support uwsgi through a emporer mode on both Debian and Redhat
based families. This is actully a fork of [Engage/puppet-uwsgi](https://github.com/Engage/puppet-uwsgi) with some updates to overall style, unit testing
and updating to include a more modern design pattern. This also includes
support for uwsgi for-readline and removes having to setup support for redhat
manually.

## Module Description

Setup and configure uwsgi in a emporer mode with support for vassels.

## Setup

### What uwsgi affects

* uwsgi, /etc/uwsgi.ini, and a app folder to set your uwsgi vassals

### Beginning with uwsgi

To setup it should be as easy as `include uwsgi` this setup does assume you are
managing python through a different module and that you have pip, and python
development packages installed.

For a good python module checkout [stankevich/python](https://forge.puppetlabs.com/stankevich/python)

To install apps you can call it via hiera with

```yaml
---
uwsgi::apps:
    myapp:
        application_options:
            virtualenv: /var/virtualenvs/myapp
            chdir: /var/www/html/myapp
            master: true
            logto: /var/log/uwsgi/myapp.log
            ...
```

## Usage

Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

## Limitations

Does not support zerg mode, also needs support for systemd based config files.

## Development

To help you just need to fork the repository, and then do a `bundle install` ,
and `bundle exec rake test`. Every pull request will run through all rspec
tests.
