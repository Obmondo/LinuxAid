pam_access
=============

[![Build Status](https://travis-ci.org/MiamiOH/puppet-pam_access.svg)](https://travis-ci.org/MiamiOH/puppet-pam_access)
[![Puppet Forge](https://img.shields.io/puppetforge/v/MiamiOH/pam_access.svg)](https://forge.puppet.com/MiamiOH/pam_access)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/MiamiOH/pam_access.svg)](https://forge.puppet.com/MiamiOH/pam_access)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/MiamiOH/pam_access.svg)](https://forge.puppet.com/MiamiOH/pam_access/scores)

This module manages **pam_access** entries stored in `/etc/security/access.conf`.  It
requires Augeas >= 0.8.0.

Sample usage:

    class { 'pam_access':
      exec => true,
    }

    pam_access::entry { 'mailman-cron':
      user   => 'mailman',
      origin => 'cron',
    }

    pam_access::entry { 'root-localonly':
      permission => '-',
      user       => 'root',
      origin     => 'ALL EXCEPT LOCAL',
    }

    pam_access::entry { 'lusers-revoke-access':
      create => false,
      user   => 'lusers',
      group  => true,
    }
