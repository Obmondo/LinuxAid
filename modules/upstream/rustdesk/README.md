<!-- markdownlint-disable-file MD041 -->
<!-- markdownlint-disable MD033 -->
<div align="center">

# puppet-rustdesk

*Deploy RustDesk client and self-hosted server components (`hbbs`/`hbbr`) across your infrastructure with a single Puppet class*

[![Latest Release](https://img.shields.io/github/v/release/Obmondo/puppet-rustdesk?sort=semver&label=release)](https://github.com/Obmondo/puppet-rustdesk/releases)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Obmondo/puppet-rustdesk?label=stars)](https://github.com/Obmondo/puppet-rustdesk/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/Obmondo/puppet-rustdesk)](https://github.com/Obmondo/puppet-rustdesk/commits/main)

*Maintained by [Obmondo](https://obmondo.com)*

</div>
<!-- markdownlint-enable MD033 -->

---

## Upstream References & Resources

- **Upstream Project (GitHub)**: [rustdesk/rustdesk](https://github.com/rustdesk/rustdesk)
- **RustDesk Server Pro**: [rustdesk/rustdesk-server-pro](https://github.com/rustdesk/rustdesk-server-pro)
- **Official Website**: [rustdesk.com](https://rustdesk.com)

---

## Features

- **Automated Client & Server Deployment**: Manages installation of RustDesk desktop client and self-hosted server components (`hbbs` ID server and `hbbr` relay server) via `.deb` packages.
- **Multi-Architecture Support**: Supports both AMD64 (`x86_64`) and ARM64 (`aarch64`) architectures seamlessly.
- **Dependency Management**: Automatically installs required X11, Wayland, and GStreamer graphic libraries for clients, and system packages for servers.
- **Flexible Configuration**: Control client and server independently via class parameters or Hiera.

---

## Module Parameters & Configuration Reference

### Class: `rustdesk`

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `rustdesk::client_enable` | `Boolean` | `false` | Whether to enable and manage the RustDesk client component. |
| `rustdesk::client_version` | `SemVer` | `"1.4.9"` | The version of the RustDesk client to install. |
| `rustdesk::client_extra_dependencies` | `Array[String]` | `[]` | Additional OS packages required for the client. |
| `rustdesk::server_enable` | `Boolean` | `false` | Whether to enable and manage the RustDesk server components (`hbbs` / `hbbr`). |
| `rustdesk::server_version` | `SemVer` | `"1.8.6"` | The version of the RustDesk server to install. |
| `rustdesk::server_extra_dependencies` | `Array[String]` | `[]` | Additional OS packages required for the server. |

---

## Ports Used (Server Components)

- **Port 21115 (TCP)**: NAT test
- **Port 21116 (TCP/UDP)**: ID registration and heartbeat service (`hbbs`)
- **Port 21117 (TCP)**: Relay service (`hbbr`)
- **Port 21118 & 21119 (TCP)**: Web socket / HTTP tunneling

---

## Usage Examples

### 1. Enable Client Only

```puppet
class { 'rustdesk':
  client_enable  => true,
  client_version => '1.4.9',
  server_enable  => false,
}
```

### 2. Enable Server Only

```puppet
class { 'rustdesk':
  client_enable  => false,
  server_enable  => true,
  server_version => '1.8.6',
}
```

### 3. Hiera Configuration (`data/common.yaml`)

```yaml
---
rustdesk::client_enable: true
rustdesk::client_version: '1.4.9'
rustdesk::server_enable: false
```

---

## Limitations & Support

- **Operating Systems**: Currently supports Ubuntu (`22.04`, `24.04`, and `26.04`).
- **Architectures**: Supports `amd64`/`x86_64` and `arm64`/`aarch64`.
