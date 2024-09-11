#!/bin/bash

set -euo pipefail

# Stage module dir after install
declare -ri STAGE=${STAGE:-1}
# Used to automatically make a commit
declare -ri COMMIT=${COMMIT:-1}
# True if the repo is given as a remote. If false we don't run git checkout but
# instead take the source as it is.
declare -i IS_REMOTE=0

declare -ri IS_ENABLEIT=${IS_ENABLEIT:-0}

# Source git repo; either git://, https:// or a local dir
source_path=$1
# Revision to check out. If unset we'll try to pick the latest master
revision=${2:-''}

cleanup() {
  if [[ -v tmp && -n "${tmp}" ]]; then
    rm -rf "${tmp}"
  fi
}

trap cleanup ERR EXIT

puppet_dir="$(dirname "$(readlink -f "${0}/..")")"
module_location=upstream
if (( IS_ENABLEIT )); then
  module_location=enableit
fi
modules_dir="${puppet_dir}/modules/${module_location}"

if [[ "${source_path}" =~ ^(git|https) ]]; then
  IS_REMOTE=1
  tmp="$(mktemp -d)"

  chmod a+rX "${tmp}"
  git clone "${source_path}" "${tmp}"
  source_dir="${tmp}"
else
  source_dir="${source_path}"
fi

latest_tag=$(git -C "${source_dir}" describe --tags --abbrev=0)

if [[ -z "${revision}" ]]; then
  echo "Using latest tag: ${latest_tag}"
  revision="${latest_tag}"
else
  echo "Using ref ${revision}"
fi

if [[ $IS_REMOTE -eq 1 ]]; then
  git -C "${source_dir}" checkout "${revision}"
fi

metadata="${source_dir}/metadata.json"
name=$(jq -r .name "${metadata}" | cut -d- -f2)
full_name=$(jq -r .name "${metadata}")
version=$(jq -r .version "${metadata}")
module_dir="${modules_dir}/${name}/"

rsync -Paq --delete            \
      --delete-excluded        \
      --exclude='/.git*'       \
      --exclude='/.fixtures.yml'   \
      --exclude='/.travis.yml' \
      --exclude='/spec'        \
      --exclude='/coverage'    \
      --exclude=Gemfile.lock   \
      --exclude=Dockerfile     \
      "${source_dir}/" "${module_dir}"

if (( STAGE )); then
  git add "${module_dir}"
fi

if (( COMMIT )); then
  git commit -F - <<EOF
Added upstream ${full_name} ${version} (rev ${revision})

Source is at ${source_path}
EOF
fi
