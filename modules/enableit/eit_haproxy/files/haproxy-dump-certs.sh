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

usage() {
  cat <<EOF
Usage: $(basename "$0") [-s SOCKET] [CERT_PATH ...]

  -s SOCKET   HAProxy stats socket (default: ${SOCKET})
  -h          This help
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

  echo "dump ssl cert ${path}" | hap > "$tmp"

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
  echo "show ssl cert" | hap | awk '/^[^#]/ && NF' | while read -r p; do
    dump_one "$p"
  done
fi
