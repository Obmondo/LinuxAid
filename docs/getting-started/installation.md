# Installation

Each path starts on a server that meets the [prerequisites](prerequisites.md). This page has every step for paths 1 and 3, and lists what path 2 needs.

## Path 1: one server, masterless

The server compiles and applies its own configuration with `puppet apply`, so you need no OpenVox server. When you are done, `/opt/obmondo/openvox/code` holds LinuxAid and your settings:

```text
/opt/obmondo/openvox/code
├── environments/master    LinuxAid
└── hiera-data/main        your settings
    └── agents
        └── web01.example.yaml
```

### Step 1: install the LinuxAid tools

```sh
apt-get update && apt-get install -y ca-certificates curl git jq
curl -fsSL https://raw.githubusercontent.com/Obmondo/linuxaid-cli/main/install.sh | bash
```

On RHEL, CentOS Stream, Rocky Linux and Oracle Linux 8 or 9, replace the first line with `dnf install -y git jq`, and install curl if `curl --version` fails. On version 9, also install [systemd-resolved](prerequisites.md#systemd-resolved) if the server doesn't have it. Without it, LinuxAid's configuration fails to compile. On SUSE Linux Enterprise 15, install git, curl and jq with zypper instead of the first line.

`install.sh` finds the latest `linuxaid-cli` release on GitHub, checks the download against the SHA-256 digest GitHub publishes for it, and puts `linuxaid-install` and `linuxaid-cli` in `/usr/local/bin`. It runs neither of them.

### Step 2: install the OpenVox agent

```sh
linuxaid-install --certname web01.example --masterless
```

Replace `web01.example` with a name for this server. It becomes the server's certname, which names its settings file in step 3. OpenVox accepts it only in lowercase.

With `--masterless`, `linuxaid-install`:

1. checks that it runs as root, on a supported system, with enough disk space
2. writes `/etc/obmondo/opensource-mode`, which tells `linuxaid-cli` to skip Obmondo's API
3. unless `/opt/puppetlabs/bin/puppet` is already there, installs `iptables`, installs `openvox-agent` 8.32.0 from `repos.obmondo.com`, and stops and disables the `puppet` service
4. writes `/etc/puppetlabs/puppet/puppet.conf` with the certname and no server

It asks no questions and is safe to run again.

### Step 3: add LinuxAid and your settings

```sh
git clone https://github.com/Obmondo/LinuxAid.git /opt/obmondo/openvox/code/environments/master
mkdir -p /opt/obmondo/openvox/code/hiera-data/main/agents
cat > /opt/obmondo/openvox/code/hiera-data/main/agents/web01.example.yaml <<'EOF'
classes:
  - role::basic
common::system::openvox::manage: false
common::monitor::enable: false
EOF
```

The file gives the server `role::basic` and switches off two things a masterless server can't use:

- `role::basic` adds no services. On Ubuntu it sets up journald and DNS through systemd-resolved and installs the systemd-resolved NSS libraries, which makes it a small first run. [Post-configuration](post-configuration.md) covers giving the server more to do.
- `common::system::openvox::manage: false` stops LinuxAid from managing the agent. Otherwise, an enforced run rewrites `puppet.conf` to point at Obmondo's server, `enableit.puppet.obmondo.com`, and adds an hourly timer that runs the agent against it.
- `common::monitor::enable: false` stops LinuxAid from installing a Prometheus agent that sends metrics to `prometheus.obmondo.com`. That agent logs in with the server's OpenVox certificate, and a masterless server has none.

### Step 4: run in report-only mode

```sh
cd /opt/obmondo/openvox/code/environments/master
linuxaid-cli run-openvox --apply --hiera-config ''
```

- `--apply` runs `puppet apply` on this server, with LinuxAid's [`linuxaid_enc.rb`](../../linuxaid_enc.rb) as the node classifier.
- `--hiera-config ''` drops the extra Hiera layer that `linuxaid-cli` reads by default from `/opt/obmondo/openvox/hiera.yaml`. That file only exists on nodes that LinuxAid's Kubernetes operator manages. LinuxAid's own `hiera.yaml` still applies.

Without `--enforce`, OpenVox runs with `--noop`. It compiles the configuration and prints each change. Lines that end in `(noop)` are pending changes that step 5 makes.

`linuxaid-cli` exits 0 even when the run fails, so read the output. A clean run prints a line like `Notice: Applied catalog in 1.06 seconds`. The run failed if it prints a `level=ERROR` line or `puppet run succeeded, but with failures`. On a masterless server, expect a Facter error about `clientcert_pem`.

If the output says `Missing role on web01.example`, OpenVox found no `classes` for the server. Compare the file name from step 3 with the `certname` in `/etc/puppetlabs/puppet/puppet.conf`.

### Step 5: apply the changes

```sh
linuxaid-cli run-openvox --apply --hiera-config '' --enforce
```

### Later runs

`linuxaid-install --masterless` sets up no schedule, and with `common::system::openvox::manage: false` LinuxAid adds none either. OpenVox runs only when you run step 4 or step 5 from the environment directory. Run them again after you change your settings or [update LinuxAid](post-configuration.md#keep-linuxaid-up-to-date).

To run step 4 every hour and keep its output, add a cron job:

```sh
cat > /etc/cron.d/linuxaid <<'EOF'
0 * * * * root cd /opt/obmondo/openvox/code/environments/master && /usr/local/bin/linuxaid-cli run-openvox --apply --hiera-config '' >> /var/log/linuxaid-cli.log 2>&1
EOF
```

Read the log as step 4 describes. To apply the changes, run step 5 by hand. `/opt/puppetlabs/puppet/public/last_run_summary.yaml` covers only runs whose catalog compiled, so an older summary there can hide a failed run.

## Path 2: your own OpenVox server

The setup steps for this path are not written yet. Your OpenVox server needs:

- LinuxAid checked out as an environment, for example `master` in its environment path. Agents choose the environment for each run, and `linuxaid-cli` asks for `master` unless told otherwise.
- `linuxaid_enc.rb` from that checkout as its external node classifier. It gives each node `hiera_datapath`, its tags, and the monitoring and subscription flags. Without them, `hiera.yaml` has no `hiera_datapath` to find your settings under, and `site.pp` has no `$obmondo_monitor`, `$obmondo_tags` or `$subscription`.
- The environment's own `environment.conf`, which puts `modules/enableit` and `modules/upstream` on the module path.
- Your settings in `../../hiera-data/main`, relative to the environment directory: `agents/<certname>.yaml` for each node, `common.yaml` for all of them, and `tags.yaml`.
- An environment directory as its working directory, for example `WorkingDirectory=/etc/puppetlabs/code/environments/master` in its systemd unit. `linuxaid_enc.rb` opens `tags.yaml` relative to the OpenVox server's working directory. If the file isn't there, it hands out no tags and gives no error.
- `common::system::openvox::server` set to your server in those settings. LinuxAid writes each agent's `puppet.conf` from it, and the default is Obmondo's `enableit.puppet.obmondo.com`.
- `common::monitor::enable: false` in those settings, unless you want metrics to go to Obmondo. Monitoring is on by default and sends them to `prometheus.obmondo.com`.
- The eyaml key pair in `/etc/puppetlabs/puppet/eyaml/keys/` on the OpenVox server, readable by its `puppet` user. `hiera.yaml` decrypts where the catalog compiles, not on the agents.
- HTTPS on port 443. `linuxaid-install` checks `https://<server>/status/v1/services` before it installs anything, and both `linuxaid-install` and LinuxAid set `masterport = 443` on the agents.
- A way to sign the agents' certificates. The `puppet_autosign.rb` in this repository asks Obmondo's API, so it does not work for your own server.

## Path 3: Obmondo

To see these steps before you start, watch the setup videos on [obmondo.com/get-started](https://obmondo.com/get-started).

1. On obmondo.com, open [Add server](https://obmondo.com/user/servers/add-server).
2. Work through its steps: name the server, select a configuration, configure its settings and add a subscription. obmondo.com builds the certname from the hostname and your organisation id.
3. At the last step, copy the install command and run it on the server as root. It has this shape, with your token and certname filled in:

   ```sh
   export TOKEN='<generated for your server>' && export CERTNAME='web01.your-org' && curl -sL -H "token=$TOKEN" -o /tmp/linuxaid-install "https://api.obmondo.com/api/servers/install?token=$TOKEN&certname=$CERTNAME&arch=$(uname -m)" && chmod +x /tmp/linuxaid-install && /tmp/linuxaid-install
   ```

The installer asks you to confirm, checks the token with Obmondo and installs the OpenVox agent. It stops and disables `unattended-upgrades` and the `puppet` service, points the agent at Obmondo's OpenVox server with `noop = true`, and does a first report-only run.

With a subscription, LinuxAid then adds a timer that runs the agent about once an hour, and the server shows up on [your servers page](https://obmondo.com/user/servers), where you change its roles and settings. To keep its settings in your own Git repository, follow [Git setup](../../docs/setup/git_setup.md).
