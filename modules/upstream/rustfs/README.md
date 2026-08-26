<!-- markdownlint-disable-file MD041 -->
<!-- markdownlint-disable MD033 -->
<div align="center">

# puppet-rustfs

*Deploy RustFS - S3 backup storage - across your infrastructure with a single Puppet class*

[![Latest Release](https://img.shields.io/github/v/release/Obmondo/puppet-rustfs?sort=semver&label=release)](https://github.com/Obmondo/puppet-rustfs/releases)
[![License: AGPL v3](https://img.shields.io/badge/license-AGPL--3.0-orange)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Obmondo/puppet-rustfs?label=stars)](https://github.com/Obmondo/puppet-rustfs/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/Obmondo/puppet-rustfs)](https://github.com/Obmondo/puppet-rustfs/commits/main)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Obmondo/puppet-rustfs)

*Maintained by [Obmondo](https://obmondo.com)*

</div>
<!-- markdownlint-enable MD033 -->

---

## Upstream References & Resources

- **Upstream Project (GitHub)**: [rustfs/rustfs](https://github.com/rustfs/rustfs)
- **Official Website**: [rustfs.org](https://rustfs.org)
- **Container Image**: [Docker Hub](https://hub.docker.com/r/rustfs/rustfs) / [GHCR](https://ghcr.io/rustfs/rustfs)
- **Hiera Eyaml (Vox Pupuli)**: [voxpupuli/hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml)

---

## Features

- **Automated Docker & Docker Compose Setup**: Installs and manages required container runtimes via puppetlabs/docker.
- **S3-Compatible Object Storage**: Exposes high-performance S3 APIs for backup clients like Velero, PostgreSQL backup utilities, and [Kubeaid](https://kubeaid.io) clusters.
- **Secure Authentication**: Manages S3 Access Keys and Secret Access Keys securely via class parameters or Hiera / eyaml.
- **Directory Validation**: Enforces pre-mounted data storage requirements with strict permissions.

---

## Data Directory & Permissions (`data_dir`)

RustFS runs containers mapped to an internal user requiring correct UID/GID permissions on the host mount (`10001`).

Before applying this module, ensure your backup data directory is mounted and configured with correct permissions:

```bash
# 1. Create the mount directory
sudo mkdir -p /mnt/backups/rustfs

# 2. Set ownership for RustFS user (UID/GID 10001)
sudo chown -R 10001:10001 /mnt/backups/rustfs

# 3. Set directory permissions
sudo chmod 755 /mnt/backups/rustfs
```

---

## Module Parameters & Configuration Reference

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `rustfs::enable` | `Boolean` | `false` | Whether to enable and manage the RustFS deployment. |
| `rustfs::version` | `String[1]` | `"1.0.0-rc.3"` | The version tag of the `rustfs/rustfs` container image. |
| `rustfs::container_image` | `String[1]` | `"rustfs/rustfs"` | The container image repository name. |
| `rustfs::data_dir` | `Stdlib::Unixpath` | `"/opt/rustfs/data"` | Host directory where backup data is stored (must be pre-mounted). |
| `rustfs::access_key` | `String[1]` | `"admin"` | S3 Access Key ID for authentication. |
| `rustfs::secret_key` | `String[1]` | `"admin"` | S3 Secret Access Key for authentication (recommended via eyaml). |
| `rustfs::env_vars` | `Hash` | `{}` | Additional environment variables passed to the RustFS container. |

---

## Ports Used

- **Port 9000 (S3 API / Data Port)**: Used by backup clients (Velero, PostgreSQL backup jobs, [Kubeaid](https://kubeaid.io) clusters) for all S3 read/write and backup object transfers.
- **Port 9001 (Web Console / Management UI)**: Used for accessing the web-based management interface.

---

## Usage Examples

### 1. Direct Class Declaration in Puppet Manifest

```puppet
class { 'rustfs':
  enable     => true,
  data_dir   => '/mnt/backups/rustfs',
  version    => '1.0.0-rc.3',
  access_key => 'your-access-key',
  secret_key => 'your-secret-key',
}
```

### 2. Hiera Configuration (`data/common.yaml`) with Eyaml

For production and secure environments, secrets like `rustfs::secret_key` should be encrypted using [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml).

You can generate an encrypted string for your secret key using the `eyaml` CLI tool:

```bash
eyaml encrypt -s "your-super-secret-key"
```

This will output a PKCS7 block (`ENC[...]`) which you can paste directly into your Hiera YAML configuration:

```yaml
---
rustfs::enable: true
rustfs::version: '1.0.0-rc.3'
rustfs::container_image: 'rustfs/rustfs'
rustfs::data_dir: '/mnt/backups/rustfs'
rustfs::access_key: 'my-backup-admin'
rustfs::secret_key: 'ENC[PKCS7,MIIB7AYJKoZIhvcNAQcDoIIB3TCCAdkCAQAxggF7MIIBewIBADAFMAAC...]'
rustfs::env_vars:
  RUSTFS_LOG: 'info'
```

---

## Limitations & Support

- **Operating Systems**: Currently supports Ubuntu (`22.04`, `24.04`, `26.04`).
- **Data Mount Constraint**: The data directory (`data_dir`) must be pre-mounted and managed by system-level configuration; the module will fail if the directory is missing.
