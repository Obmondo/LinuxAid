# Decisions made

In this document we've documented the decisions we have made and why.
These are based on decades of experience with large scale operations by our senior staff - and hopefully helps others
to understand the experience from real world issues - that these decisions are based on.

## Puppet has been great.. but

Puppet has been a great tool - that I've used since 2008 - for building system configuration management for larger environments.
It never came as a turnkey solution.. you had to write decide and write your own roles, profiles or whatever structure you decided. You had to setup a puppetdb UI - to have a nice CMDB UI, and you had to setup eyaml, hiera, octocatalog-diff etc. - IF you knew that all these great extensions existed.

I did all that - but as a consultant - my work was owned by the customer I wrote it for. That meant for me, that the next customer who needed to manage their environment, I had to redo all those things again - as copyright of my work belonged to the previous customer. It also meant that IF I did it better the second time, I couldn't share this with my previous customer.

We started using Puppet for more customers, some very small - running our own puppet server setup - so we could share it with everyone, so it also benefitted the small customers with only a very few servers - without the cost multiplying for each customer to build their own environment.

This is what became LinuxAid - a turnkey Puppet - now OpenVox - setup to give you everything you need to start managing your servers and systems.

to make this more configurable - and re-usable - we've build a set of options for "anything you pretty much need anywhere" - but which doesn't belong in a role. We called that the "common" module. Same for monitoring options - which we called the "monitoring" module.

We've also instrumented these roles, used the wonderful features of the DSL - with proper typing, custom specific types created and so on - so you can build a UI - by simply generating a JS validator for the exposed classes if you want :)

Our hope is we can collaborate on making it even easier to get started with OpenVox - and collaborating on a complete solution, incl. design decisions of roles, profiles etc. - benefitting everybody.