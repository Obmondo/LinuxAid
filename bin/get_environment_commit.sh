#!/bin/bash

if (( $# != 1 )); then
  echo "Call this script with the name of the environment"
  echo "Example: ${0} production"
  exit 1
fi

ENVROOT='/etc/puppetlabs/code/environments'
GITDIR="${ENVROOT}/${1}/.git"

# check to make sure the env repo exists
if [ -d "${GITDIR}" ];
then
  "${1}:$(git --git-dir "${GITDIR}" rev-parse --short HEAD)"
else
  date '+%s'
fi
