# puppet-rustfs

Maintained by [Obmondo](https://obmondo.com).

## Description

This module manages the deployment of `rustfs` as an S3-compatible backup storage target using Docker Compose.

## Setup

### What rustfs affects

* Installs Docker and Docker Compose packages.
* Creates the `/opt/obmondo/docker-compose/rustfs` directory.
* Manages the `/opt/obmondo/docker-compose/rustfs/docker-compose.yml` file.
* Runs the `rustfs` container using Docker Compose.

### Ports Used

* **Port 9000 (S3 API / Data Port)**: Used by backup clients (Velero, PostgreSQL backup jobs, [Kubeaid](https://kubeaid.io) clusters) for all S3 read/write and backup object transfers.
* **Port 9001 (Web Console / Management UI)**: Used for accessing the web-based management interface.

### Beginning with rustfs

To get started, ensure your data directory is pre-mounted, then include the class:

```puppet
class { 'rustfs':
  enable     => true,
  data_dir   => '/mnt/backups/rustfs',
  version    => '1.0.0-rc.2',
  access_key => 'your-access-key',
  secret_key => 'your-secret-key',
}
```

## Usage

You can configure the module via Hiera. Secrets (`secret_key`) should be managed using `eyaml`.

### Common Hiera Configuration (`data/common.yaml`)

```yaml
---
rustfs::enable: true
rustfs::version: '1.0.0-rc.2'
rustfs::container_image: 'rustfs/rustfs'
rustfs::data_dir: '/mnt/backups/rustfs'
rustfs::access_key: 'my-backup'
rustfs::secret_key: 'ENC[PKCS7,...]'
rustfs::env_vars:
  SOME_EXTRA_VAR: 'value'
```

## Limitations

* Currently only supports Ubuntu.
* Requires the data directory (`data_dir`) to be pre-mounted and managed by system-level configuration; the module will fail if the directory is missing.
