#!/usr/bin/env bash

IMAGE=ghcr.io/obmondo/linuxaid-octocatalog-diff:2.3.1

usage() {
  cat <<EOF
Usage: $(basename "$0") [--e2e] [OPTIONS]

Run octocatalog-diff inside Docker.

Subcommands:
  --e2e         Run in e2e mode: uses local facts (e2e/facts/), enc (e2e/enc.rb)
                and hiera config (e2e/hiera.yaml). No PuppetDB required.

Options:
  -h, --help    Show this help message
  --ci          Enable CI mode: produce a Markdown summary in addition to plain text.
                In GitHub Actions, writes to GITHUB_STEP_SUMMARY; locally, prints to stdout.
  --debug       Mount .catalog-diff-debug/ as /tmp inside the container.
                Keeps all working files (catalogs, facts) for inspection after the run.
  Any additional options are passed directly to octocatalog-diff.

Examples:
  $(basename "$0") --e2e --hostname role-basic.e2etesting
  $(basename "$0") --e2e --hostname role-basic.e2etesting --from master --to HEAD
EOF
}

E2E=0
DEBUG=0
CI_MODE=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --ci)
      CI_MODE=1
      shift
      ;;
    --debug)
      DEBUG=1
      shift
      ;;
    --e2e)
      E2E=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

DOCKER_ARGS=(
  --rm
  -u "$(id -u):$(id -g)"
  -v "$(pwd):/repo"
  -e OCTOCATALOG_DIFF_CONFIG_FILE=/repo/.octocatalog-diff.cfg.rb
  -e HOME=/tmp
)

if [ "$DEBUG" = "1" ]; then
  mkdir -p "$(pwd)/.catalog-diff-debug"
  DOCKER_ARGS+=(-v "$(pwd)/.catalog-diff-debug:/tmp")
  echo "Debug mode: working files will be in $(pwd)/.catalog-diff-debug"
fi

filter_stderr() {
  local from_branch="${1:-master}" to_branch="${2:-HEAD}"
  if [ "$DEBUG" = "1" ]; then
    cat
    return
  fi

  local block=0 from_header=0 to_header=0
  while IFS= read -r line; do
    # only care about error lines
    [[ "$line" != Error:* ]] && continue
    # "Try 'puppet help'" marks the boundary between from/to compilations
    [[ "$line" == *"Try 'puppet help'"* ]] && (( block++ )) && continue

    if (( block == 0 && from_header == 0 )); then
      echo "=== Errors compiling $from_branch ==="
      from_header=1
    elif (( block >= 1 && to_header == 0 )); then
      echo ""
      echo "=== Errors compiling $to_branch ==="
      to_header=1
    fi
    echo "$line"
  done
}

run_e2e() {
  # Extract values from remaining args (all args still pass through to octocatalog-diff via "$@")
  local hostname="" from_branch="master" to_branch="" next_val=""
  for arg in "$@"; do
    if [ -n "$next_val" ]; then
      printf -v "$next_val" '%s' "$arg"
      next_val=""
      continue
    fi
    case "$arg" in
      --hostname) next_val=hostname ;;
      --from)     next_val=from_branch ;;
      --to)       next_val=to_branch ;;
    esac
  done
  if [ -z "$to_branch" ]; then
    to_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
  fi

  if [ -n "$hostname" ] && [ ! -f "e2e/facts/${hostname}.yaml" ]; then
    echo "Error: no fact file found for '${hostname}'"
    echo "Expected: e2e/facts/${hostname}.yaml"
    echo ""
    echo "Available hostnames:"
    for f in e2e/facts/*.yaml; do
      basename "$f" .yaml
    done | sort | sed 's/^/  /'
    return 1
  fi

  local fmt_args=()
  if [ "$CI_MODE" = "1" ]; then
    fmt_args+=(--ci)
  fi

  docker run "${DOCKER_ARGS[@]}" \
    -e PUPPET_FACT_DIR=/repo/e2e/facts \
    "$IMAGE" \
    bundle exec octocatalog-diff --basedir /repo \
    --enc /repo/e2e/enc.rb \
    --hiera-config /repo/e2e/hiera.yaml \
    --output-format json \
    "$@" \
    2> >(filter_stderr "$from_branch" "$to_branch" >&2) \
    | ruby e2e/bin/format_catalog_diff.rb "${fmt_args[@]}" 2>/dev/null
  # exit 2 = diffs found (expected), only fail on real errors
  local rc="${PIPESTATUS[0]}"
  if [ "$rc" -eq 2 ]; then rc=0; fi
  return "$rc"
}

if [ "$E2E" = "1" ]; then
  run_e2e "$@"
  exit $?
else
  usage
  exit 1
fi
