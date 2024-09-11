#!/bin/bash

function check_filesystem_ro {
  mountpoint -q $1
  if [ $? -eq 0 ]; then
    touch $1/.obmondowritetest
    if [ $? -eq 0 ]; then
      echo "OK: $1 is in READ_WRITE Mode"
    else
      echo "CRITICAL: $1 is in READ_ONLY Mode"
      exit 2
    fi
  fi
}

check_filesystem_ro '/var'
check_filesystem_ro '/var/log'
check_filesystem_ro '/tmp'
check_filesystem_ro '/'
