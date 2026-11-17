#!/bin/bash
#
# Renew HAProxy ACME certificates that expire within <days> days or have a
# domain/SAN mismatch against crt-list.txt, one at a time, and dump each
# renewed certificate to disk.
#
# HAProxy runs with "acme.scheduler off" because its own scheduler starts
# every due certificate in the same pass.
#
set -u

DAYS="${1:?usage: $0 <days>}"
SOCKET="${SOCKET:-/var/run/haproxy.sock}"
CRT_LIST=/etc/haproxy/crt-list.txt

while read -r line; do
  # The first token in crt-list.txt line is the certificate file path
  cert="${line%% *}"
  [ -f "$cert" ] || continue

  # Extract expected LE domains from comment tag [acme LE domains domain1,domain2,...]
  if [[ "$line" =~ \[acme[[:space:]]+LE[[:space:]]+domains[[:space:]]+([^]]+)\] ]]; then
    expected_raw="${BASH_REMATCH[1]}"
  else
    continue
  fi
  [ -n "$expected_raw" ] || continue

  # Normalize and sort expected domains alphabetically for comparison
  sorted_expected=$(echo "$expected_raw" | tr ',' '\n' | sort | paste -sd,)

  # Extract actual Subject Alternative Name (SAN) DNS entries from the certificate
  actual_domains=$(openssl x509 -in "$cert" -noout -ext subjectAltName 2>/dev/null |
    grep -oE 'DNS:[^ ,]+' |
    cut -d: -f2 |
    sort |
    paste -sd,)

  needs_renewal=false

  if [ "$sorted_expected" != "$actual_domains" ]; then
    echo "Domain/SAN mismatch detected for ${cert} (expected: [${sorted_expected}], actual: [${actual_domains}])"
    needs_renewal=true
  elif ! openssl x509 -checkend "$((DAYS * 86400))" -noout -in "$cert" > /dev/null; then
    echo "Certificate expiring soon: ${cert}"
    needs_renewal=true
  fi

  if [ "$needs_renewal" = true ]; then
    echo "renewing ${cert}"
    echo "acme renew ${cert}" | socat - "UNIX-CONNECT:${SOCKET}" || exit 1

    # One certificate a minute, which also gives this one time to be issued
    sleep 60

    # A failed dump is picked up by haproxy-dump-certs.timer
    /opt/obmondo/bin/haproxy-dump-certs.sh -s "$SOCKET" "$cert" < /dev/null || true
  fi
done < <(grep -F '[acme ' "$CRT_LIST")
