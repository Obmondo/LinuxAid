# e2e Testing

## Overview

The `e2e/` directory provides an isolated testing environment for catalog-diff scenarios. It uses a stub ENC (`enc.rb`) that returns fixed parameters without making any API calls, and local Hiera data so tests run entirely offline.

## Directory structure

```
e2e/
├── enc.rb                           # Stub ENC — returns fixed params, no API
├── hiera.yaml                       # Hiera config pointing at e2e/ data
├── global.yaml                      # Defaults (monitoring off, no full mgmt)
└── agents/
    ├── role-basic.e2etesting.yaml      # Assigns role::basic
    └── role-monitoring.e2etesting.yaml # Assigns role::monitoring
```

## Certname convention

e2e certnames follow the pattern `<scenario>.<customerid>`, using `.e2etesting` as the customer suffix:

```
role-basic.e2etesting
role-monitoring.e2etesting
myfeature.e2etesting
```

## Adding a new test agent

Create `e2e/agents/<certname>.yaml` with the desired classes:

```yaml
# e2e/agents/myfeature.e2etesting.yaml
classes:
  - role::basic
  - mymodule::myclass
```

## Running catalog-diff in e2e mode

```bash
./bin/catalog-diff.sh --e2e --hostname role-basic.e2etesting
./bin/catalog-diff.sh --e2e --hostname role-basic.e2etesting --from HEAD --to <branch>
```

## Node facts for catalog-diff

octocatalog-diff reads node facts from local YAML files in `e2e/facts/agents/` instead of
querying PuppetDB (controlled by the `PUPPET_FACT_DIR` env var set in `bin/catalog-diff.sh`).

### Seeding / refreshing facts

Run `bin/fetch-node-facts` on a machine with PuppetDB access (requires the e2e certs):

```bash
AUTOSIGN_CLIENT_CERT=e2e/.certs/role-basic.e2etesting.pem \
AUTOSIGN_CLIENT_KEY=e2e/.certs/role-basic.e2etesting.key \
AUTOSIGN_CA_CERT=e2e/.certs/ca.pem \
bin/fetch-node-facts <certname>
```

This writes `e2e/facts/agents/<certname>.yaml` in Puppet YAML format (`name` + `values`).
Commit the resulting file so CI and other developers can run catalog-diff without VPN access.

### Testing a fact change

Edit a value in `e2e/facts/agents/<certname>.yaml`, then re-run catalog-diff:

```bash
# e.g. change the osfamily fact and see catalog impact
$EDITOR e2e/facts/agents/<certname>.yaml
./bin/catalog-diff.sh --e2e --hostname <certname>
```
