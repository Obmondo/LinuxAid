#!/bin/bash

# Generate docs for these modules
MODULES="common monitor role profile"
MODULEDIR="modules/enableit"

# Check if puppet-strings is available
if ! puppet strings --help >/dev/null 2>&1; then
  echo "ERROR: puppet strings command not found. Please install puppet-strings gem." >&2
  exit 1
fi

for module in $MODULES; do
  echo "Processing module: $module"

  MODULEPATH="${MODULEDIR}/${module}"
  MANIFESTS_DIR="${MODULEPATH}/manifests"

  if [ -d "${MANIFESTS_DIR}" ]; then
    find "${MANIFESTS_DIR}" -type f -name "*.pp" -exec \
      puppet strings generate --format markdown --out "${MODULEPATH}/REFERENCE.md" {} +
  fi
done
