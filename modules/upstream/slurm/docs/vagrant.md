-*- mode: markdown; mode: visual-line; -*-

# Slurm Puppet Module Tests with Vagrant

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
[Vagrant](http://vagrantup.com/) uses [Oracle's VirtualBox](http://www.virtualbox.org/)
to build configurable, lightweight, and portable virtual machines dynamically.

* [Reference installation notes](http://docs.vagrantup.com/v2/installation/) -- assuming you have installed [Oracle's VirtualBox](http://www.virtualbox.org/)
* [installation notes on Mac OS](http://sourabhbajaj.com/mac-setup/Vagrant/README.html) using [Homebrew](http://brew.sh/) and [Cask](http://sourabhbajaj.com/mac-setup/Homebrew/Cask.html)

The `Vagrantfile` at the root of the repository pilot the provisioning of a virtual cluster configuring Slurm from the puppet provisionning capability of Vagrant over _this_ module.
In particular, by default, the following boxes will be deployed upon `vagrant up`:

* `slurm-master`: 1 Slurm controller (_i.e._ a head node (running the `slurmctld` daemon) as well as the Slurm accounting DB _i.e._ `slurmdbd`)
* `access`: 1 login node
* `node-[1-2]`: 2 compute nodes (running the `slurmd` daemon)

Of course, if you simply want to make a quick test on slurm.conf parameters, you simply need to deploy the `slurm-master` VM as follows:

```
vagrant up slurm-master
```

You can change the default settings of the deployment by overwriting them in the special file `tests/vagrant/config.yaml` (see `config.yaml.sample` as an example of all the settings you can pilot).
More precisely, the [Hiera hierachy](https://github.com/ULHPC/puppet-slurm/blob/devel/tests/vagrant/puppet/hiera.yaml) places `hieradata/custom.yaml` (not tracked by default in the Git repository) at the highest hierachy to allow for quick and fast tests.

For instance, to deploy 4 compute nodes instead of 2, you just need to use:

```yaml
# -*- mode: yaml; -*-
# Time-stamp: <Fri 2019-02-01 16:13 svarrette>
################################################################################
# Complementary configuration for Vagrant
# You can overwrite here the default settings defined in ../../Vagrantfile and
# rework the SLURM configuration and VM deployed (i.e. the characteristics of
# the virtual cluster deployed)
# See config.yaml.sample for all possible settings

:defaults:
  :nnodes: 4
```

You can also tweak the slurm partitions of their TRES settings. Ex:

```yaml
:defaults:
  :nnodes: 4

# Which Trackable RESources (TRES) will be tracked in addition to
# billing, cpu, energy, memory and node
slurm::accountingstorageTRES: gres/gpu,gres/gpu:volta

slurm::partitions:
  'DEFAULT':
    TRESbillingweights: 'CPU=1.0,Mem=0.25G,GRES/gpu=15.0'
    content: State=UP AllowGroups=clusterusers AllowAccounts=ALL DisableRootJobs=YES OverSubscribe=NO
  'admin':
    priority: 100
    nodes: 'node-[1-4]'
    content: Hidden=YES DefaultTime=0-10:00:00 MaxTime=5-00:00:00 MaxNodes=UNLIMITED  AllowQos=qos-admin
  'interactive':
    priority: 20
    nodes: 'node-1'
    content: DefaultTime=0-1:00:00  MaxTime=0-4:00:00  AllowQos=qos-besteffort,qos-interactive DefMemPerCPU=400 MaxMemPerCPU=400
  'batch':
    priority: 20
    nodes: 'node-[2-4]'
    content: DefaultTime=0-2:00:00  MaxTime=5-00:00:00 MaxNodes=UNLIMITED Default=YES AllowQos=qos-besteffort,qos-batch DefMemPerCPU=400 MaxMemPerCPU=400
```

Then you just need to provision the VMs using the [vagrant puppet apply  provisionning](https://www.vagrantup.com/docs/provisioning/puppet_apply.html)


         vagrant provision --provision-with puppet [slurm-master]

## Default cluster deployment

By default, the following boxes are deployed:

```
$> vagrant status
Current machine states:

slurm-master   not created (virtualbox)
access         not created (virtualbox)
node-1         not created (virtualbox)
node-2         not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

$> vagrant up
[...]
+--------------|--------------------------|---------|----------|------------|-------------------------------|-------------+
|                                    Puppet Testing infrastructure deployed on Vagrant                                    |
+--------------|--------------------------|---------|----------|------------|-------------------------------|-------------+
| Name         | Hostname                 | OS      | vCPU/RAM | Role       | Description                   | IP          |
+--------------|--------------------------|---------|----------|------------|-------------------------------|-------------+
| slurm-master | slurm-master.vagrant.dev | centos7 | 2/2048   | controller | Slurm Controller #1 (primary) | 10.10.1.11  |
| access       | access.vagrant.dev       | centos7 | 1/1024   | login      | Cluster frontend              | 10.10.1.2   |
| node-1       | node-1.vagrant.dev       | centos7 | 2/512    | node       | Computing Node #1             | 10.10.1.101 |
| node-2       | node-2.vagrant.dev       | centos7 | 2/512    | node       | Computing Node #2             | 10.10.1.102 |
+--------------|--------------------------|---------|----------|------------|-------------------------------|-------------+
- Virtual Puppet Testing infrastructure deployed deployed!
```

You can ssh into any of the deployed machine afterwards:

```bash
$> vagrant ssh [slurm-master | access | node-1 | node-2]
```

## Vagrant boxes provisioning

When you run `vagrant up <name>` to boot the VM, the following default provisioning are applied (shell scripts are located in `tests/vagrant/scripts/`):

| Script                          | Type   | Description                                                                   |
|---------------------------------|--------|-------------------------------------------------------------------------------|
| `bootstrap.sh`                  | shell  | Install puppet 4 and defaults packages and gems                               |
| `puppet_modules_setup.rb`       | shell  | pre-install the necessary puppet modules in `tests/vagrant/puppet/modules/`   |
| `setup_testing_users_groups.sh` | shell  | setup testing group `clusterusers` and users `user-[1-2]`                     |
|                                 | puppet | `default.pp`, profile-based deployment depending on the `role`                |
| inline                          | shell  | create cluster and qos for the slurm accounting (if role is `controller`)     |
| `setup_slurm_accounting.sh`     | shell  | create cluster, default account and a set of users in the slurm accounting DB |
|                                 |        |                                                                               |

It is worth to note the way the `puppet_modules_setup.rb` script behaves as this script is responsible for two main tasks:

1. pre-install the puppet modules listed as dependencies in `metadata.json` using [`librarian-puppet`](https://librarian-puppet.com/) under `tests/vagrant/puppet/modules/`
2. make the appropriate symbolic link `tests/vagrant/puppet/modules/slurm` (pointing to `/vagrant`) to ensure you can directly make changes and correct your own module transparently within the box.

## Testing manifests

You can test the manifests of the `tests/` directory within the VM:

      $> vagrant ssh <name>
      [...]
      (vagrant)$> sudo puppet apply -t /vagrant/tests/init.pp

From now on, you can test (with --noop) the other manifests.
