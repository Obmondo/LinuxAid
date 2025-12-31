#!/bin/bash

# Puppetfile Auto-Update Script
# This script automatically updates module refs to the latest tags

set -eou pipefail

# This script requires Linux and bash to run
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: This script must be run on Linux"
  echo "Current OS: $(uname -s)"
  echo "This script uses GNU sed which is not compatible with BSD sed (macOS)"
  exit 1
fi

# Ensure we're running in bash
if [[ -z "$BASH_VERSION" ]]; then
  echo "Error: This script must be run in bash"
  echo "Current shell: $SHELL"
  echo "This script uses bash-specific features and syntax"
  exit 1
fi

for program in rsync yq git; do
  if ! command -v "$program" >/dev/null; then
    echo "Missing $program"
    exit 1
  fi
done

SCRIPT_NAME="$(basename "$0")"

function ARGFAIL() {
  cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

OPTIONS:
  --update-module <module-name> [commit-hash]
                        Update a specific Openvox module
                        Requires: Upstream module name
                        Optional: Commit hash to pin to specific version

  --add-module <module-url> [commit-hash]
                        Add a specific Openvox module (defaults to latest tag)
                        Requires: Upstream module git URL
                        Optional: Commit hash to pin to specific version

  --puppetfile          Path to Puppetfile
                        Default: $(pwd)/Puppetfile

  -h, --help            Display this help message and exit

EXAMPLES:
  # Add a specific module with latest tag
  ${SCRIPT_NAME} --add-module <git-url>

  # Add a specific module with pinned commit or specific tag
  ${SCRIPT_NAME} --add-module <git-url> <commit-hash>
  ${SCRIPT_NAME} --add-module <git-url> <tag>

  # Update a specific module with pinned commit or specific tag
  ${SCRIPT_NAME} --update-module <module-name> <commit-hash>
  ${SCRIPT_NAME} --update-module <module-name> <tag>

  # Update a specific module with latest tag
  ${SCRIPT_NAME} --update-module <module-name>

For more information, visit: <https://github.com/Obmondo/linuxaid.git>
EOF
  exit 1
}

# Extract git URLs and current refs
declare UPDATE_MODULE=false
declare ADD_MODULE=false
declare OPENVOX_UPSTREAM_MODULES_PATH
declare PUPPETFILE

OPENVOX_UPSTREAM_MODULES_PATH="$(dirname "$(readlink -f "${SCRIPT_NAME}/..")")/modules/upstream"
PUPPETFILE="$(dirname "$(readlink -f "${SCRIPT_NAME}/..")")/modules/Puppetfile"

