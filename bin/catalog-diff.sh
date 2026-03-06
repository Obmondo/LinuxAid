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

run_e2e() {
  # Extract --hostname value from remaining args to validate fact file exists
  local hostname="" next_is_hostname=""
  for arg in "$@"; do
    if [ -n "$next_is_hostname" ]; then
      hostname="$arg"
      break
    fi
    [ "$arg" = "--hostname" ] && next_is_hostname=1
  done

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
    | ruby e2e/bin/format_catalog_diff.rb "${fmt_args[@]}"
  return "${PIPESTATUS[0]}"
}

if [ "$E2E" = "1" ]; then
  run_e2e "$@"
  exit $?
else
  usage
  exit 1
fi
