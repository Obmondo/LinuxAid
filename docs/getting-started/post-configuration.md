# Post-configuration

These steps assume the masterless layout from [path 1](installation.md#path-1-one-server-masterless), where your settings live in `/opt/obmondo/openvox/code/hiera-data/main`. On your own OpenVox server, Hiera reads these files from `hiera-data/main` next to its `environments` directory. The classifier looks for `tags.yaml` relative to the server's working directory instead.

## Give the server a role

> **Check SSH before you add a role.** Full host management is on by default for every role except `role::basic` and `role::monitoring`, and off for every role on TurrisOS and armv7l. With it on, even a report-only run rewrites `/etc/ssh/sshd_config` with `PasswordAuthentication no` and `PermitRootLogin forced-commands-only`, unless the role leaves SSH alone, as `role::kubeaid` does. Make sure you can still log in with those settings, or add `common::user_management::sshd::manage: false` to leave SSH alone. An enforced run also deletes every key in `/root/.ssh/authorized_keys` that LinuxAid doesn't manage, except on `role::kubeaid`. If you log in as root with a key, also add `common::system::purge_root_ssh_keys: false`.

A server's roles are the `classes` list in its file, `agents/<certname>.yaml`. LinuxAid checks the list on every run and stops if it has:

- more than two classes
- `role::monitoring` together with anything else
- more than one role that can't be combined with others

The [roles reference](../../modules/enableit/role/REFERENCE.md) lists most roles with their parameters, and the [role pages](../../docs/roles/README.md) describe the common ones. Set a parameter in the same file as `<class>::<parameter>: <value>`.

On a masterless server, keep `common::system::openvox::manage: false` and `common::monitor::enable: false` whatever the role. [Installation](installation.md#step-3-add-linuxaid-and-your-settings) explains why.

### Full host management

With full host management on, LinuxAid also runs the `common` module's system, user management, storage, network, software, logging and backup classes, each with its own switches in the [common settings reference](../../modules/enableit/common/REFERENCE.md). To turn it on for `role::basic`, add `common::full_host_management: true`.

You can also change the two SSH settings with `common::user_management::sshd::password_authentication` and `common::user_management::sshd::permit_root_login`. The [full host management page](../../docs/roles/full_host_management.md) has more.

## Settings for more than one server

`global.yaml` and `common.yaml` in `hiera-data/main` apply to every server. Between those and the server's own file, `hiera.yaml` has levels keyed on facts, for example `agents/facts/os.family=Debian.yaml` for every Debian-family server. [`hiera.yaml`](../../hiera.yaml) lists them all, most specific first.

### Tags

`tags.yaml` in `hiera-data/main` puts servers under named tags:

```yaml
webservers:
  - web01.example
  - web02.example
```

The classifier gives each server the tags it is listed under. For each of the server's tags, Hiera reads `agents/tags/<tag>.yaml` and `agents/tags/<tag>/os.family=<family>,os.release.major=<major>.yaml`, for example `os.family=Debian,os.release.major=24.04.yaml` on Ubuntu 24.04. When two tags set the same key, a per-OS tag file beats a plain one. Between two files of the same kind, the tag listed first in `tags.yaml` wins. A server with tags and no `classes` gets LinuxAid's base role, with full host management.

The classifier reads `tags.yaml` relative to the directory you run `linuxaid-cli` from, which is why the installation steps run it from the environment directory.

## Secrets

LinuxAid reads every settings file through eyaml, so you can encrypt any value. OpenVox decrypts with the key pair at:

- `/etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem`
- `/etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem`

The `eyaml createkeys` command from [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml) writes a new pair to `./keys`. Copy both files to `/etc/puppetlabs/puppet/eyaml/keys` on the machine that compiles the catalog: the server itself on path 1, the OpenVox server on path 2. Keep the private key out of Git, since it decrypts every secret. The [eyaml guide](../../docs/guides/eyaml.md) shows how to encrypt a value with `bin/eyaml.sh`, which looks for the public key at `var/public_key.pkcs7.pem` in your LinuxAid checkout.

## Report-only and enforcing runs

`linuxaid-cli run-openvox` is report-only unless you add `--enforce`:

| Command | What it runs |
|---|---|
| `linuxaid-cli run-openvox --apply --hiera-config ''` | `puppet apply --noop` on the server |
| `linuxaid-cli run-openvox --apply --hiera-config '' --enforce` | `puppet apply`, which changes the server |
| `linuxaid-cli run-openvox` | `puppet agent -t --noop` against the server in `puppet.conf`, on paths 2 and 3 |
| `linuxaid-cli run-openvox --enforce` | `puppet agent -t --no-noop` |

Read the report before every `--enforce`, and after every LinuxAid update.

## Keep LinuxAid up to date

The checkout in `environments/master` follows LinuxAid's `master` branch. To update it:

```sh
git -C /opt/obmondo/openvox/code/environments/master pull
```

Then do a report-only run before you enforce. To stay on a release instead, check out its tag in the same directory, for example `v1.8.16`. `git pull` fails once a tag is checked out. To move to a newer release, run `git fetch --tags`, then check out the newer tag.

To try a new version next to the one you run, clone it as a second environment and pass its name with `-E`:

```sh
git clone https://github.com/Obmondo/LinuxAid.git /opt/obmondo/openvox/code/environments/next
cd /opt/obmondo/openvox/code/environments/next
linuxaid-cli run-openvox --apply --hiera-config '' -E next
```

Both environments read the same settings in `hiera-data/main`.

If you keep your own fork of LinuxAid, the [updates guide](../../docs/guides/updates.md) shows how to update or add the upstream modules it carries in `modules/Puppetfile`.
