#!/bin/bash

test -f /opt/puppetlabs/puppet/cache/lib/facter/obmondo_apache_monitor.rb

if [ $? -eq 0 ]; then
  sudo /opt/puppetlabs/puppet/bin/ruby /opt/puppetlabs/puppet/cache/lib/facter/obmondo_apache_monitor.rb 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "OK: Obmondo can monitor apache"
    exit 0
  else
    echo "CRITICAL: Obmondo can not monitor apache"
    exit 2
  fi
else
  echo "UNKNOWN: puppet/ruby/facter not installed or fact is missing"
  exit 3
fi
