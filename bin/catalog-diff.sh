#!/usr/bin/env bash
#
# Run octocatalog-diff inside Docker with local facts, ENC, and eyaml support.
#

set -o pipefail

# Default image, can be overridden with OCTOCATALOG_DIFF_IMAGE env var
: "${OCTOCATALOG_DIFF_IMAGE:=ghcr.io/obmondo/linuxaid-octocatalog-diff:2.3.1}"

# --- Global State ---

E2E=0
DEBUG=0
CI_MODE=0
PULL=0
QUIET=0
NO_CACHE=0
FORMAT="pretty"
HOSTNAMES=()
CONFIG_REPO=""
CONFIG_FROM="main"
KUBE_CONTEXT=""
KUBE_NAMESPACE=""
OCD_PASSTHROUGH=()
CONFIG_TMPDIR=""

# --- Helper Functions ---

# Log to stderr
log() {
  if [[ "$QUIET" == "0" ]]; then
    echo "$@" >&2
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") --e2e [OPTIONS]

Run octocatalog-diff inside Docker.

Options:
  -h, --help    Show this help message
  --e2e         Run in e2e mode: uses local facts (e2e/facts/), enc (e2e/enc.rb)
                and hiera config (e2e/hiera.yaml).
  --ci          Enable CI mode: produce a Markdown summary in addition to plain text.
                In GitHub Actions, writes to GITHUB_STEP_SUMMARY; locally, prints to stdout.
  --pull        Pull the latest version of the Docker image before running.
  --quiet       Minimize non-essential output.
  --no-cache    Force re-fetching facts via SSH even if they exist locally.
  --format-as FMT
                Output format. Options: pretty (default), json.
  --config-repo PATH
                Path to a customer config repo.
                Hiera reads agent data (agents/*.yaml, global.yaml, etc.) from it.
                The "from" compilation uses the committed state; the "to" uses the working tree.
  --config-from REF
                Git ref for the "from" state of the config repo (default: main).
  --kube-context NAME
                Kubernetes context to fetch eyaml keys from.
                Auto-detected from assh config (~/.ssh/assh.d/<customer_id>.yml) if not given.
  --kube-namespace NS
                Namespace containing the 'eyaml-keys' secret.
                Auto-detected from assh config (~/.ssh/assh.d/<customer_id>.yml) if not given.
  --debug       Keep all working files (catalogs, facts) in .catalog-diff-debug/ for inspection.

  Any additional options are passed directly to octocatalog-diff.

Examples:
  $(basename "$0") --e2e --hostname role-basic.e2etesting
  $(basename "$0") --e2e --hostname role-basic.e2etesting --from master --to HEAD
  $(basename "$0") --e2e --config-repo /path/to/config --hostname node.customer
EOF
}

check_dependencies() {
  local deps=(docker yq ruby)
  [[ -n "$KUBE_CONTEXT" ]] && deps+=(kubectl)

  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Error: dependency '$cmd' is not installed." >&2
      exit 1
    fi
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)        usage; exit 0 ;;
      --e2e)            E2E=1; shift ;;
      --ci)             CI_MODE=1; shift ;;
      --pull)           PULL=1; shift ;;
      --quiet)          QUIET=1; shift ;;
      --no-cache)       NO_CACHE=1; shift ;;
      --format-as)      FORMAT="$2"; shift 2 ;;
      --debug)          DEBUG=1; shift ;;
      --hostname)       HOSTNAMES+=("$2"); shift 2 ;;
      --from)           OCD_PASSTHROUGH+=(--from "$2"); shift 2 ;;
      --to)             OCD_PASSTHROUGH+=(--to "$2"); shift 2 ;;
      --config-repo)    CONFIG_REPO="$(cd "$2" && pwd)"; shift 2 ;;
      --config-from)    CONFIG_FROM="$2"; shift 2 ;;
      --kube-context)   KUBE_CONTEXT="$2"; shift 2 ;;
      --kube-namespace) KUBE_NAMESPACE="$2"; shift 2 ;;
      --)               shift; OCD_PASSTHROUGH+=("$@"); break ;;
      *)                OCD_PASSTHROUGH+=("$1"); shift ;;
    esac
  done

  if [[ "$E2E" != "1" ]]; then
    echo "Error: --e2e is currently required" >&2
    usage
    exit 1
  fi
}

cleanup() {
  [[ -n "$CONFIG_TMPDIR" ]] && rm -rf "$CONFIG_TMPDIR"
}

trap cleanup EXIT INT TERM HUP

ensure_tmpdir() {
  [[ -z "$CONFIG_TMPDIR" ]] && CONFIG_TMPDIR="$(mktemp -d)"
}

fetch_facts() {
  local hostname="$1"
  [[ -z "$hostname" ]] && return

  local fact_file="e2e/facts/${hostname}.yaml"
  if [[ -f "$fact_file" ]] && [[ "$NO_CACHE" == "0" ]]; then
    log "Using cached facts: $fact_file"
  else
    log "Fetching facts for '${hostname}' via SSH..."
    if ! bin/fetch-node-facts "$hostname"; then
      echo "Error: failed to fetch facts for '${hostname}'" >&2
      exit 1
    fi
  fi
}

detect_kube_params() {
  local hostname="$1"
  [[ -z "$hostname" || -n "$KUBE_CONTEXT" ]] && return

  local customer_id="${hostname#*.}"
  local assh_file="$HOME/.ssh/assh.d/${customer_id}.yml"
  [[ ! -f "$assh_file" ]] && assh_file="$HOME/.ssh/assh.d/${customer_id}.yaml"

  [[ -f "$assh_file" ]] || return

  KUBE_CONTEXT=$(yq -r '.k8s.context // ""' "$assh_file" 2>/dev/null)
  KUBE_NAMESPACE=$(yq -r '.k8s.namespace // ""' "$assh_file" 2>/dev/null)

  if [[ -n "$KUBE_CONTEXT" ]]; then
    log "Auto-detected kube context=$KUBE_CONTEXT namespace=$KUBE_NAMESPACE from $assh_file"
  fi
}

fetch_eyaml_keys() {
  [[ -z "$KUBE_CONTEXT" ]] && return

  if [[ -z "$KUBE_NAMESPACE" ]]; then
    echo "Error: --kube-namespace is required with --kube-context" >&2
    exit 1
  fi

  # Skip if already fetched in this session
  [[ -f "$CONFIG_TMPDIR/private_key.pkcs7.pem" ]] && return

  ensure_tmpdir

  log "Fetching eyaml private key from ${KUBE_CONTEXT}/${KUBE_NAMESPACE}..."
  local key_data
  if ! key_data=$(kubectl --context "$KUBE_CONTEXT" -n "$KUBE_NAMESPACE" \
      get secret eyaml-keys -o jsonpath='{.data.private_key\.pkcs7\.pem}' 2>&1); then
    echo "Error: failed to fetch eyaml-keys secret from '$KUBE_NAMESPACE': $key_data" >&2
    exit 1
  fi
  if [[ -z "$key_data" ]]; then
    echo "Error: eyaml-keys secret exists but private_key.pkcs7.pem field is empty" >&2
    exit 1
  fi
  echo "$key_data" | base64 -d > "$CONFIG_TMPDIR/private_key.pkcs7.pem"
}

setup_config_repo() {
  [[ -z "$CONFIG_REPO" ]] && return

  # Check if already extracted
  [[ -f "$CONFIG_TMPDIR/hiera-from.yaml" ]] && return

  ensure_tmpdir

  git -C "$CONFIG_REPO" archive "$CONFIG_FROM" | tar -x -C "$CONFIG_TMPDIR" \
    || { echo "Error: failed to extract config repo at ref '$CONFIG_FROM'" >&2; exit 1; }

  # Point datadir to our temporary mount points.
  for side in from to; do
    yq ".defaults.datadir = \"/config-repo-$side\"" hiera.yaml > "$CONFIG_TMPDIR/hiera-$side.yaml"
  done
}

dump_agent_config() {
  local label="$1" path="$2"
  [[ -f "$path" ]] || return
  [[ "$QUIET" == "1" ]] && return
  echo "--- Agent Config ($label) ---" >&2
  cat "$path" >&2
}

filter_stderr() {
  if [[ "$DEBUG" == "1" ]]; then
    cat
    return
  fi

  # Pass through Puppet errors and octocatalog-diff catalog errors;
  # drop noisy INFO/DEBUG lines from the bundler/octocatalog-diff runtime.
  while IFS= read -r line; do
    case "$line" in
      Error:*|*CatalogError*|*"Unable to resolve"*|*"failed to load"*|\[bootstrap\]*)
        echo "$line" >&2
        ;;
    esac
  done
}

build_docker_args() {
  local -n out="$1"
  out=(
    --rm
    -u "$(id -u):$(id -g)"
    -v "$(pwd):/repo"
    -e "OCTOCATALOG_DIFF_CONFIG_FILE=/repo/.octocatalog-diff.cfg.rb"
    -e "PUPPET_FACT_DIR=/repo/e2e/facts"
    -e "HOME=/tmp"
  )

  if [[ -f "$CONFIG_TMPDIR/private_key.pkcs7.pem" ]]; then
    out+=(-v "$CONFIG_TMPDIR/private_key.pkcs7.pem:/etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem:ro")
  fi

  if [[ -n "$CONFIG_REPO" ]]; then
    out+=(
      -v "$CONFIG_TMPDIR:/config-repo-from:ro"
      -v "$CONFIG_REPO:/config-repo-to:ro"
      -v "$CONFIG_TMPDIR/hiera-from.yaml:/hiera-from.yaml:ro"
      -v "$CONFIG_TMPDIR/hiera-to.yaml:/hiera-to.yaml:ro"
      -v "$CONFIG_TMPDIR/modules:/customer-modules:ro"
    )
    # Bind-mount each customer module over /repo/modules/enableit/<name> so the
    # "to" side resolves puppet:///modules/<name>/... refs without touching the
    # working tree. The "from" side gets them via the bootstrap script.
    if [[ -d "$CONFIG_REPO/modules" ]]; then
      local mod name
      for mod in "$CONFIG_REPO"/modules/*/; do
        [[ -d "$mod" ]] || continue
        name=$(basename "$mod")
        out+=(-v "${mod%/}:/repo/modules/enableit/$name:ro")
      done
    fi
  fi

  if [[ "$DEBUG" == "1" ]]; then
    mkdir -p "$(pwd)/.catalog-diff-debug"
    out+=(-v "$(pwd)/.catalog-diff-debug:/tmp")
  fi
}

run_diff() {
  local hostname="$1"
  local ocd_args=(--basedir /repo --enc /repo/e2e/enc.rb)

  if [[ -n "$CONFIG_REPO" ]]; then
    # Resolving `source => puppet:///modules/customers/...` to actual file content
    # so octocatalog-diff can detect content-level changes:
    #   - "to" (working tree) side: customer modules are bind-mounted directly
    #     into /repo/modules/enableit/<name> by build_docker_args.
    #   - "from" (git ref) side: octocatalog-diff checks the ref out into its own
    #     build dir, so we use --bootstrap-script to copy customer modules from
    #     /customer-modules (which points at the extracted CONFIG_FROM ref) into
    #     that build dir's modules/enableit/.
    ocd_args+=(
      --from-hiera-config /hiera-from.yaml
      --to-hiera-config /hiera-to.yaml
      --no-hiera-path
      --bootstrap-script e2e/bin/bootstrap-customer-modules.sh
    )
  else
    ocd_args+=(--hiera-config /repo/e2e/hiera.yaml)
  fi

  # In CI mode, dump the agent config files used for each compilation side
  if [[ "$CI_MODE" == "1" ]] && [[ -n "$hostname" ]]; then
    if [[ -n "$CONFIG_REPO" ]]; then
      dump_agent_config "From: agents/${hostname}.yaml" "$CONFIG_TMPDIR/agents/${hostname}.yaml"
      dump_agent_config "To: agents/${hostname}.yaml"   "$CONFIG_REPO/agents/${hostname}.yaml"
    else
      dump_agent_config "e2e/agents/${hostname}.yaml" "e2e/agents/${hostname}.yaml"
    fi
  fi

  # Inject clientcert override
  if [[ -n "$hostname" ]]; then
    ocd_args+=(--hostname "$hostname" --fact-override "clientcert=$hostname")
  fi

  local fmt_args=()
  [[ "$CI_MODE" == "1" ]] && fmt_args+=(--ci)
  [[ ! -t 1 ]] && fmt_args+=(--no-color)
  [[ -n "$hostname" ]] && fmt_args+=(--hostname "$hostname")

  # Build docker command
  local docker_args=()
  build_docker_args docker_args

  local run_cmd=(
    docker run "${docker_args[@]}"
    "$OCTOCATALOG_DIFF_IMAGE"
    bundle exec octocatalog-diff "${ocd_args[@]}"
    --output-format json
    "${OCD_PASSTHROUGH[@]}"
  )

  local ocd_output rc
  ocd_output=$("${run_cmd[@]}" 2> >(filter_stderr >&2))
  rc=$?

  # exit 2 = diffs found (expected); anything else non-zero is a real failure
  if [[ "$rc" != "0" && "$rc" != "2" ]]; then
    echo "Error: octocatalog-diff failed (exit $rc). Re-run with --debug for full stderr." >&2
    return "$rc"
  fi

  if [[ "$FORMAT" == "json" ]]; then
    printf '%s\n' "$ocd_output"
  else
    printf '%s\n' "$ocd_output" | ruby e2e/bin/format_catalog_diff.rb "${fmt_args[@]}"
  fi
  return 0
}

# --- Main ---

parse_args "$@"
check_dependencies

[[ "$DEBUG" == "1" ]] && log "Debug mode: .catalog-diff-debug/"

if [[ "$PULL" == "1" ]]; then
  log "Updating Docker image..."
  docker pull "$OCTOCATALOG_DIFF_IMAGE" >&2
fi

# Run for each hostname (or once with empty hostname if none given)
[[ ${#HOSTNAMES[@]} -eq 0 ]] && HOSTNAMES=("")

final_rc=0
for hostname in "${HOSTNAMES[@]}"; do
  [[ -n "$hostname" ]] && log "--- $hostname ---"
  fetch_facts "$hostname"
  detect_kube_params "$hostname"
  fetch_eyaml_keys
  setup_config_repo
  run_diff "$hostname" || final_rc=$?
done

exit $final_rc
