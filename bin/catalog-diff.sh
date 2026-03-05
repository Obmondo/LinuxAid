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
  --debug       Mount .catalog-diff-debug/ as /tmp inside the container.
                Keeps all working files (catalogs, facts) for inspection after the run.
  Any additional options are passed directly to octocatalog-diff.

Examples:
  $(basename "$0") --e2e --hostname role-basic.e2etest
  $(basename "$0") --e2e --hostname role-basic.e2etest --from master --to HEAD
EOF
}

DEBUG=0

if [ "$1" = "--debug" ]; then
  DEBUG=1
  shift
fi

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

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
  --e2e)
    shift
    docker run "${DOCKER_ARGS[@]}" \
      -e PUPPET_FACT_DIR=/repo/e2e/facts \
      "$IMAGE" \
      bundle exec octocatalog-diff --basedir /repo \
      --enc /repo/e2e/enc.rb \
      --hiera-config /repo/e2e/hiera.yaml \
      "$@"
    ;;
  *)
    docker run "${DOCKER_ARGS[@]}" \
      "$IMAGE" \
      bundle exec octocatalog-diff --basedir /repo "$@"
    ;;
esac
