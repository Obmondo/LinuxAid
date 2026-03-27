# OpenVAS Puppet/OpenVox module

## Description

This module manages an OpenVAS (Greenbone Community Edition) deployment using
Docker Compose.

It creates and manages:

- OpenVAS compose directory and compose file
- Docker Compose stack lifecycle (`docker_compose { 'openvas': ... }`)
- Firewall rule for OpenVAS web interface exposure
- Docker engine and Docker Compose plugin (by default)

## Setup

### Beginning with openvas

```puppet
include openvas
```

## Usage

### Default usage

```puppet
include openvas
```

### Set admin password declaratively (recommended)

The admin password for GVMD can be set declaratively using the `admin_password`
parameter. **Important:** Always provide this value through Hiera with eYAML
encryption, never in plain text in your Puppet manifests.

#### Step 1: Generate eYAML keys (one-time setup)

If your Hiera setup doesn't already have eYAML keys, generate them:

```bash
# Create keys directory (should be outside version control)
mkdir -p /etc/puppetlabs/puppet/eyaml/keys

# Generate PKCS7 key pair
eyaml createkeys \
  --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem \
  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem
```

**Important:** 
- Keep the private key secure and never commit it to version control
- The public key can be shared in your repository
- Back up both keys securely

#### Step 2: Encrypt your password

```bash
# Encrypt your desired password
echo "YourSecurePassword123!" | eyaml encrypt \
  --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem \
  --stdin \
  --output=string
```

This outputs an encrypted string like:
```
ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQEw...]
```

#### Step 3: Add to Hiera data

In your node's Hiera YAML file (e.g., `hiera-data/nodes/myserver.yaml`):

```yaml
---
openvas::admin_password: >-
  ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQEw...]
```

Make sure your `hiera.yaml` is configured to use the eyaml lookup key for
encrypted data:

```yaml
hierarchy:
  - name: 'encrypted'
    lookup_key: eyaml_lookup_key
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem
      pkcs7_public_key: /etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem
    paths:
      - "nodes/%{trusted.certname}.yaml"
```

Then include the class in your manifest:

```puppet
include openvas
```

The password will be automatically set in the GVMD service via the `PASSWORD`
environment variable.

### Change existing admin password

If you already have OpenVAS running and want to change the password:

**Option A: Declarative (recommended for future deployments)**

1. Add `openvas::admin_password` to your Hiera data as shown above
2. Run Puppet to apply the change

**Option B: Imperative (for existing deployments)**

```bash
docker compose -f /opt/openvas/docker-compose.yml exec \
  -u gvmd gvmd gvmd --user=admin --new-password='YourNewPassword'
```

Then add the password to Hiera (as shown above) to make it declarative.

### Disable Docker management (if handled elsewhere)

```puppet
class { 'openvas':
  manage_docker => false,
}
```

### Install but keep web interface private

```puppet
class { 'openvas':
  install => true,
  expose  => false,
}
```

### Disable and remove managed resources

```puppet
class { 'openvas':
  install => false,
}
```

### Override compose settings

```puppet
class { 'openvas':
  compose_dir          => '/opt/openvas',
  feed_release         => '24.10',
  web_port             => 9392,
}
```

Notes:

- The compose file path is derived automatically as
  `${compose_dir}/docker-compose.yml`.
- `web_port` controls only the firewall rule port.
- The GSA container bind is fixed to `127.0.0.1:9392` in the managed compose
  template.
- Compose content changes (for example environment variable updates like
  `admin_password`) are applied through the managed `docker_compose` resource
  during Puppet runs.

## Limitations

- Built and tested for Ubuntu (22.04, 24.04).
- By default (`manage_docker => true`) this module manages Docker and Docker
  Compose plugin.
- If you set `manage_docker => false`, Docker and Docker Compose plugin must
  already be present.

## Development

Run checks with PDK:

```bash
pdk validate
pdk test unit
```
