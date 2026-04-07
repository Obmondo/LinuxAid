# e2e Testing

## Overview

The `e2e/` directory provides an isolated testing environment for catalog-diff scenarios. It uses a stub ENC (`enc.rb`) that returns fixed parameters without making any API calls, and local Hiera data so tests run entirely offline.

## Directory structure

```
e2e/
├── enc.rb                           # Stub ENC — returns fixed params, no API
├── hiera.yaml                       # Hiera config pointing at e2e/ data
├── global.yaml                      # Defaults (monitoring off, no full mgmt)
└── facts/
    ├── role-basic.e2etesting.yaml      # Agent facts
    └── role-monitoring.e2etesting.yaml # Agent facts
```

## Certname convention

e2e certnames follow the pattern `<scenario>.<customerid>`, using `.e2etesting` as the customer suffix:

```
role-basic.e2etesting
role-monitoring.e2etesting
myfeature.e2etesting
```

## Running catalog-diff in e2e mode

The main entry point is `bin/catalog-diff.sh`. It runs the diff inside a Docker container.

```bash
# Compare a single host
./bin/catalog-diff.sh --e2e --hostname role-basic.e2etesting

# Compare multiple hosts
./bin/catalog-diff.sh --e2e --hostname host1 --hostname host2

# Compare between branches
./bin/catalog-diff.sh --e2e --hostname role-basic.e2etesting --from master --to <branch>

# Force re-fetching facts and pull latest Docker image
./bin/catalog-diff.sh --e2e --hostname host1 --no-cache --pull
```

### Options

- `--e2e`: Required. Use local facts, ENC, and Hiera config.
- `--hostname <name>`: The Puppet certname to diff. Can be used multiple times.
- `--from <ref>` / `--to <ref>`: Git references for the base and target catalogs.
- `--ci`: Enable CI mode (Markdown summary for GitHub Actions).
- `--pull`: Pull the latest Docker image before running.
- `--quiet`: Minimize non-essential output.
- `--no-cache`: Force re-fetching facts via SSH even if they exist locally.
- `--format-as FMT`: Output format. Options: `pretty` (default), `json`.
- `--debug`: Keep temporary catalogs and facts in `.catalog-diff-debug/`.
- `--config-repo <path>`: Use a customer config repo for Hiera data.
- `--kube-context <context>`: Kubernetes context to fetch eyaml keys from.

## Node facts for catalog-diff

octocatalog-diff reads node facts from local YAML files in `e2e/facts/` instead of
querying PuppetDB (controlled by the `PUPPET_FACT_DIR` env var set in `bin/catalog-diff.sh`).

### Seeding / refreshing facts

The script `bin/catalog-diff.sh` will automatically attempt to fetch facts via SSH if they are missing locally. You can also manually refresh them:

```bash
# Fetch facts via SSH (requires sudo on the remote node)
bin/fetch-node-facts <certname>
```

This writes `e2e/facts/<certname>.yaml` in Puppet YAML format (`name` + `values`).
Commit the resulting file so CI and other developers can run catalog-diff without SSH access.

### Testing a fact change

Edit a value in `e2e/facts/<certname>.yaml`, then re-run catalog-diff:

```bash
# e.g. change the osfamily fact and see catalog impact
$EDITOR e2e/facts/<certname>.yaml
./bin/catalog-diff.sh --e2e --hostname <certname>
```
