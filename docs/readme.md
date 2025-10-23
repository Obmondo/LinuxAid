# LinuxAid 

A platform for everything you need to run a secure and reliable Linux operations setup

## Config options

Under each module that you use in linuxaid-config tree - you can see the documentation for it the corresponding REFERENCE.md file - following the Puppet standard way of documenting modules.

For LinuxAid we have built these modules:

- [Roles](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/role/REFERENCE.md) - the list of roles (software and configs we support currently). Note some roles support mixing - so multiple roles cannot always be assigned to a server, as they can conflict.
- [Common settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md) - the list of common configurations you can rollout for any server, regardless of its configured role.
- [Monitoring settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/monitor/REFERENCE.md) - settings for monitoring

## Security and Reliability

### Supply Chain Security

For Supply Chain Security we have built an [open source repository server](https://gitea.obmondo.com/EnableIT/LinuxAid/src/branch/master/modules/enableit/role/REFERENCE.md#role--package_management--repo).

It supports mirroring any upstream mirror you need to use for your servers - so you can run airgapped - and servers don't need internet access to function and be maintainable. It also enables staged rollouts.

It also has a daemon called packagesign, a separate open source project we wrote, that supports automatically pulling built rpm or deb packages from gitea, gitlab etc. build jobs - and gpg signing and adding them to your own repository.

This is part of a design to protect against any single-point-of-compromise affecting you.

To do this, you need to gpg sign all commits on your branches, that builds these packages/releases (easily setup in .gitconfig) - and then on your runners (which are separate from and not managed by your Githost) - you need to enable it to run a security check, that validates ALL gpg signatures on the git repo cloned - before the CI job is allowed to run.

This protects against a compromised Githost - as they can inject code into your repo.. but once thats cloned by a runner - the job will not be allowed to run.

This way - they cannot sneak anything into your release packages.

### Staged rollouts

Using our reposerver role, you can enable automatic snapshots - which will simply make hardlink based snapshots of all repositories, so that you can split your servers into groups, and assign a snapshot to 1 group at a time, and roll out security updates to them.

You can do the same for your LinuxAid configuration (the puppet and/or hiera tree) if you want - by simply making git branches or tags - and locking servers to an environment.

## Monitoring

LinuxAid includes monitoring of everything we have ever needed for any customer we have had.
That includes hardware monitoring of hardware from Dell, HP, IBM, Supermicro etc. - and we constantly add support and gladly accept PRs :)

Because LinuxAid is built on Puppet (Now OpenVox - the Open Source community fork), it automatically detects your hardware and everything else on your system, using a system called 'facts' - of which there's 1000's - and configures your server according to these facts, with the right monitoring (and everything else).

We run the LinuxAid setup under a Kubernetes setup - documented in KubeAid (see below details link) - and this CAN be spun Pup on a single-host Linux server if you want, but it means you can have a High availability setup, very easily.
See the technical details on monitoring here: https://github.com/Obmondo/LinuxAid/blob/master/docs/monitoring.md