#!/bin/bash

PROFILES=( wildfly:8.0.0 wildfly:8.2.1 wildfly:9.0.2 wildfly:10.1.0 )
BOXES=( default centos-72-x64 debian-78-x64 debian-82-x64 ubuntu-1404-x64 ubuntu-1604-x64 )
for TEST_profile in "${PROFILES[@]}"
do
  for BOX in "${BOXES[@]}"
  do
    PUPPET_INSTALL_TYPE="agent" TEST_profile="${TEST_profile}" BEAKER_set="${BOX}" bundle exec rake beaker
  done
done
