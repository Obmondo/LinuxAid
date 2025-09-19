#!/bin/bash

# Generate docs for these modules
MODULES="common monitor role profile"
MODULEDIR="modules/enableit"

# Check if puppet-strings is available
if ! puppet strings --help >/dev/null 2>&1; then
  log "ERROR: puppet strings command not found. Please install puppet-strings gem."
  exit 1
fi

for module in $MODULES; do
  echo "Processing module: $module"

  MODULEPATH="${MODULEDIR}/${module}"
  if [ -d "${MODULEPATH}" ]; then
    puppet strings generate --format markdown --out "${MODULEPATH}/REFERENCE.md" "${MODULEPATH}/manifests/*"
  fi
done
