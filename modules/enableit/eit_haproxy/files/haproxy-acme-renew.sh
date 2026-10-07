#!/bin/bash
#
# Renew HAProxy ACME certificates that expire within 30 days, one at a time,
# and dump each renewed certificate to disk.
#
# HAProxy runs with "acme.scheduler off" because its own scheduler starts
# every due certificate in the same pass.
#
set -u

SOCKET="${SOCKET:-/var/run/haproxy.sock}"
CRT_LIST=/etc/haproxy/crt-list.txt

while read -r cert; do
  # still valid for 30 days
  openssl x509 -checkend 2592000 -noout -in "$cert" > /dev/null && continue

  echo "renewing ${cert}"
  echo "acme renew ${cert}" | socat - "UNIX-CONNECT:${SOCKET}" || exit 1

  # one certificate a minute, which also gives this one time to be issued
  sleep 60

  # a failed dump is picked up by haproxy-dump-certs.timer
  /opt/obmondo/bin/haproxy-dump-certs.sh -s "$SOCKET" "$cert" < /dev/null || true
done < <(grep -F '[acme ' "$CRT_LIST" | cut -d ' ' -f 1)
