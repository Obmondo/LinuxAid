#!/bin/bash
#
# Dump in-memory certificates from HAProxy to disk.
#
# HAProxy's `dump ssl cert <name>` already outputs the cert chain followed
# by the private key in PEM — the same format we load with crt-list. So we
# just send it to a tempfile in the destination directory, sanity-check
# that both halves are present, and atomically rename over the old file.
#
# With no args, walks every cert from `show ssl cert` and dumps each.
# With args, dumps only those (paths or names as known to HAProxy).
#
set -euo pipefail

SOCKET="${SOCKET:-/var/run/haproxy.sock}"
MAX_RETRIES=20
RETRY_DELAY=10

# Restored argument parsing
usage() {
  cat <<EOF
Usage: $(basename "$0") [-s SOCKET] [-d]
  -s SOCKET   HAProxy stats socket (default: ${SOCKET})
  -d          Enable debug/verbose logging
EOF
}

DEBUG=false

while getopts ":s:hd" opt; do
  case "$opt" in
    s) SOCKET="$OPTARG" ;;
    d) DEBUG=true ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

hap() { socat - "UNIX-CONNECT:${SOCKET}"; }

dump_one() {
  local path="$1"
  if [ "${DEBUG:-false}" = true ]; then
    echo "Attempting dump for: ${path}" >&2
  fi
  local dir tmp
  dir=$(dirname "$path")
  tmp=$(mktemp "${dir}/.$(basename "$path").XXXXXX")
  trap 'rm -f "$tmp"' RETURN

  local output
  local retries=0
  while [ $retries -lt $MAX_RETRIES ]; do
    output=$(echo "dump ssl cert ${path}" | hap)
    if echo "$output" | grep -q 'locked'; then
      echo "Locked, retrying in ${RETRY_DELAY}s... (${path})" >&2
      sleep $RETRY_DELAY
      ((retries++))
    else
      echo "$output" > "$tmp"
      break
    fi
  done

  if [ $retries -eq $MAX_RETRIES ]; then
      echo "--- Lock contention detected. Capturing HAProxy state ---" >&2
      echo "show tasks" | hap > /tmp/haproxy_tasks_dump.txt 2>&1
      echo "show threads" | hap > /tmp/haproxy_threads_dump.txt 2>&1
      echo "Error: ${path}: Failed to dump (still locked after ${MAX_RETRIES} retries)" >&2
      exit 1
  fi

  if ! grep -q 'BEGIN CERTIFICATE'      "$tmp" \
  || ! grep -q 'BEGIN .*PRIVATE KEY'    "$tmp"; then
    echo "skip: ${path}: dump missing cert or key (placeholder still in memory?)" >&2
    return 0
  fi

  local cn
  cn=$(openssl x509 -in "$tmp" -noout -subject 2>/dev/null | sed -n 's/.*CN[[:space:]]*=[[:space:]]*\([^,/[:space:]]*\).*/\1/p')
  if [ -n "$cn" ]; then
    echo "$cn" >> /tmp/active_cert_domains.txt
  fi

  # Optimization: Content verification with fast sha256sum
  if [ -f "$path" ]; then
    if cmp -s \
        <(sha256sum "$tmp" | cut -d ' ' -f1) \
        <(sha256sum "$path" | cut -d ' ' -f1); then
      if [ "${DEBUG:-false}" = true ]; then
        echo "Already up-to-date: ${path}" >&2
      fi
      return 0
    fi
  fi

  chmod 600 "$tmp"
  mv "$tmp" "$path"
  echo "SUCCESS: ${path} updated and verified." >&2
  sleep 0.25
}

if [ $# -gt 0 ]; then
  for p in "$@"; do dump_one "$p"; done
else
  # Use a temporary file to avoid pipe issues with the loop
  echo "show ssl cert" | hap | awk '/^[^#]/ && NF' > /tmp/cert_list.txt
  while read -r p; do
    dump_one "$p"
  done < /tmp/cert_list.txt

  echo "----------------------------------------------------------------------------------"
  echo "Analyzing for unused certificates which can be removed..."
  comm -23 \
      <(ls /etc/haproxy/certs/*.pem 2>/dev/null | sort) \
      <(sort /tmp/cert_list.txt) | while read -r unused_cert; do
          echo "$unused_cert"
  done

  echo "----------------------------------------------------------------------------------"
  echo "Analyzing for unused domain expiry threshold .prom files which can be removed..."
  if [ -f /tmp/active_cert_domains.txt ]; then
    sort -u /tmp/active_cert_domains.txt -o /tmp/active_cert_domains.txt
    for prom_file in /var/lib/node_exporter/textfile_collector/threshold_monitor_domains_expiry_*.prom; do
      [ -e "$prom_file" ] || continue
      prom_domain=$(basename "$prom_file" | sed 's/^threshold_monitor_domains_expiry_//;s/\.prom$//')
      if ! grep -q "^${prom_domain}$" /tmp/active_cert_domains.txt; then
        echo "$prom_file"
      fi
    done
    rm -f /tmp/active_cert_domains.txt
  fi
fi
