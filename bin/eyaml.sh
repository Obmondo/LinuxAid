#!/bin/bash
# Use eyaml with public key already set
#
# Will ready from stdin and output a string if run with no arguments.

if [[ $# -eq 0 ]]; then
  COMMAND='encrypt'
  ARGS='--stdin --output=string'
else
  shift
  COMMAND="$1"
  ARGS="$*"
fi

eval eyaml "${COMMAND}" --pkcs7-public-key="$(dirname "$0")/../var/public_key.pkcs7.pem" "$ARGS" | tr -d \\n