[ $# -eq 0 ] && { ARGFAIL; exit 1; }

while [[ $# -gt 0 ]]; do
  arg="$1"
  shift

  case "$arg" in
    --add-module)
      if [[ $# -eq 0 ]]; then
        echo "Error: --update-module requires a module name" >&2
        exit 1
      fi

      ADD_MODULE=true
      GIT_URL=$1
      COMMIT_HASH="${2:-}"

      # Validate HTTPS URL with optional .git suffix
      if [[ ! "$GIT_URL" =~ ^https://[^/]+/.+(\.git)?$ ]]; then
        echo "Error: Invalid Git URL. Must be HTTPS format with optional .git suffix" >&2
        echo "Example: https://github.com/user/repo or https://github.com/user/repo.git" >&2
        exit 1
      fi

      shift
      [[ -n "$COMMIT_HASH" ]] && shift
      ;;
    --update-module)
      if [[ $# -eq 0 ]]; then
        echo "Error: --update-module requires a module name" >&2
        exit 1
      fi

      UPDATE_MODULE=true
      MODULE_NAME=$1
      COMMIT_HASH="${2:-}"

      if ! test -d "${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME}"; then
        echo "Openvox module ${MODULE_NAME} under ${OPENVOX_UPSTREAM_MODULES_PATH} dir does not exist"
        exit 1
      fi

      shift
      [[ -n "$COMMIT_HASH" ]] && shift
      ;;
    --puppetfile)
      PUPPETFILE_PATH=${1:-${PUPPETFILE}}

      if [ ! -f "$PUPPETFILE_PATH" ]; then
          echo "Error: Puppetfile not found at $PUPPETFILE"
          exit 1
      fi

      shift
      ;;
    -h|--help)
      ARGFAIL
      exit
      ;;
    *)
      echo "Error: wrong argument given"
      ARGFAIL
      exit 1
      ;;
  esac
done

# Trap SIGTERM (15), SIGINT (2 - Ctrl+C), and SIGHUP (1)
trap cleanup SIGTERM SIGINT SIGHUP

# Create temp file
TEMP_FILE=$(mktemp)
cat "$PUPPETFILE" > "$TEMP_FILE"

function get_module_latest_tag() {
  LATEST_TAG=$(git ls-remote --tags "$GIT_URL" 2>/dev/null | \
    grep -oP 'refs/tags/\K[^{}^]+' | \
    grep -E '^v?([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$' |
    sort -V | tail -1)

  echo "${LATEST_TAG}"
}

function setup_module_git_clone() {
  CHECKOUT_REF=$1
  # Create tempdir to clone the module locally
  TEMP_CLONE_DIR="$(mktemp -d --suffix="-${MODULE_NAME##*/}")"

  chmod a+rX "${TEMP_CLONE_DIR}"
  git clone --quiet "${GIT_URL}" "${TEMP_CLONE_DIR}"

  # Switch to required ref
  git -C "${TEMP_CLONE_DIR}" checkout --quiet "${CHECKOUT_REF}"
}

function extract_module_name_from_url() {
  # Extract the last part of the path and remove .git suffix
  MODULE_NAME=$(basename "${GIT_URL%.git}")

  # Remove 'puppet-' prefix if present
  MODULE_NAME=${MODULE_NAME#puppet-}

  echo "${MODULE_NAME}"
}

function get_module_current_version() {
  local MODULE_VERSION
  METADATA_JSON="${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME}/metadata.json"

  # Check if metadata file exists
  if [[ ! -f "${METADATA_JSON}" ]]; then
    echo "Error: Metadata file not found: ${METADATA_JSON}" >&2
    return 1
  fi

  MODULE_VERSION=$(jq -r .version "${METADATA_JSON}")

  echo "${MODULE_VERSION}"
}

function get_module_git_url() {
  if [[ "$MODULE_NAME" =~ ^https:// ]]; then
    GIT_URL=$MODULE_NAME
  else
    METADATA_JSON="${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME}/metadata.json"

    # Check if metadata file exists
    if [[ ! -f "${METADATA_JSON}" ]]; then
      echo "Error: Metadata file not found: ${METADATA_JSON}" >&2
      return 1
    fi

    GIT_URL=$(jq -r .source "${METADATA_JSON}")

    # Check if git URL is empty or null
    if [[ -z "${GIT_URL}" ]]; then
      echo "Error: Git URL is empty in ${METADATA_JSON} of module ${MODULE_NAME}" >&2
      exit 1
    fi
  fi

  # Validate it's an HTTPS URL
  if [[ ! "$GIT_URL" =~ ^https:// ]]; then
    echo "Error: Git URL must be HTTPS format: ${GIT_URL}" >&2
    return 1
  fi

  # Clean up git URL
  local GIT_URL_CLEAN=${GIT_URL%.git}

  echo "${GIT_URL_CLEAN}"
}

function update_puppetfile() {
  # Check if module exists in Puppetfile
  if grep -q "mod '[^']*/${MODULE_NAME}'" "$PUPPETFILE"; then
    # Update existing entry
    sed -i "/mod '[^']*\/${MODULE_NAME}'/,/:ref =>/ s/:ref => '[^']*'/:ref => '${LATEST_TAG}'/" "$PUPPETFILE"
    echo "Updated ${MODULE_NAME} to ${LATEST_TAG} in Puppetfile"
  else
    # Append new entry
    cat >> "$PUPPETFILE" <<-EOF

mod 'obmondo/${MODULE_NAME}',
    :git => '${GIT_URL}',
    :ref => '${LATEST_TAG}'
EOF
    echo "Added ${MODULE_NAME} at ${LATEST_TAG} to Puppetfile"
  fi

  git add "$PUPPETFILE"
}

# Function to add new module in linuxaid
function add_module() {
  MODULE_NAME=$(extract_module_name_from_url "$GIT_URL")
  MODULE_DIR="${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME##*/}/"

  # Pin to specific commit
  if [[ -n "$COMMIT_HASH" ]]; then
    setup_module_git_clone "$COMMIT_HASH"
    COMMIT_MESSAGE="chore: pin puppet-${MODULE_NAME} module @${COMMIT_HASH}

Pinned to specific commit instead of tagged release.
Source: ${GIT_URL}/commit/${COMMIT_HASH}"
  else
    LATEST_TAG=$(get_module_latest_tag "${GIT_URL}")
    setup_module_git_clone "$LATEST_TAG"
    COMMIT_MESSAGE="chore: added puppet-${MODULE_NAME} module ${LATEST_TAG}

Source: ${GIT_URL}/releases/tag/${LATEST_TAG}"
  fi

  update_puppetfile
  sync_module_to_linuxaid "$MODULE_NAME" "$COMMIT_MESSAGE"
}

# Check each repository for updates
function update_module() {
  MODULE_DIR="${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME##*/}/"

  get_module_git_url

  # Pin to specific commit
  if [[ -n "$COMMIT_HASH" ]]; then
    LATEST_TAG="${COMMIT_HASH}"
    setup_module_git_clone "$COMMIT_HASH"
    echo "Using ref ${COMMIT_HASH}"
    COMMIT_MESSAGE="chore: updated puppet-${MODULE_NAME} module @${COMMIT_HASH}

Pinned to specific commit instead of tagged release.

Source: ${GIT_URL}/commit/${COMMIT_HASH}"
  else
    LATEST_TAG=$(get_module_latest_tag "${MODULE_NAME}")
    CURRENT_TAG=$(get_module_current_version "${MODULE_NAME}")

    # Update to latest tag, when available
    # NOTE: metadata.json version has no *v* prefix, as per pdk
    if [ "v$CURRENT_TAG" == "$LATEST_TAG" ]; then
      echo "Already at latest tag: ${CURRENT_TAG}"
      return 0
    fi

    echo "Current version: ${CURRENT_TAG}, Latest version: ${LATEST_TAG}"
    setup_module_git_clone "${LATEST_TAG}"
    COMMIT_MESSAGE="chore: updated puppet-${MODULE_NAME} module v${CURRENT_TAG} -> ${LATEST_TAG}

Source: ${GIT_URL}/releases/tag/${LATEST_TAG}"
  fi

  update_puppetfile
  sync_module_to_linuxaid "$MODULE_NAME" "$COMMIT_MESSAGE"
}

function sync_module_to_linuxaid() {
  MODULE_DIR="${OPENVOX_UPSTREAM_MODULES_PATH}/${MODULE_NAME}/"

  rsync -Paq --delete                  \
        --delete-excluded              \
        --exclude='/.git*'             \
        --exclude='/.fixtures.yml'     \
        --exclude='/.editconfig'       \
        --exclude='/.msync.yml'        \
        --exclude='/.overcommit.yml'   \
        --exclude='/.pmtignore'        \
        --exclude='/.puppet-lint.rc'   \
        --exclude='/.rubocop.yml'      \
        --exclude='/.rubocop_todo.yml' \
        --exclude='/.sync.yml'         \
        --exclude='/.travis.yml'       \
        --exclude='/spec'              \
        --exclude='/coverage'          \
        --exclude=Gemfile.lock         \
        --exclude=Dockerfile           \
        "${TEMP_CLONE_DIR}/" "${MODULE_DIR}"

  if [[ -n $(git status --porcelain "${MODULE_DIR}") ]]; then
    echo "Changes detected, committing..."
    git add "${MODULE_DIR}"
    git commit -F - <<EOF
${COMMIT_MESSAGE}
EOF
  else
    echo "No changes to commit"
  fi

  rm -fr "$TEMP_CLONE_DIR"
}

if "$UPDATE_MODULE"; then
  update_module "$MODULE_NAME" "$COMMIT_HASH"
fi

if "$ADD_MODULE"; then
  add_module "$GIT_URL" "$COMMIT_HASH"
fi
