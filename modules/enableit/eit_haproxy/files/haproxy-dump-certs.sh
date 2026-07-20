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
MAX_RETRIES=5
RETRY_DELAY=5

# Restored argument parsing
usage() {
  cat <<EOF
Usage: $(basename "$0") [-s SOCKET]
  -s SOCKET   HAProxy stats socket (default: ${SOCKET})
EOF
}

while getopts ":s:h" opt; do
  case "$opt" in
    s) SOCKET="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

hap() { socat - "UNIX-CONNECT:${SOCKET}"; }

dump_one() {
  local path="$1"
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
      echo "Error: ${path}: Failed to dump (still locked after ${MAX_RETRIES} retries)" >&2
      exit 1
  fi

  if ! grep -q 'BEGIN CERTIFICATE'      "$tmp" \
  || ! grep -q 'BEGIN .*PRIVATE KEY'    "$tmp"; then
    echo "skip: ${path}: dump missing cert or key (placeholder still in memory?)" >&2
    return 0
  fi

  if [ -f "$path" ] && cmp -s \
        <(openssl x509 -in "$tmp"  -noout -fingerprint -sha256) \
        <(openssl x509 -in "$path" -noout -fingerprint -sha256); then
    return 0
  fi

  chmod 600 "$tmp"
  mv "$tmp" "$path"
  echo "updated: ${path}"
}

if [ $# -gt 0 ]; then
  for p in "$@"; do dump_one "$p"; done
else
  # Use a temporary file to avoid pipe issues with the loop
  echo "show ssl cert" | hap | awk '/^[^#]/ && NF' > /tmp/cert_list.txt
  while read -r p; do
    dump_one "$p"
  done < /tmp/cert_list.txt
fi
