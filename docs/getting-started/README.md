# Getting started with LinuxAid

LinuxAid is a ready-made OpenVox setup for Linux servers. It comes with roles that say what a server is for, and a `common` module with settings that any server can use. You describe each server in Hiera data, a directory of YAML files that you own, and OpenVox makes the server match it.

## What you get

- The OpenVox agent on each server, installed by `linuxaid-install`.
- LinuxAid's roles and settings. The [roles reference](../../modules/enableit/role/REFERENCE.md) lists most roles, and the [common settings reference](../../modules/enableit/common/REFERENCE.md) lists the settings that work on any server.
- One settings file per server, `agents/<certname>.yaml`, where you pick its roles and change its settings.
- Report-only runs by default. `linuxaid-cli run-openvox` prints what it would change and makes those changes only when you add `--enforce`. The exception is the few resources that [Prerequisites](prerequisites.md#a-fresh-server) lists, which LinuxAid applies on every run.

## Three ways to install

| | 1. One server, masterless | 2. Your own OpenVox server | 3. Obmondo |
|---|---|---|---|
| What you need | Root on one server | An OpenVox server that agents reach on port 443 | An account on [obmondo.com](https://obmondo.com) |
| Monitoring | Off in the installation steps | On by default, sending metrics to Obmondo's Prometheus server | Obmondo's monitoring |
| Scheduled runs | None until you add [a cron job](installation.md#later-runs) | Hourly | Hourly |
| Cost | Free and open source | Free and open source | An Obmondo subscription |
| Docs | Every step | Requirements only | Every step |

## Which path to pick

Start with path 1. It needs nothing but the server. It shows you what LinuxAid does before you enforce anything, apart from the few resources that [Prerequisites](prerequisites.md#a-fresh-server) lists. Each server keeps its own copy of LinuxAid and its own settings. Past a handful of servers, that gets tedious.

Move to path 2 when you want one place that holds LinuxAid and the settings for all your servers.

Pick path 3 if you want Obmondo to run the OpenVox server, collect the metrics and schedule system updates in service windows. You choose roles on obmondo.com and run one command on each server.

## The steps

1. [Prerequisites](prerequisites.md) covers what the server needs and which operating systems the installer supports.
2. [Installation](installation.md) walks through paths 1 and 3, and lists what path 2 needs.
3. [Post-configuration](post-configuration.md) covers roles, settings for groups of servers, secrets and keeping LinuxAid up to date.
