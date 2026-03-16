## External Node Classifier (ENC)

### Overview

The ENC (`puppet_enc.rb`) is the script that Puppet Server calls to determine
a node's environment, parameters, and tags. It is configured in `puppet.conf`:

```ini
[server]
node_terminus = exec
external_nodes = /etc/puppetlabs/code/environments/production/puppet_enc.rb
```

### Why the ENC lives on the production branch

Each environment under `/etc/puppetlabs/code/environments/` is a full git
clone checked out at a specific tag (e.g. `v1_5_3`). Puppet Server's
`external_nodes` setting points to a **single, fixed path** — it cannot
dynamically select an ENC per environment.

Because of this, `puppet_enc.rb` always runs from the `production` environment.
It calls the API to determine the node's actual environment (via
`linuxaid_tag`), and returns it in the YAML output. Puppet Server then uses
that environment to load the correct `environment.conf`, modulepath, and Hiera
data from the corresponding environment directory.

If the ENC needs to be fixed or updated, only the `production` environment's
copy needs to change — making it a single point of maintenance.

### Branch naming: master == production

The `master` branch in git corresponds to the `production` environment on the
Puppet Server. This mapping is handled by `gfetch`, which clones/checks out
the `master` branch into the `production` environment directory. When a node
has no `linuxaid_tag` set (or the tag is empty), the ENC falls back to the
`production` environment.
