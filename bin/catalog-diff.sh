#!/usr/bin/env bash

docker compose run --rm catalog-diff \
  bundle exec octocatalog-diff --basedir /workspace "$@"
