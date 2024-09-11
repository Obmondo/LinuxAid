motd
====

Overview
--------
This module populates `/etc/motd` with the contents of a simple template file. 

Module Description
-------------------
The MOTD module demonstrates how to utilize templates within a module class and provides a means with which to experiment with the puppet module tool.

Setup
-----

**What MOTD affects:**

* contents of `etc/motd`   

Motd utilizes the contents of `motd/motd.erb` to populate `etc/motd`. You must declare the class to use it:

	include motd


Usage
------

MOTD allows you to use the default contents of the template, customize the template, drop your own template into the templates folder, or specify a template in a different location. 

If you would like to change the location of the template: 

    class { 'motd':
      template => 'mymodule/mytemplate.erb',
    }

If you would like to provide a static string as the MOTD content you can use the content parameter:

    class { 'motd':
      content => 'Hello!',
    }

Limitations
------------

Platforms : Linux

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)
