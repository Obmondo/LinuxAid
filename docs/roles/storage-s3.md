# S3 Object Storage Role (`role::storage::s3`)

## Overview

The `role::storage::s3` class deploys an S3-compatible object storage
server (MinIO) using Docker Compose, complete with automated bucket
initialization and access policy scripts.

## Components

- **MinIO S3 Server**: Lightweight, high-performance S3-compatible
  object storage daemon.
- **Initialization Script**: Automated creation of S3 buckets and access
  policies on startup.
- **Docker Compose Integration**: Managed via systemd and Docker Compose.

## Usage

Assign the role to a storage node in Hiera:

```yaml
classes:
  - role::storage::s3
```

## Configuration

Configure S3 credentials and buckets via Hiera (`eyaml` recommended):

```yaml
profile::storage::s3::access_key: 'admin'
profile::storage::s3::secret_key: >
  ENC[PKCS7,...]
profile::storage::s3::default_buckets:
  - 'backups'
  - 'logs'
```

## Related Documentation

- [Roles Reference](./README.md)
- [Eyaml Guide](../guides/eyaml.md)
