#!/usr/bin/env bash

IMAGE=ghcr.io/obmondo/linuxaid-octocatalog-diff:2.3.1

DOCKER_ARGS=(
  --rm
  -v "$(pwd):/workspace"
  -v /tmp/.certs:/tmp/.certs:ro
  -e AUTOSIGN_CLIENT_CERT=/tmp/.certs/dev-ashish21.niwyocdmk2.pem
  -e AUTOSIGN_CLIENT_KEY=/tmp/.certs/dev-ashish21.niwyocdmk2.key
  -e AUTOSIGN_CA_CERT=/tmp/.certs/ca.pem
  -w /workspace
)

if [ "$1" = "--e2e" ]; then
  shift
  docker run "${DOCKER_ARGS[@]}" \
    -e PUPPET_FACT_DIR=/workspace/e2e/facts \
    "$IMAGE" \
    bundle exec octocatalog-diff --basedir /workspace \
    --enc /workspace/e2e/enc.rb \
    --hiera-config /workspace/e2e/hiera.yaml \
    "$@"
else
  docker run "${DOCKER_ARGS[@]}" \
    "$IMAGE" \
    bundle exec octocatalog-diff --basedir /workspace "$@"
fi
