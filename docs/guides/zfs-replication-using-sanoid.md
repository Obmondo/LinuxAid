# ZFS Replication Guide (Using Sanoid)

This guide covers ZFS replication setup using the [sanoid puppet module](https://github.com/Obmondo/puppet-sanoid), including data migration, pool management, and syncoid replication between two or more systems.

## Overview

[Sanoid](https://github.com/jimsalterjrs/sanoid) is a policy-driven snapshot management tool for ZFS filesystems that automates the creation, pruning, and monitoring of snapshots based on configurable policies

## Setup

### Production Server Configuration

In your `linuxaid-config`, configure the production server with the zfs pool configs. Plus, you need to provide the public SSH key of the backup server where the replication needs to takes place.

Update the ZFS pool names in the `zfs::pools` configurations.

The `template` can be configured based on [sanoid templates](https://github.com/Obmondo/puppet-sanoid/blob/main/data/common.yaml#L11) we've already defined. You can also create your own template as well.

`production-server.yaml`

```yaml
...
common::storage::zfs::allow_sync_from:
  - '<SSH public key of backup server>'
common::storage::zfs::pools:
  '<pool 1>':
    template: production
    recursive: true
  '<pool 2>':
    template: production
    recursive: true
```

### Backup Server Configuration

Similarly, the backup server configurations needs to be defined with the correct source (in our case, it's the production server).

backup-server.yaml

```yaml
...
common::storage::zfs::pools:
  '<pool 1>':
    template: backup
    recursive: true
  '<pool 2>':
    template: backup
    recursive: true
common::storage::zfs::replications:
  'rapid':
    source: '<production server name>'
  'slow':
    source: '<production server name>'
```

## Apply The Changes

After making these configuration changes, run puppet agent, and the Linuxaid will take care of the rest.
