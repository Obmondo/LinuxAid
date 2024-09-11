[![Build Status](https://travis-ci.org/bi4o4ek/puppet-opendkim.svg?branch=master)](https://travis-ci.org/bi4o4ek/puppet-opendkim)

# opendkim

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with opendkim](#setup)
    * [Beginning with opendkim](#beginning-with-opendkim)
    * [Add domains for signing](#add-domains-for-signing)
    * [Add allowed hosts](#add-allowed-hosts)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The opendkim module allows you to set up mail signing and manage DKIM services with minimal effort.

## Module Description

OpenDKIM is a widely-used DKIM service, and this module provides a simplified way of creating configurations to manage your infrastructure.
This includes the ability to configure and manage a range of different domain, as well as a streamlined way to install and configure OpenDKIM service.

## Setup

### What opendkim affects

* configuration files and directories (created and written to) 
* package/service/configuration files for OpenDKIM
* signing domains list
* trusted hosts list

### Beginning with opendkim

To install OpenDKIM with the default parameters

    include opendkim

### Add domains for signing

    opendkim::domain{['example.com', 'example.org']:}


### Add allowed hosts

    opendkim::trusted{['10.0.0.0/8', '203.0.113.0/24']:}

## Usage

For example.
There is internal ip 10.3.3.80 and external ip 203.0.113.100 on our mail-relay host with OpenDKIM.
This host signs all mails for domains example.com and example.org.

    # Postfix-relay
    class{ 'postfix::server':
        inet_interfaces              => '10.3.3.80, localhost',
        mynetworks                   => '10.0.0.0/8, 203.0.113.0/24',
        smtpd_recipient_restrictions => 'permit_mynetworks, reject_unauth_destination',
        smtpd_client_restrictions    => 'permit_mynetworks, reject',
        mydestination                => '$myhostname',
        myhostname                   => 'relay-site.example.com',
        smtpd_banner                 => 'Hello',
        extra_main_parameters        => {
            smtp_bind_address     => '203.0.113.100',
            smtpd_milters         => 'inet:127.0.0.1:8891',
            non_smtpd_milters     => '$smtpd_milters',
            milter_default_action => 'accept',
            milter_protocol       => '2',
        },
    }

    # OpenDKIM
    include opendkim
    opendkim::domain{['example.com', 'example.org']:}
    opendkim::trusted{['10.0.0.0/8', '203.0.113.0/24']:}

After puppet-run you need to copy contents of  /etc/opendkim/keys/example.com/relay-site.txt and paste into corresponding DNS-zone as TXT.
Then repeat this action for example.org

Puppet module for postfix in this example is [thias/postfix](https://forge.puppetlabs.com/thias/postfix) v0.3.3
## Reference

Puppetlabs are working on automating this section.

## Limitations

This module is tested on:
* CentOS 6
* Ubuntu 12.04
* Ubuntu 14.04

## Development

Fork me on github and make pull request.

