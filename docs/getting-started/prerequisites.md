# Prerequisites

Check these before you start. The [overview](README.md) explains the three paths.

## A fresh server

Install LinuxAid on a server you just created. LinuxAid applies a few resources even in a report-only run:

- On every server with a role, it adds Obmondo's package repository at `repos.obmondo.com`, creates the `obmondo` group, and creates directories under `/etc/obmondo` and `/opt/obmondo`. On Ubuntu and Debian, the repository is `/etc/apt/sources.list.d/obmondo_custom_<codename>.list` with its key in `/etc/apt/keyrings/`, and LinuxAid also writes two apt settings files, `/etc/apt/preferences` and `/etc/apt/apt.conf.d/15update-stamp`.
- On roles with full host management, it writes `/etc/puppetlabs/facter/facts.d/obmondo_system.yaml`, puts the line `127.254.254.254 <certname>` in `/etc/hosts`, and rewrites `/etc/ssh/sshd_config` with `PasswordAuthentication no` and `PermitRootLogin forced-commands-only`. `role::kubeaid` gets none of these. Full host management is on by default for every role except `role::basic` and `role::monitoring`, and off for every role on TurrisOS and armv7l.
- On roles with full host management and sudo management, it deletes `/usr/bin/sudoedit`, sets every file in `/etc/sudoers.d` to mode 0440, and adds `/etc/sudoers.d/999_sudoers_include_obmondo`. Sudo management is off until you set `common::user_management::authentication::manage` and `common::user_management::authentication::manage_sudo` to `true`.

On a server you already use, the SSH rewrite can lock you out. With full host management, an enforced run also deletes every key in `/root/.ssh/authorized_keys` that LinuxAid doesn't manage, except on `role::kubeaid`. If you log in as root with a key, add `common::system::purge_root_ssh_keys: false` to the server's settings file.

## Root access

Every command in this guide runs as root, and `linuxaid-install` refuses to run as any other user.

## Operating system

All three paths install the OpenVox agent with `linuxaid-install`, which outside TurrisOS works only on amd64 and arm64:

| Operating system | What `linuxaid-install` does |
|---|---|
| Ubuntu 22.04, 24.04, 26.04 | Installs the agent |
| RHEL, CentOS Stream, Rocky Linux, Oracle Linux 8 and 9 | Installs the agent built for the major version |
| SUSE Linux Enterprise 15 | Installs the agent |
| Debian, Ubuntu 20.04 | Fails to install the agent. For path 1, install `openvox-agent` yourself first, following [Installing OpenVox](https://voxpupuli.org/openvox/install/). `linuxaid-install --masterless` then skips that step |
| AlmaLinux | Refuses it as an unknown distribution |
| TurrisOS | See the [Turris guide](../../docs/guides/linuxaid-turris-install.md) |

## Network access

The server needs outbound HTTPS to:

- GitHub, for the install script, the `linuxaid-cli` release and LinuxAid itself
- `repos.obmondo.com`, for the OpenVox agent package and Obmondo's package repository
- for path 2, your OpenVox server on port 443
- for path 3, `api.obmondo.com`, Obmondo's Prometheus server and Obmondo's OpenVox server, on port 443. The Prometheus server is `prometheus.obmondo.com` by default. `linuxaid-cli` skips the run when it can't reach one of them.

## Disk space

`linuxaid-install` stops unless `/` has more than 100 MB free and `/boot` more than 10 MB.

## Tools

The install script needs `curl` and `jq`, and path 1 needs `git` to clone LinuxAid.

## systemd-resolved

LinuxAid configures DNS through systemd-resolved on Ubuntu, Debian, SUSE Linux Enterprise 15, RHEL 9, CentOS Stream 9, Rocky Linux 9 and Oracle Linux 9. On a server without systemd-resolved and with systemd older than 258, the configuration fails to compile with `Could not find resource 'Service[systemd-resolved]' in parameter 'notify'`. The run then changes nothing.

Stock Ubuntu 22.04, 24.04 and 26.04 server and cloud images include it. On the other systems, install systemd-resolved if it is missing.

## Path 2: your own OpenVox server

You need an OpenVox server that serves agents over HTTPS on port 443, and a way to sign their certificates. [Installation](installation.md#path-2-your-own-openvox-server) lists the rest.

## Path 3: Obmondo

You need an account on [obmondo.com](https://obmondo.com). The installer comes from obmondo.com, with a token for your server.
