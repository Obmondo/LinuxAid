# HAProxy 3.2+ Native ACME Manual Domain Setup

## Overview

When managing HAProxy 3.2+ with built-in native ACME via LinuxAid, domains are normally provisioned declaratively through Puppet/OpenVox configuration. However, if you need to quickly add a domain (or multiple SANs under a single domain group) manually for troubleshooting or emergency deployment without running a full Puppet catalog, you can do so by provisioning placeholder certificates and updating HAProxy configuration maps.

---

## Prerequisites

- Root access to the server running HAProxy 3.2+.
- An existing HAProxy 3.2+ setup deployed via LinuxAid with native ACME enabled.
- The backend service running locally or reachable (e.g., `127.0.0.1:1234`).

---

## Step-by-Step Manual Procedure

### Step 1: Create the OpenSSL Config File for the Domain

Create a configuration file for your domain under `/etc/ssl/private/acme/` (replacing `this.example.com` with your target domain):

`/etc/ssl/private/acme/this.example.com.cnf`

```ini
# file managed manually
HOME                    = .
RANDFILE                = $ENV::HOME/.rnd

[ req ]
default_bits            = 4096
default_md              = sha512
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
prompt                  = no
req_extensions          = v3_req

[ v3_req ]
subjectAltName          = @alt_names

[ alt_names ]
DNS.0 = this.example.com
# If adding multiple SANs under the same cert group, add more DNS entries:
# DNS.1 = another.example.com

[ req_distinguished_name ]
commonName              = this.example.com
```

### Step 2: Generate Private Key and CSR

Generate the private key and Certificate Signing Request (CSR):

```bash
# Generate 4096-bit RSA private key
openssl genrsa -out /etc/ssl/private/acme/this.example.com.key 4096
chmod 600 /etc/ssl/private/acme/this.example.com.key

# Generate CSR
openssl req -new \
  -config /etc/ssl/private/acme/this.example.com.cnf \
  -key /etc/ssl/private/acme/this.example.com.key \
  -out /etc/ssl/private/acme/this.example.com.csr
```

### Step 3: Sign the Expired Placeholder Certificate

LinuxAid runs HAProxy with its own ACME scheduler switched off and renews certificates with `haproxy-acme-renew.service`, which treats any certificate expiring within 30 days as due. A born-expired certificate (`-days -1`) is therefore requested from Let's Encrypt on the next run.

```bash
openssl x509 -req \
  -days -1 \
  -in /etc/ssl/private/acme/this.example.com.csr \
  -signkey /etc/ssl/private/acme/this.example.com.key \
  -out /etc/ssl/private/acme/this.example.com.crt \
  -extensions v3_req \
  -extfile /etc/ssl/private/acme/this.example.com.cnf
```

### Step 4: Assemble the PEM File

HAProxy loads combined `.pem` files (certificate + private key) from `/etc/haproxy/certs/`:

```bash
cat /etc/ssl/private/acme/this.example.com.crt /etc/ssl/private/acme/this.example.com.key > /etc/haproxy/certs/this.example.com.pem
chmod 600 /etc/haproxy/certs/this.example.com.pem
```

---

## Updating HAProxy Configuration

### 1. Register in `crt-list.txt`

Open `/etc/haproxy/crt-list.txt` and add the binding entry:

```text
/etc/haproxy/certs/this.example.com.pem [acme LE domains this.example.com] this.example.com
```

*(Note: If you have multiple SANs, list them space-separated inside the brackets and SNI filter, e.g., `[acme LE domains dom1.com,dom2.com] dom1.com dom2.com`)*

### 2. Update Domain-to-Backend Map

Open `/etc/haproxy/domains-to-backends.map` and add the mapping to your backend slug:

```text
this.example.com this_example_com
```

### 3. Add Backend Definition in `haproxy.cfg`

Add the corresponding backend block to `/etc/haproxy/haproxy.cfg`:

```haproxy
backend this_example_com
    mode http
    server this_example_com_0 127.0.0.1:1234 check
```

---

## Validating and Reloading HAProxy

1. Test the HAProxy configuration syntax:

   ```bash
   haproxy -f /etc/haproxy/haproxy.cfg -c
   ```

2. If successful, reload HAProxy:

   ```bash
   systemctl reload haproxy
   ```

3. Request the certificate. A reload does not trigger this on its own; a restart does:

   ```bash
   systemctl start --no-block haproxy-acme-renew.service
   journalctl -u haproxy-acme-renew.service -f
   ```

The renew job asks HAProxy's native ACME engine for a real certificate from Let's Encrypt and, about a minute later, dumps it to `/etc/haproxy/certs/this.example.com.pem` so it survives future restarts. The background systemd timer (`haproxy-dump-certs.timer`) repeats that dump every 30 minutes as a safety net.
